export const config = {
  // 固定埋め込みにしたい場合は下行を書き換えればOK
  region: process.env.FUNCTION_REGION ?? 'asia-northeast1',
  aiMode: 'workflow',
  openaiApiKey: process.env.OPENAI_API_KEY ?? '',
  workflow: {
    reasonUrl: process.env.WORKFLOW_URL_REASON ?? '',
    introUrl: process.env.WORKFLOW_URL_INTRO ?? '',
    reasonBatchUrl: process.env.WORKFLOW_URL_REASON_BATCH ?? '',
    // WORKFLOW_API_KEY 未設定時は OPENAI_API_KEY を自動的に流用
    apiKey: process.env.WORKFLOW_API_KEY ?? process.env.OPENAI_API_KEY ?? '',
    timeoutMs: parseInt(process.env.WORKFLOW_TIMEOUT_MS ?? '10000', 10),
  },
  crustdata: {
    enabled: process.env.ENABLE_CRUSTDATA === '1',
    apiKey: process.env.CRUSTDATA_API_KEY ?? '',
    baseUrl: process.env.CRUSTDATA_BASE_URL ?? '',
  },
  constants: {
    maxCandidates: 3,
  },
};
