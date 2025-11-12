import { config } from './env';
import OpenAI from 'openai';
import fetch from 'node-fetch';
import { createLogger, serializeError } from './logger';

const WORKFLOW_REASON_BATCH_ID =
  process.env.WORKFLOW_ID_REASON_BATCH ?? 'wf_6913516ec01081908c14c2c76263cb1b0463dd17238b2541';
const WORKFLOW_INTRO_ID =
  process.env.WORKFLOW_ID_INTRO ?? 'wf_69137b4bc6748190b1e1af0992a98d6601f0c7b9b6a3caa6';

const WORKFLOW_ENDPOINT = 'https://api.openai.com/v1/workflows';

const logger = createLogger({ module: 'openaiClient' });

const client = () => new OpenAI({ apiKey: config.openaiApiKey });

type ProfileContext = {
  nickname: string;
  generated_profile_text: string;
  introduction?: string;
};

function sanitize(text: string | undefined | null): string {
  return (text ?? '').trim();
}

function formatContextForPrompt(ctx: ProfileContext, label: string): string {
  const parts: string[] = [
    `${label}:`,
    `- nickname: ${ctx.nickname}`,
    `- generated_profile_text: ${sanitize(ctx.generated_profile_text) || '(none)'}`,
  ];
  if (sanitize(ctx.introduction)) {
    parts.push(`- introduction: ${sanitize(ctx.introduction)}`);
  }
  return parts.join('\n');
}

function workflowPayload(ctx: ProfileContext) {
  return {
    nickname: ctx.nickname,
    generated_profile_text: sanitize(ctx.generated_profile_text),
    introduction: sanitize(ctx.introduction),
  };
}

type WorkflowInvokeOptions = {
  inputs?: Record<string, unknown>;
  /**
   * @deprecated Legacyフィールド。自動的にinputsへマージされます。
   */
  state?: Record<string, unknown>;
};

async function runWorkflow(workflowId: string, options: WorkflowInvokeOptions): Promise<any> {
  const workflowLogger = logger.child({ handler: 'runWorkflow', workflowId });
  workflowLogger.debug('Invoking workflow', { aiMode: config.aiMode });

  try {
    const legacyState = options.state ?? {};
    const baseInputs = options.inputs ?? {};
    const payloadInputs: Record<string, unknown> = { ...baseInputs };

    if (legacyState && Object.keys(legacyState).length > 0) {
      if (Object.keys(baseInputs).length > 0) {
        workflowLogger.warn('Both inputs and state provided, merging objects for workflow payload');
      }
      Object.assign(payloadInputs, legacyState);
    }

    const res = await fetch(`${WORKFLOW_ENDPOINT}/${workflowId}/runs`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${config.openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: payloadInputs,
      }),
      timeout: config.workflow.timeoutMs,
    } as any);
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      workflowLogger.error('Workflow HTTP error', {
        status: res.status,
        statusText: res.statusText,
        bodyPreview: text ? text.slice(0, 200) : undefined,
      });
      throw new Error(`Workflow ${workflowId} failed: ${res.status} ${res.statusText} ${text}`);
    }
    const data: any = await res.json();
    const outputs =
      data?.response?.outputs ??
      data?.outputs ??
      data?.output ??
      [];
    workflowLogger.debug('Workflow response received', {
      hasOutputs: Array.isArray(outputs) && outputs.length > 0,
    });
    if (Array.isArray(outputs) && outputs.length > 0) {
      const first = outputs[0];
      const content = first?.content ?? first;
      if (Array.isArray(content) && content[0]?.type === 'json') {
        workflowLogger.info('Workflow returned structured JSON');
        return content[0].json;
      }
      if (content?.type === 'json') {
        workflowLogger.info('Workflow returned JSON payload');
        return content.json;
      }
      if (content?.type === 'text') {
        workflowLogger.info('Workflow returned text payload');
        return { text: content.text };
      }
      if (Array.isArray(content)) {
        workflowLogger.info('Workflow returned array payload');
        return content;
      }
      if (typeof content === 'object') {
        workflowLogger.info('Workflow returned object payload');
        return content;
      }
    }
    workflowLogger.info('Workflow returned raw data');
    return data;
  } catch (error) {
    workflowLogger.error('Workflow invocation failed', { error: serializeError(error) });
    throw error;
  }
}

export async function embedText(text: string): Promise<number[]> {
  const embedLogger = logger.child({ handler: 'embedText' });
  embedLogger.debug('Embedding text', { textLength: text.length, aiMode: config.aiMode });

  try {
    if (config.aiMode === 'workflow') {
      // If workflow has an embedding endpoint you can add it later; default to direct
      embedLogger.debug('Workflow mode does not yet support embeddings, using direct API');
    }
    const res = await client().embeddings.create({
      model: 'text-embedding-3-small',
      input: text,
    });
    const embedding = res.data[0].embedding as unknown as number[];
    embedLogger.debug('Embedding generated', { embeddingLength: embedding.length });
    return embedding;
  } catch (error) {
    embedLogger.error('Embedding generation failed', { error: serializeError(error) });
    throw error;
  }
}

