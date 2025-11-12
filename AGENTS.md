# AGENTS.md - homii_ai_event_comp_app

常に日本語で回答してください。
このリポジトリは AI ハッカソン向けの最小実装用モバイルアプリ（Flutter）です。バックエンドは新設の Firebase プロジェクト（Firestore + Functions v2 + 匿名Auth）を前提とします。

## 📦 構成
- Flutter App: このリポジトリ
- Firebase Functions: 別プロジェクト（Callable Functions のみ）
- Firestore: `hackathon_*` 名前空間の簡易スキーマ

## 🎯 目標（MVP）
- 匿名ログイン → プロフィール登録（nickname / linkedin_id / introduction / generated_profile_text / profile_image_key）
- イベントは**固定で1つ**。プロフィール登録 = 参加登録。
- AIが候補最大3名を提案 → 片方向提案/相互承認でマッチ成立
- AIメッセージ（擬似チャット）で通知・紹介（social link開示）

## 🔌 バックエンドAPI（Callable）
- `generateProfileText({ nickname, linkedin_id })`
- `profileUpsert({ nickname, linkedin_id, introduction, generated_profile_text, profile_image_key })`
- `getRecommendations({ limit?, force? }) -> { candidates: [...] }`
- `proposeConnection({ toUid, note? })`
- `respondConnection({ fromUid, accept, reply_reason? })`

リアルタイムは `ai_messages/{uid}/messages` を onSnapshot 購読。

## 🗄️ Firestore 概要
- `hackathon_profiles/{uid}`: nickname, linkedin_id, introduction, generated_profile_text, profile_image_key, embedding:number[]
- `hackathon_recommendations/{uid}/items/{recId}`
- `hackathon_matches/{pairId}` // pairId = min(uidA,uidB)+'_'+max(uidA,uidB)
- `ai_messages/{uid}/messages/{msgId}`

## 🔒 ルール方針（β）
- 匿名Auth必須・`hackathon_*`配下のみ許可・期間限定のゆるめルール→終了後に厳格化。

## 🤖 AIチャットの扱い
- 既存HomiiのSupabase/Prismaベースのチャットは直接流用しません。
- OpenAIユーティリティ（埋め込み/短文生成/リトライ等）のみ再利用し、Firestoreに**擬似AIメッセージ**を書き込みます。

## 🛠️ 開発コマンド
```bash
flutter pub get
flutter run
flutter analyze   # エラー0を目標
```

## ✅ 品質・運用
- 例外はユーザーに優しい文言で表示（ネットワーク/レート制限）
- ログ/計測は最小限（画面遷移・API失敗）
- ハッカソン終了後にデータTTL/クリーンアップ実施

注記: プロフィール保存後に Firestore onCreate トリガーで自動的に FOUND_MATCH を投下します。手動の再取得が必要な場合のみ getRecommendations を使用します。