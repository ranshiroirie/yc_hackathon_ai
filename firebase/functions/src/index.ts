import * as dotenv from 'dotenv';
if (process.env.FUNCTIONS_EMULATOR === 'true') {
  dotenv.config({ path: '.env.local' });
} else if (!process.env.NODE_ENV || process.env.NODE_ENV !== 'production') {
  dotenv.config();
}

import { z } from 'zod';
import { config } from './env';
import { embedText, generateReason, generateIntro, normalize, cosine, generateReasonsBatch, refineProfileText } from './openaiClient';
import { setGlobalOptions } from 'firebase-functions/v2/options';
import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import fetch from 'node-fetch';
import { createLogger, serializeError } from './logger';

initializeApp();
const db = getFirestore();

// Set global default region
setGlobalOptions({ region: config.region });

const rootLogger = createLogger({ module: 'functions' });

function normalizeLinkedinId(linkedinId: string): string {
  return linkedinId.trim().replace(/^https?:\/\//i, '').replace(/^(www\.)?linkedin\.com\/in\//i, '').replace(/\/+$/g, '').toLowerCase();
}

function extractLinkedinVanity(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  return normalizeLinkedinId(value);
}

function buildProfileContext(profile: any) {
  return {
    nickname: profile?.nickname || '',
    generated_profile_text: profile?.generated_profile_text || '',
    introduction: profile?.introduction || '',
  };
}

type TemplateRecord = {
  id: string;
  username?: string;
  linkedin?: string;
  profile_text?: string;
  dummy_intro?: string;
};

type CandidateSourceType = 'profile' | 'predata';

type RankedCandidate = {
  uid: string;
  nickname: string;
  profile_image_key: number;
  generated_profile_text: string;
  introduction: string;
  score: number;
  sourceType: CandidateSourceType;
};

function normalizeNickname(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  if (!trimmed) return null;
  return trimmed.toLowerCase();
}

async function loadProfileTemplates(): Promise<TemplateRecord[]> {
  const snap = await db.collection('hackathon_profile_predata').get();
  const templates: TemplateRecord[] = [];
  snap.forEach(doc => {
    const data = doc.data() || {};
    templates.push({
      id: doc.id,
      username: typeof data.username === 'string' ? data.username : undefined,
      linkedin: typeof data.linkedin === 'string' ? data.linkedin : undefined,
      profile_text: typeof data.profile_text === 'string' ? data.profile_text : (typeof data.profileIntro === 'string' ? data.profileIntro : undefined),
      dummy_intro: typeof data.dummy_intro === 'string' ? data.dummy_intro : (typeof data.dammy_data === 'string' ? data.dammy_data : undefined),
    });
  });
  return templates;
}

async function ensurePredataEmbedding(templateId: string, baseText: string, existingEmbedding: unknown, logger: ReturnType<typeof rootLogger.child>): Promise<number[]> {
  const casted = Array.isArray(existingEmbedding) ? existingEmbedding as number[] : [];
  if (casted.length > 0) {
    return casted;
  }
  if (!baseText.trim()) {
    return [];
  }
  try {
    const embedded = await embedText(baseText);
    const normalized = normalize(embedded);
    await db.collection('hackathon_profile_predata').doc(templateId).set({ embedding: normalized }, { merge: true });
    logger.info('Generated embedding for predata template', { templateId });
    return normalized;
  } catch (error) {
    logger.error('Failed to generate embedding for predata template', {
      templateId,
      error: serializeError(error),
    });
    return [];
  }
}

function generateImageKeyFromId(id: string): number {
  if (!id) {
    return 1;
  }
  let hash = 0;
  for (let i = 0; i < id.length; i += 1) {
    hash = ((hash << 5) - hash) + id.charCodeAt(i);
    hash |= 0;
  }
  const positive = Math.abs(hash);
  return (positive % 10) + 1;
}

async function collectRankedCandidates(
  me: any,
  options: { excludeUid: string; logger: ReturnType<typeof rootLogger.child> }
): Promise<RankedCandidate[]> {
  const { excludeUid, logger } = options;
  const seenLinkedin = new Set<string>();
  const seenNickname = new Set<string>();
  const normalizedSelfNickname = normalizeNickname(me.nickname);
  if (normalizedSelfNickname) {
    seenNickname.add(normalizedSelfNickname);
  }
  const candidates: RankedCandidate[] = [];

  const profilesSnap = await db.collection('hackathon_profiles').get();
  for (const doc of profilesSnap.docs) {
    if (doc.id === excludeUid) continue;
    const data = doc.data() || {};
    const embedding = Array.isArray(data.embedding) ? data.embedding as number[] : [];
    if (!embedding.length || !data.generated_profile_text) continue;

    const score = cosine(me.embedding, embedding);
    const normalizedLinkedin = extractLinkedinVanity(data.linkedin_id);
    const normalizedNick = normalizeNickname(data.nickname);

    if (normalizedLinkedin) seenLinkedin.add(normalizedLinkedin);
    if (normalizedNick) seenNickname.add(normalizedNick);

    candidates.push({
      uid: doc.id,
      nickname: typeof data.nickname === 'string' ? data.nickname : '',
      profile_image_key: typeof data.profile_image_key === 'number' ? data.profile_image_key : 0,
      generated_profile_text: typeof data.generated_profile_text === 'string' ? data.generated_profile_text : '',
      introduction: typeof data.introduction === 'string' ? data.introduction : '',
      score,
      sourceType: 'profile',
    });
  }

  const predataSnap = await db.collection('hackathon_profile_predata').get();
  for (const doc of predataSnap.docs) {
    const data = doc.data() || {};
    const normalizedLinkedin = extractLinkedinVanity(data.linkedin);
    const normalizedNick = normalizeNickname(data.username);
    if (normalizedLinkedin && seenLinkedin.has(normalizedLinkedin)) {
      logger.debug('Skipping predata due to LinkedIn duplicate', { templateId: doc.id, linkedin: normalizedLinkedin });
      continue;
    }
    if (normalizedNick && seenNickname.has(normalizedNick)) {
      logger.debug('Skipping predata due to nickname duplicate', { templateId: doc.id, nickname: normalizedNick });
      continue;
    }

    const baseText = typeof data.profile_text === 'string' ? data.profile_text.trim() : '';
    if (!baseText) {
      logger.debug('Skipping predata due to missing profile text', { templateId: doc.id });
      continue;
    }

    const embedding = await ensurePredataEmbedding(doc.id, baseText, data.embedding, logger);
    if (!embedding.length) {
      logger.debug('Skipping predata due to missing embedding after attempt', { templateId: doc.id });
      continue;
    }

    const score = cosine(me.embedding, embedding);

    if (normalizedLinkedin) seenLinkedin.add(normalizedLinkedin);
    if (normalizedNick) seenNickname.add(normalizedNick);

    candidates.push({
      uid: `pre_${doc.id}`,
      nickname: typeof data.username === 'string' ? data.username : '',
      profile_image_key: typeof data.profile_image_key === 'number' ? data.profile_image_key : 0,
      generated_profile_text: baseText,
      introduction: baseText || (typeof data.dummy_intro === 'string' ? data.dummy_intro : ''),
      score,
      sourceType: 'predata',
    });
  }

  candidates.sort((a, b) => b.score - a.score);
  return candidates;
}

function enforceProfileFirst(
  sortedCandidates: RankedCandidate[],
  limit: number,
  logger: ReturnType<typeof rootLogger.child>
): RankedCandidate[] {
  if (limit <= 0) return [];
  if (sortedCandidates.length === 0) return [];

  const hasProfile = sortedCandidates.some(candidate => candidate.sourceType === 'profile');
  if (!hasProfile) {
    if (sortedCandidates.length > 0) {
      logger.info('Profile-first enforcement skipped: no profile candidates available', {
        requestedLimit: limit,
        totalCandidates: sortedCandidates.length,
      });
    }
    return sortedCandidates.slice(0, limit);
  }

  const topProfile = sortedCandidates.find(candidate => candidate.sourceType === 'profile');
  if (!topProfile) {
    return sortedCandidates.slice(0, limit);
  }

  const result: RankedCandidate[] = [topProfile];
  for (const candidate of sortedCandidates) {
    if (candidate.uid === topProfile.uid) continue;
    if (result.length >= limit) break;
    result.push(candidate);
  }

  if (result.length < limit) {
    // 補充した結果が limit 未満なら残りも追加
    for (const candidate of sortedCandidates) {
      if (result.length >= limit) break;
      if (result.some(existing => existing.uid === candidate.uid)) continue;
      result.push(candidate);
    }
  }

  return result.slice(0, limit);
}

async function fetchCrustdataProfile(linkedinVanity: string): Promise<{ generated_profile_text: string } | null> {
  const logger = rootLogger.child({ handler: 'fetchCrustdataProfile', linkedin: linkedinVanity });
  if (!config.crustdata.enabled || !config.crustdata.apiKey || !config.crustdata.baseUrl || !linkedinVanity) {
    return null;
  }
  try {
    logger.debug('Attempting Crustdata profile lookup');
    const url = new URL(config.crustdata.baseUrl);
    url.pathname = `${url.pathname.replace(/\/$/, '')}/profiles`;
    url.searchParams.set('linkedin', linkedinVanity);
    const res = await fetch(url.toString(), {
      headers: {
        'Authorization': `Bearer ${config.crustdata.apiKey}`,
        'Content-Type': 'application/json',
      },
      timeout: 8000,
    } as any);
    if (!res.ok) {
      logger.warn('Crustdata response not ok', {
        status: res.status,
        statusText: res.statusText,
      });
      return null;
    }
    const data: any = await res.json();
    const text =
      (typeof data?.profile_summary === 'string' && data.profile_summary) ||
      (typeof data?.summary === 'string' && data.summary) ||
      '';
    if (!text.trim()) {
      logger.debug('Crustdata response missing profile summary');
      return null;
    }
    logger.info('Crustdata profile fetched');
    return { generated_profile_text: text.trim() };
  } catch (error) {
    logger.error('Crustdata profile fetch failed', { error: serializeError(error) });
    return null;
  }
}

function pickTemplateMatch(templates: TemplateRecord[], nickname: string, linkedinVanity: string): TemplateRecord | null {
  const nicknameNormalized = nickname.trim().toLowerCase();
  let exactLinkedin: TemplateRecord | null = null;
  let matchedByName: TemplateRecord | null = null;
  let fallback: TemplateRecord | null = null;

  for (const tpl of templates) {
    if (!fallback && tpl.profile_text) {
      fallback = tpl;
    }
    const vanity = extractLinkedinVanity(tpl.linkedin);
    if (!exactLinkedin && vanity && vanity === linkedinVanity) {
      exactLinkedin = tpl;
    }
    if (!matchedByName && tpl.username && tpl.username.trim().toLowerCase() === nicknameNormalized) {
      matchedByName = tpl;
    }
    if (exactLinkedin && matchedByName) break;
  }

  return exactLinkedin || matchedByName || fallback;
}

export const generateProfileText = onCall(async (req: CallableRequest<any>) => {
  const start = Date.now();
  const uid = req.auth?.uid ?? 'unknown';
  const logger = rootLogger.child({ handler: 'generateProfileText', uid });

  logger.info('generateProfileText invoked', { hasAuth: !!req.auth });

  try {
    assertAnon(req);
    const schema = z.object({
      nickname: z.string().min(1).max(32),
      linkedin_id: z.string().min(3).max(100),
    });
    const { nickname, linkedin_id } = schema.parse(req.data || {});
    const normalizedLinkedin = normalizeLinkedinId(linkedin_id);

    logger.debug('Resolved input payload', {
      nicknameLength: nickname.length,
      linkedin: normalizedLinkedin,
    });

    let source: 'template' | 'crustdata' | 'none' = 'none';
    let generatedProfileText = '';
    let templateId: string | undefined;

    const crustdataResult = await fetchCrustdataProfile(normalizedLinkedin);
    if (crustdataResult) {
      generatedProfileText = crustdataResult.generated_profile_text;
      source = 'crustdata';
      logger.info('Crustdata profile selected', { durationMs: Date.now() - start });
    }

    if (!generatedProfileText) {
      const templates = await loadProfileTemplates();
      const match = pickTemplateMatch(templates, nickname, normalizedLinkedin);
      if (match?.profile_text) {
        generatedProfileText = match.profile_text;
        templateId = match.id;
        source = 'template';
        logger.info('Template profile selected', {
          durationMs: Date.now() - start,
          templateId,
        });
      } else {
        logger.warn('No template match found', {
          durationMs: Date.now() - start,
          templateCount: templates.length,
        });
      }
    }

    if (!generatedProfileText.trim()) {
      logger.info('No generated profile text available', {
        durationMs: Date.now() - start,
      });
      return {
        generated_profile_text: '',
        source: 'none',
        template_id: null,
      };
    }

    const refined = await refineProfileText({
      nickname,
      linkedinId: normalizedLinkedin,
      baseText: generatedProfileText,
    });

    const result = {
      generated_profile_text: refined.trim(),
      source,
      template_id: templateId ?? null,
    };

    logger.info('generateProfileText completed', {
      durationMs: Date.now() - start,
      source,
      templateId: templateId ?? null,
      generatedLength: result.generated_profile_text.length,
    });

    return result;
  } catch (error) {
    logger.error('generateProfileText failed', {
      durationMs: Date.now() - start,
      error: serializeError(error),
    });
    throw error;
  }
});

// Helpers
function assertAnon(req: CallableRequest<any>) {
  const provider = (req.auth?.token as any)?.firebase?.sign_in_provider;
  if (!req.auth || provider !== 'anonymous') {
    rootLogger.warn('Unauthorized request rejected', {
      handler: 'assertAnon',
      provider,
      hasAuth: !!req.auth,
    });
    throw new HttpsError('unauthenticated', 'Anonymous auth required');
  }
}

async function getProfile(uid: string): Promise<any | null> {
  const doc = await db.collection('hackathon_profiles').doc(uid).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
}

// profileUpsert
export const profileUpsert = onCall(async (req: CallableRequest<any>) => {
  const start = Date.now();
  const uid = req.auth?.uid ?? 'unknown';
  const logger = rootLogger.child({ handler: 'profileUpsert', uid });

  logger.info('profileUpsert invoked');

  try {
    assertAnon(req);

    const schema = z.object({
      nickname: z.string().min(1).max(32),
      linkedin_id: z.string().min(3).max(100),
      introduction: z.string().max(600).default(''),
      generated_profile_text: z.string().min(1).max(2000),
      profile_source: z.string().max(32).optional(),
      profile_image_key: z.number().int().nonnegative(),
    });
    const input = schema.parse(req.data || {});

    const profileRef = db.collection('hackathon_profiles').doc(uid);
    const normalizedLinkedin = normalizeLinkedinId(input.linkedin_id);
    const baseText = input.generated_profile_text.trim();

    const embedding = baseText
      ? await embedText(baseText).then(normalize).catch(error => {
        logger.error('Embedding generation failed', {
          error: serializeError(error),
        });
        return [] as number[];
      })
      : [];

    const existing = await profileRef.get();

    const payload: Record<string, unknown> = {
      nickname: input.nickname,
      linkedin_id: normalizedLinkedin,
      introduction: input.introduction ?? '',
      generated_profile_text: baseText,
      profile_image_key: input.profile_image_key,
      embedding,
      updated_at: FieldValue.serverTimestamp(),
    };

    if (input.profile_source) {
      payload.profile_source = input.profile_source;
    }

    if (!existing.exists) {
      payload.created_at = FieldValue.serverTimestamp();
    }

    await profileRef.set(payload, { merge: true });

    logger.info('profileUpsert completed', {
      isCreate: !existing.exists,
      embeddingLength: embedding.length,
      durationMs: Date.now() - start,
    });

    return { ok: true };
  } catch (error) {
    logger.error('profileUpsert failed', {
      durationMs: Date.now() - start,
      error: serializeError(error),
    });
    throw error;
  }
});

// getRecommendations
export const getRecommendations = onCall(async (req: CallableRequest<any>) => {
  const start = Date.now();
  const uid = req.auth?.uid ?? 'unknown';
  const logger = rootLogger.child({ handler: 'getRecommendations', uid });

  logger.info('getRecommendations invoked');

  try {
    assertAnon(req);
    const schema = z.object({ limit: z.number().int().min(1).max(10).default(3), force: z.boolean().default(false) });
    const { limit } = schema.parse(req.data || {});

    const me = await getProfile(uid);
    if (!me || !Array.isArray(me.embedding) || me.embedding.length === 0 || !me.generated_profile_text) {
      logger.warn('Profile missing embedding', { durationMs: Date.now() - start });
      throw new HttpsError('failed-precondition', 'Profile or embedding missing');
    }

    const ranked = await collectRankedCandidates(me, { excludeUid: uid, logger });
    const top = enforceProfileFirst(ranked, limit, logger);

    logger.info('Similarity candidates resolved', {
      totalCandidates: ranked.length,
      returned: top.length,
      durationMs: Date.now() - start,
    });

    const reasonsBatch = await generateReasonsBatch(
      buildProfileContext(me),
      top.map(c => ({
        id: c.uid,
        nickname: c.nickname,
        generated_profile_text: c.generated_profile_text,
        introduction: c.introduction,
      }))
    );
    const reasonMap = new Map(reasonsBatch.map(r => [r.id, r.reason]));
    const reasons = top.map(c => ({
      ...c,
      reason: reasonMap.get(c.uid) || 'You might have interesting topics to explore together.',
    }));

    logger.info('getRecommendations completed', {
      durationMs: Date.now() - start,
      reasonsGenerated: reasonsBatch.length,
    });

    return {
      candidates: reasons.map(
        ({ uid, nickname, profile_image_key, score, reason, introduction, sourceType }) => ({
          uid,
          nickname,
          profile_image_key,
          score,
          reason,
          introduction,
          sourceType,
        })
      ),
    };
  } catch (error) {
    logger.error('getRecommendations failed', {
      durationMs: Date.now() - start,
      error: serializeError(error),
    });
    throw error;
  }
});

// proposeConnection
export const proposeConnection = onCall(async (req: CallableRequest<any>) => {
  const start = Date.now();
  const uidA = req.auth?.uid ?? 'unknown';
  const logger = rootLogger.child({ handler: 'proposeConnection', uid: uidA });

  logger.info('proposeConnection invoked');

  try {
    assertAnon(req);
    const schema = z.object({ toUid: z.string().min(1), note: z.string().max(200).optional() });
    const { toUid } = schema.parse(req.data || {});

    if (toUid.startsWith('pre_')) {
      const templateId = toUid.substring(4);
      const [me, templateSnap] = await Promise.all([
        getProfile(uidA),
        db.collection('hackathon_profile_predata').doc(templateId).get(),
      ]);

      if (!me) {
        logger.warn('Proposer profile not found for predata proposal', {
          durationMs: Date.now() - start,
          templateId,
        });
        throw new HttpsError('not-found', 'Profile not found');
      }

      if (!templateSnap.exists) {
        logger.warn('Predata template not found for proposal', {
          durationMs: Date.now() - start,
          templateId,
        });
        throw new HttpsError('not-found', 'Candidate not available');
      }

      const template = templateSnap.data() || {};
      const nickname = typeof template.username === 'string' && template.username.trim()
        ? template.username.trim()
        : 'Guest';
      const profileTextRaw = typeof template.profile_text === 'string' ? template.profile_text : '';
      const dummyIntroRaw = typeof template.dummy_intro === 'string' ? template.dummy_intro : '';
      const introduction = profileTextRaw.trim() || dummyIntroRaw.trim() || 'Looking forward to meeting you at the event!';
      const linkedin = typeof template.linkedin === 'string' ? template.linkedin.trim() : '';
      const profileImageKey = typeof template.profile_image_key === 'number' && template.profile_image_key > 0
        ? template.profile_image_key
        : generateImageKeyFromId(templateId);

      await new Promise(resolve => setTimeout(resolve, 800));

      const messageId = `predata_auto_${Date.now()}`;
      await db.collection('ai_messages').doc(uidA).collection('messages').doc(messageId).set({
        type: 'MATCH_INTRO',
        created_at: FieldValue.serverTimestamp(),
        isCopiable: false,
        intro: {
          peer: {
            uid: toUid,
            nickname,
            profile_image_key: profileImageKey,
            social_link: linkedin,
            linkedin_id: linkedin,
            introduction,
            generated_profile_text: introduction,
          },
          topics: [],
          ice_breaker: `Hi ${nickname}! Looking forward to connecting at the event.`,
        },
        meta: {
          sourceType: 'predata',
          autoSayHi: true,
          templateId,
        },
      });

      logger.info('Auto say-hi response created for predata proposal', {
        durationMs: Date.now() - start,
        templateId,
      });

      return { proposalId: `auto_${templateId}` };
    }

    const [a, b] = await Promise.all([getProfile(uidA), getProfile(toUid)]);
    if (!a || !b) {
      logger.warn('Profile not found for proposal', { durationMs: Date.now() - start, toUid });
      throw new HttpsError('not-found', 'Profile not found');
    }

    const reason = await generateReason(buildProfileContext(a), buildProfileContext(b)).catch(error => {
      logger.error('generateReason failed', {
        durationMs: Date.now() - start,
        error: serializeError(error),
      });
      return 'You might have interesting topics to explore together.';
    });

    await db.collection('ai_messages').doc(toUid).collection('messages').add({
      type: 'REQUEST_MATCH',
      created_at: FieldValue.serverTimestamp(),
      fromUid: uidA,
      candidate: { uid: uidA, nickname: a.nickname || '', profile_image_key: a.profile_image_key || 0 },
      reason,
    });

    logger.info('proposeConnection completed', {
      durationMs: Date.now() - start,
      toUid,
    });

    return { proposalId: 'ok' };
  } catch (error) {
    logger.error('proposeConnection failed', {
      durationMs: Date.now() - start,
      error: serializeError(error),
    });
    throw error;
  }
});

// respondConnection
export const respondConnection = onCall(async (req: CallableRequest<any>) => {
  const start = Date.now();
  const uidB = req.auth?.uid ?? 'unknown';
  const logger = rootLogger.child({ handler: 'respondConnection', uid: uidB });

  logger.info('respondConnection invoked');

  try {
    assertAnon(req);
    const schema = z.object({ fromUid: z.string().min(1), accept: z.boolean(), reply_reason: z.string().max(200).optional() });
    const { fromUid, accept } = schema.parse(req.data || {});

    if (!accept) {
      logger.info('Connection declined', { fromUid, durationMs: Date.now() - start });
      return { matched: false };
    }

    const [a, b] = await Promise.all([getProfile(fromUid), getProfile(uidB)]);
    if (!a || !b) {
      logger.warn('Profile not found during respondConnection', {
        fromUid,
        durationMs: Date.now() - start,
      });
      throw new HttpsError('not-found', 'Profile not found');
    }

    const pair = [fromUid, uidB].sort().join('_');
    const matchRef = db.collection('hackathon_matches').doc(pair);

    await db.runTransaction(async (tx) => {
      const m = await tx.get(matchRef);
      if (!m.exists) {
        tx.set(matchRef, {
          uids: [fromUid, uidB],
          matched_at: FieldValue.serverTimestamp(),
        });
      }
    });

    const intro = await generateIntro(
      buildProfileContext(a),
      buildProfileContext(b)
    ).catch(error => {
      logger.error('generateIntro failed', {
        error: serializeError(error),
      });
      return {
        topics: ['Your projects', 'AI/UX', 'Community'],
        ice_breaker_for_target: 'Hi! Would love to chat today at the event!',
        ice_breaker_for_peer: 'Hi! Would love to chat today at the event!'
      };
    });

    const makeIntro = (peer: any, iceBreaker: string) => ({
      peer: {
        uid: peer.id,
        nickname: peer.nickname || '',
        profile_image_key: peer.profile_image_key || 0,
        linkedin_id: peer.linkedin_id || '',
        introduction: peer.introduction || '',
        generated_profile_text: peer.generated_profile_text || '',
      },
      topics: intro.topics,
      ice_breaker: iceBreaker
    });

    await Promise.all([
      db.collection('ai_messages').doc(fromUid).collection('messages').doc(`intro_${pair}`).set({
        type: 'MATCH_INTRO',
        created_at: FieldValue.serverTimestamp(),
        isCopiable: true,
        intro: makeIntro(b, intro.ice_breaker_for_target)
      }),
      db.collection('ai_messages').doc(uidB).collection('messages').doc(`intro_${pair}`).set({
        type: 'MATCH_INTRO',
        created_at: FieldValue.serverTimestamp(),
        isCopiable: true,
        intro: makeIntro(a, intro.ice_breaker_for_peer)
      })
    ]);

    logger.info('respondConnection completed', {
      durationMs: Date.now() - start,
      matchId: pair,
    });

    return { matched: true, matchId: pair };
  } catch (error) {
    logger.error('respondConnection failed', {
      durationMs: Date.now() - start,
      error: serializeError(error),
    });
    throw error;
  }
});

// Firestore trigger: profiles.onCreate => FOUND_MATCH
export const onProfileCreate = onDocumentCreated('hackathon_profiles/{uid}', async (event) => {
  const start = Date.now();
  const uid = event.params.uid as string;
  const logger = rootLogger.child({ handler: 'onProfileCreate', uid });

  logger.info('onProfileCreate triggered');

  try {
    const me = event.data?.data() as any;
    if (!me || !Array.isArray(me.embedding) || me.embedding.length === 0 || !me.generated_profile_text) {
      logger.warn('New profile missing embedding or generated text', { durationMs: Date.now() - start });
      return;
    }

    const ranked = await collectRankedCandidates(me, { excludeUid: uid, logger });
    const top = enforceProfileFirst(ranked, config.constants.maxCandidates, logger);

    logger.info('Trigger candidate similarity resolved', {
      totalCandidates: ranked.length,
      returned: top.length,
    });

    if (top.length === 0) {
      logger.info('No candidates available for FOUND_MATCH notification', {
        durationMs: Date.now() - start,
      });
      return;
    }

    const reasonsBatch = await generateReasonsBatch(
      buildProfileContext(me),
      top.map(c => ({
        id: c.uid,
        nickname: c.nickname,
        generated_profile_text: c.generated_profile_text,
        introduction: c.introduction,
      }))
    );
    const rmap = new Map(reasonsBatch.map(r => [r.id, r.reason]));
    const reasons = top.map(c => ({
      uid: c.uid,
      nickname: c.nickname,
      profile_image_key: c.profile_image_key,
      score: c.score,
      sourceType: c.sourceType,
      introduction: c.introduction,
      reason: rmap.get(c.uid) || 'You might have interesting topics to explore together.'
    }));

    await db.collection('ai_messages').doc(uid).collection('messages').add({
      type: 'FOUND_MATCH',
      created_at: FieldValue.serverTimestamp(),
      candidates: reasons,
    });

    logger.info('onProfileCreate completed', {
      durationMs: Date.now() - start,
      candidatesStored: reasons.length,
    });
  } catch (error) {
    logger.error('onProfileCreate failed', {
      durationMs: Date.now() - start,
      error: serializeError(error),
    });
    throw error;
  }
});
