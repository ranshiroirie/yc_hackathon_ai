import path from 'node:path';
import process from 'node:process';
import { promises as fs } from 'node:fs';

import { parse } from 'csv-parse/sync';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

type TemplateEntry = {
  docId: string;
  username: string;
  linkedin: string;
  profile_text: string;
  dummy_intro?: string;
  role?: string;
};

type PreparedPayload = {
  docId: string;
  payload: Record<string, unknown>;
};

type CliOptions = {
  inputPath: string;
  dryRun: boolean;
};

function normalizeLinkedin(value: string): string {
  return value
    .trim()
    .replace(/^https?:\/\//i, '')
    .replace(/^(www\.)?linkedin\.com\/in\//i, '')
    .replace(/^(www\.)?linkedin\.com\//i, '')
    .replace(/\/+$/g, '')
    .toLowerCase();
}

function sanitizeDocId(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^[-_]+|[-_]+$/g, '');
}

function ensureUniqueDocId(base: string, used: Set<string>): string {
  let candidate = base;
  let counter = 2;
  while (used.has(candidate)) {
    candidate = `${base}-${counter}`;
    counter += 1;
  }
  used.add(candidate);
  return candidate;
}

function makeDocId(linkedinVanity: string, username: string, used: Set<string>): string {
  const base = linkedinVanity ? sanitizeDocId(linkedinVanity) : sanitizeDocId(username);
  const fallback = base || 'template';
  return ensureUniqueDocId(fallback, used);
}

function extractDummyIntro(row: Record<string, string>): string {
  const key = Object.keys(row).find(k => k.startsWith('Dammy Data'));
  return key ? (row[key] || '').trim() : '';
}

function parseJudgeRole(value: string | undefined): string | undefined {
  if (!value) return undefined;
  const normalized = value.trim().toLowerCase();
  if (!normalized) return undefined;
  if (['yes', 'true', 'judge'].includes(normalized)) {
    return 'judge';
  }
  return normalized;
}

function prepareEntry(input: Partial<TemplateEntry>, usedIds: Set<string>): TemplateEntry | null {
  const username = (input.username ?? '').trim();
  const linkedin = (input.linkedin ?? '').trim();
  const profileText = (input.profile_text ?? '').trim();

  if (!username || !linkedin || !profileText) {
    console.warn('必須フィールドが欠けているためスキップします', {
      username,
      linkedin,
      hasProfileText: !!profileText,
    });
    return null;
  }

  const normalizedLinkedin = normalizeLinkedin(linkedin);
  let docId = input.docId ? sanitizeDocId(input.docId) : '';
  if (docId) {
    docId = ensureUniqueDocId(docId, usedIds);
  } else {
    docId = makeDocId(normalizedLinkedin, username, usedIds);
  }

  const entry: TemplateEntry = {
    docId,
    username,
    linkedin,
    profile_text: profileText,
  };

  if (input.dummy_intro && input.dummy_intro.trim()) {
    entry.dummy_intro = input.dummy_intro.trim();
  }
  if (input.role && input.role.trim()) {
    entry.role = input.role.trim();
  }

  return entry;
}

async function readEntriesFromJson(inputPath: string): Promise<TemplateEntry[]> {
  const raw = await fs.readFile(inputPath, 'utf8');
  const parsed = JSON.parse(raw);
  if (!Array.isArray(parsed)) {
    throw new Error('Input JSONは配列である必要があります。');
  }
  const used = new Set<string>();
  const entries: TemplateEntry[] = [];
  parsed.forEach((item, index) => {
    const entry = prepareEntry(
      {
        docId: typeof item.docId === 'string' ? item.docId : undefined,
        username: item.username,
        linkedin: item.linkedin,
        profile_text: item.profile_text,
        dummy_intro: item.dummy_intro,
        role: item.role,
      },
      used
    );
    if (!entry) {
      console.warn('JSONレコードをスキップしました', { index });
      return;
    }
    entries.push(entry);
  });
  return entries;
}

async function readEntriesFromCsv(inputPath: string): Promise<TemplateEntry[]> {
  const raw = await fs.readFile(inputPath, 'utf8');
  const records = parse(raw, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
  }) as Record<string, string>[];

  const used = new Set<string>();
  const entries: TemplateEntry[] = [];

  records.forEach((row, index) => {
    const entry = prepareEntry(
      {
        username: row['User Name'],
        linkedin: row['Linkedin'],
        profile_text: row['Profile Intro by Team'],
        dummy_intro: extractDummyIntro(row),
        role: parseJudgeRole(row['Judges']),
      },
      used
    );

    if (!entry) {
      console.warn('CSVレコードをスキップしました', { index: index + 2 }); // header offset
      return;
    }

    entries.push(entry);
  });

  return entries;
}

async function readEntries(inputPath: string): Promise<TemplateEntry[]> {
  const ext = path.extname(inputPath).toLowerCase();
  if (ext === '.csv') {
    console.info('CSVファイルからテンプレートを読み込みます。'); // eslint-disable-line no-console
    return readEntriesFromCsv(inputPath);
  }
  if (ext === '.json' || ext === '.jsonc' || ext === '') {
    console.info('JSONファイルからテンプレートを読み込みます。'); // eslint-disable-line no-console
    return readEntriesFromJson(inputPath);
  }
  throw new Error(`未対応のファイル形式です: ${ext}`);
}

function buildPayload(entry: TemplateEntry): PreparedPayload | null {
  const docId = entry.docId?.trim();
  const username = entry.username?.trim();
  const linkedin = entry.linkedin?.trim();
  const profileText = entry.profile_text?.trim();

  if (!docId || !username || !linkedin || !profileText) {
    console.warn('必須フィールドが欠けているためスキップします', {
      docId,
      username,
      linkedin,
      hasProfileText: !!profileText,
    });
    return null;
  }

  const payload: Record<string, unknown> = {
    username,
    linkedin,
    profile_text: profileText,
  };

  if (entry.dummy_intro && entry.dummy_intro.trim()) {
    payload.dummy_intro = entry.dummy_intro.trim();
  }

  if (entry.role && entry.role.trim()) {
    payload.role = entry.role.trim();
  }

  return { docId, payload };
}

async function importEntries(entries: TemplateEntry[], dryRun: boolean) {
  const db = getFirestore();
  const collection = db.collection('hackathon_profile_predata');
  const BATCH_LIMIT = 400;

  let processed = 0;
  let skipped = 0;

  for (let i = 0; i < entries.length; i += BATCH_LIMIT) {
    const slice = entries.slice(i, i + BATCH_LIMIT);
    const batch = dryRun ? null : db.batch();
    let batchCount = 0;

    for (const entry of slice) {
      const result = buildPayload(entry);
      if (!result) {
        skipped += 1;
        continue;
      }
      const { docId, payload } = result;
      if (dryRun) {
        console.info(`[dry-run] ${docId} を書き込み対象として検証しました。`); // eslint-disable-line no-console
      } else {
        batch!.set(collection.doc(docId), payload, { merge: true });
      }
      processed += 1;
      batchCount += 1;
    }

    if (!dryRun && batch && batchCount > 0) {
      await batch.commit();
      console.info(`Committed batch (${batchCount} docs)`); // eslint-disable-line no-console
    } else if (dryRun && batchCount > 0) {
      console.info(`Dry-run: ${batchCount} 件を検証しました。`); // eslint-disable-line no-console
    }
  }

  console.info(
    `完了: ${processed} 件のテンプレートを${dryRun ? '検証しました（書き込みなし）' : '更新しました'}。`
  ); // eslint-disable-line no-console
  if (skipped > 0) {
    console.warn(`${skipped} 件は必須項目欠如のためスキップしました。`);
  }
}

function parseCliOptions(): CliOptions {
  const args = process.argv.slice(2);
  let inputArg: string | null = null;
  let dryRun = false;

  for (const arg of args) {
    if (arg === '--dry-run') {
      dryRun = true;
      continue;
    }
    if (arg.startsWith('--csv=')) {
      inputArg = arg.split('=')[1];
      continue;
    }
    if (arg.startsWith('--input=')) {
      inputArg = arg.split('=')[1];
      continue;
    }
    if (!inputArg) {
      inputArg = arg;
    }
  }

  const defaultPath = path.resolve(__dirname, '../../data/hackathon_profile_predata.json');
  const resolvedInput = inputArg ? path.resolve(process.cwd(), inputArg) : defaultPath;

  return {
    inputPath: resolvedInput,
    dryRun,
  };
}

async function main() {
  const options = parseCliOptions();

  console.info(`読み込みファイル: ${options.inputPath}`); // eslint-disable-line no-console
  console.info(`モード: ${options.dryRun ? 'ドライラン（書き込みなし）' : '書き込みあり'}`); // eslint-disable-line no-console

  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS && !process.env.FIREBASE_CONFIG) {
    console.warn(
      '警告: Firebase Admin SDK の認証情報が設定されていません。' +
        ' service account JSON を指す GOOGLE_APPLICATION_CREDENTIALS を設定してください。'
    );
  }

  initializeApp({
    credential: applicationDefault(),
  });

  const entries = await readEntries(options.inputPath);
  if (entries.length === 0) {
    console.info('入力データが空のため終了します。'); // eslint-disable-line no-console
    return;
  }

  await importEntries(entries, options.dryRun);
}

main().catch(error => {
  console.error('プロフィールテンプレートの投入に失敗しました。', error); // eslint-disable-line no-console
  process.exitCode = 1;
});

