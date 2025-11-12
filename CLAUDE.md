# CLAUDE.md - 開発ガイド（ハッカソン用）

## アーキテクチャ
- Firebase: 新規プロジェクト（例: homii-ai-companion）
- Auth: 匿名のみ
- API: Callable Functions v2（asia-northeast1, 128MB, timeout 15s, maxInstances 5）
- DB: Firestore（`hackathon_*`名前空間）
- Realtime: `ai_messages` を onSnapshot
- イベント: **固定1件**。`EVENT_ID` は Functions 側の定数/環境変数で管理（例: `HACKATHON_EVENT_ID`）。

## Firestore スキーマ（MVP）
- `hackathon_profiles/{uid}`: nickname, linkedin_id, introduction, generated_profile_text, profile_image_key:int, embedding:number[], created_at, updated_at
- `hackathon_recommendations/{uid}/items/{recId}`: to_uid, score, reason, status, created_at
- `hackathon_matches/{pairId}`: uids:[uidA,uidB], matched_at, eventId
- `ai_messages/{uid}/messages/{msgId}`: role, text, meta, created_at

## Callable API 契約（イベント固定版）
- `profileUpsert(data)` → { ok: true }  // プロフ保存＋埋め込み生成＋members登録
- `getRecommendations({ limit?=3 })`
- `proposeConnection({ toUid, note? })` → { proposalId }
- `respondConnection({ fromUid, accept, reply_reason? })` → { matched, matchId? }

## AIチャット移植方針
- Supabase/Prisma の既存チャットは使わず、OpenAIユーティリティのみ再利用。
- Functions が生成する文面を `ai_messages` に書き込み、クライアントが購読してUI表示。

## 実装手順（最短）
1) Firebase プロジェクト作成 → 匿名Auth ON / Firestore 作成
2) Functions: `profileUpsert` / `getRecommendations` を先着手
3) Flutter: 匿名サインイン→プロフィール入力→候補→提案/承認→紹介（`ai_messages`購読）

## 環境変数
- `OPENAI_API_KEY`
- `HACKATHON_EVENT_ID`（固定イベントID）

## 品質ゲート
- Flutter: `flutter analyze` エラー0
- Functions（別リポ）: `npm run lint` エラー0

注記: プロフィール保存後に Firestore onCreate トリガーで自動的に FOUND_MATCH を投下します。手動の再取得が必要な場合のみ getRecommendations を使用します。


## 環境変数（AI切替）
- AI_MODE=direct|workflow
- WORKFLOW_URL_REASON
- WORKFLOW_URL_INTRO
- WORKFLOW_API_KEY
- WORKFLOW_TIMEOUT_MS(=10000)


## Language Policy
- UI language: English
- AI prompts & outputs: English-only