export async function refineProfileText(input: {
  nickname: string;
  linkedinId: string;
  baseText: string;
}): Promise<string> {
  const base = sanitize(input.baseText);
  if (!base) {
    return '';
  }

  const refineLogger = logger.child({ handler: 'refineProfileText', nickname: input.nickname });
  refineLogger.debug('Refining profile text', { baseLength: base.length });

  const prompt =
    `You are an event concierge crafting a short English profile for a networking app.\n` +
    `Keep it under 600 characters, energetic but professional. Use first-person voice.\n` +
    `Highlight the attendee's expertise, current focus, and networking goals. Avoid bullet lists.\n\n` +
    `Attendee nickname: ${input.nickname}\n` +
    `LinkedIn vanity: ${input.linkedinId}\n` +
    `Base profile text:\n${base}\n` +
    `\nReturn only the refined paragraph.`;

  try {
    const res = await client().responses.create({
      model: 'gpt-4o-mini',
      input: prompt,
    });
    const text = (res.output_text || '').trim();
    refineLogger.debug('Profile text refined', { refinedLength: text.length });
    return text || base;
  } catch (error) {
    refineLogger.error('refineProfileText failed', { error: serializeError(error) });
    return base;
  }
}

export async function generateReason(a: ProfileContext, b: ProfileContext): Promise<string> {
  const reasonLogger = logger.child({ handler: 'generateReason', target: a.nickname, peer: b.nickname });
  reasonLogger.debug('Generating match reason', { aiMode: config.aiMode });

  if (config.aiMode === 'workflow') {
    try {
      const data = await runWorkflow(WORKFLOW_REASON_BATCH_ID, {
        inputs: {
          target_user: workflowPayload(a),
          candidates: [
            {
              id: 'peer',
              ...workflowPayload(b),
            },
          ],
          limit: 1,
          style: { max_chars: 200 },
        },
      });
      const ranking = data?.ranking ?? data?.recommendations ?? [];
      const reason = ranking[0]?.reason ?? data?.reason;
      if (reason) {
        const sliced = String(reason).slice(0, 200);
        reasonLogger.info('Reason generated via workflow', { source: 'workflow', length: sliced.length });
        return sliced;
      }
    } catch (error) {
      reasonLogger.error('generateReason workflow failed', { error: serializeError(error) });
    }
  }

  const prompt = `You are an event assistant. Respond in English only.\n` +
    `Write one or two concise sentences (<= 200 characters) explaining why the two people below might be a good match. ` +
    `Use their generated profile text and introductions as context. Avoid sensitive claims or contact info.\n\n` +
    `${formatContextForPrompt(a, 'Target user')}\n\n${formatContextForPrompt(b, 'Candidate')}`;

  const res = await client().responses.create({
    model: 'gpt-4o-mini',
    input: prompt,
  });
  const text = (res.output_text || '').trim();
  const sliced = text.slice(0, 200);
  reasonLogger.info('Reason generated via direct API', { source: 'direct', length: sliced.length });
  return sliced;
}

export async function generateReasonsBatch(
  me: ProfileContext,
  candidates: Array<{ id: string; nickname: string; generated_profile_text: string; introduction?: string }>
): Promise<Array<{ id: string; reason: string }>> {
  if (candidates.length === 0) return [];

  const batchLogger = logger.child({ handler: 'generateReasonsBatch', candidateCount: candidates.length });
  batchLogger.debug('Generating reasons batch', { aiMode: config.aiMode });

  // Workflow batch endpointがあれば使用
  if (config.aiMode === 'workflow') {
    try {
      const data = await runWorkflow(WORKFLOW_REASON_BATCH_ID, {
        inputs: {
          target_user: workflowPayload(me),
          candidates: candidates.map(c => ({
            id: c.id,
            ...workflowPayload({
              nickname: c.nickname,
              generated_profile_text: c.generated_profile_text,
              introduction: c.introduction,
            }),
          })),
          limit: candidates.length,
          style: { max_chars: 200 },
        },
      });
      const ranking = data?.ranking ?? data?.recommendations ?? [];
      if (Array.isArray(ranking)) {
        batchLogger.info('Batch reasons generated via workflow', { generated: ranking.length });
        return ranking.map((x: any) => ({
          id: String(x.id),
          reason: String(x.reason || '').slice(0, 200),
        }));
      }
    } catch (error) {
      batchLogger.error('generateReasonsBatch workflow failed', { error: serializeError(error) });
    }
  }

  // direct: JSONで返すよう強く指示
  const list = candidates.map((c, i) => {
    const lines = [
      `${i + 1}. id=${c.id}, nickname=${c.nickname}`,
      `   generated_profile_text=${sanitize(c.generated_profile_text) || '(none)'}`,
    ];
    if (sanitize(c.introduction)) {
      lines.push(`   introduction=${sanitize(c.introduction)}`);
    }
    return lines.join('\n');
  }).join('\n');
  const prompt =
    `You are an event assistant. Respond in English only.\n` +
    `For EACH candidate below, write one or two concise sentences (<= 200 characters) explaining why the user might be a good match with the candidate.\n` +
    `Return ONLY a pure JSON array of objects: [{"id":"<id>","reason":"<text>"}]. No markdown, no extra text.\n\n` +
    `${formatContextForPrompt(me, 'Target user')}\n\nCandidates:\n${list}`;

  const res = await client().responses.create({
    model: 'gpt-4o-mini',
    input: prompt,
  });
  const text = (res.output_text || '').trim();
  batchLogger.info('Batch reasons generated via direct prompt', { source: 'direct' });
  try {
    const arr = JSON.parse(text);
    if (Array.isArray(arr)) {
      return arr.map((x: any) => ({ id: String(x.id), reason: String(x.reason || '') }))
        .map(x => ({ ...x, reason: x.reason.slice(0, 200) }));
    }
  } catch (_) {
    // ignore
  }
  // フォールバック: 個別生成
  batchLogger.warn('Batch reasons fallback to per-candidate generation');
  const out: Array<{ id: string; reason: string }> = [];
  for (const c of candidates) {
    const r = await generateReason(me, {
      nickname: c.nickname,
      generated_profile_text: c.generated_profile_text,
      introduction: c.introduction,
    }).catch(() => 'You might have interesting topics to explore together.');
    out.push({ id: c.id, reason: r.slice(0, 200) });
  }
  return out;
}

export async function generateIntro(
  a: ProfileContext,
  b: ProfileContext
): Promise<{ topics: string[]; ice_breaker_for_target: string; ice_breaker_for_peer: string }> {
  const introLogger = logger.child({ handler: 'generateIntro', target: a.nickname, peer: b.nickname });
  introLogger.debug('Generating intro payload', { aiMode: config.aiMode });

  if (config.aiMode === 'workflow') {
    try {
      const data = await runWorkflow(WORKFLOW_INTRO_ID, {
        inputs: {
          target_user: workflowPayload(a),
          peer_user: workflowPayload(b),
          style: { topics: 3, ice_breaker_max_chars: 200 },
        },
      });
      const topics = Array.isArray(data?.topics) ? data.topics.slice(0, 3).map(String) : [];
      const iceTarget = typeof data?.ice_breaker_for_target === 'string'
        ? data.ice_breaker_for_target
        : 'Hi! I would love to connect with you at the event!';
      const icePeer = typeof data?.ice_breaker_for_peer === 'string'
        ? data.ice_breaker_for_peer
        : 'Hi! I would love to connect with you at the event!';
      introLogger.info('Intro generated via workflow', {
        topics: topics.length,
      });
      return {
        topics,
        ice_breaker_for_target: String(iceTarget).slice(0, 200),
        ice_breaker_for_peer: String(icePeer).slice(0, 200),
      };
    } catch (error) {
      introLogger.error('generateIntro workflow failed', { error: serializeError(error) });
    }
  }

  const prompt =
    `You are an event assistant. Respond in English only.\n` +
    `Return ONLY JSON with fields "topics" (array of 3 concise items), ` +
    `"ice_breaker_for_target" (one sentence <=200 chars for ${a.nickname} to message ${b.nickname}), ` +
    `"ice_breaker_for_peer" (one sentence <=200 chars for ${b.nickname} to message ${a.nickname}).\n` +
    `Focus on friendly, practical openings based on the profiles below.\n\n` +
    `${formatContextForPrompt(a, 'target_user')}\n\n${formatContextForPrompt(b, 'peer_user')}`;
  const res = await client().responses.create({
    model: 'gpt-4o-mini',
    input: prompt,
  });
  const text = (res.output_text || '').trim();
  introLogger.info('Intro generated via direct prompt');
  try {
    const parsed = JSON.parse(text);
    const topics = Array.isArray(parsed?.topics) ? parsed.topics.slice(0, 3).map(String) : [];
    const iceTarget = typeof parsed?.ice_breaker_for_target === 'string'
      ? parsed.ice_breaker_for_target
      : 'Hi! I would love to connect with you at the event!';
    const icePeer = typeof parsed?.ice_breaker_for_peer === 'string'
      ? parsed.ice_breaker_for_peer
      : 'Hi! I would love to connect with you at the event!';
    return {
      topics,
      ice_breaker_for_target: iceTarget.slice(0, 200),
      ice_breaker_for_peer: icePeer.slice(0, 200)
    };
  } catch (_) {
    // fallback to simple template
    introLogger.warn('Intro JSON parse failed, falling back to template');
    return {
      topics: ['AI projects', 'Onboarding experiences', 'Event goals'],
      ice_breaker_for_target: 'Hi! I’d love to connect and talk more about our event goals!',
      ice_breaker_for_peer: 'Hi! I’d love to connect and talk more about our event goals!'
    };
  }
}

export function normalize(v: number[]): number[] {
  const norm = Math.sqrt(v.reduce((s, x) => s + x * x, 0));
  if (!norm) return v.map(() => 0);
  return v.map(x => x / norm);
}

export function cosine(a: number[], b: number[]): number {
  const len = Math.min(a.length, b.length);
  let s = 0; for (let i = 0; i < len; i++) s += (a[i] || 0) * (b[i] || 0);
  return s;
}
