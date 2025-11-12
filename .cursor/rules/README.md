# Cursor Rules Directory Structure

このディレクトリには、Homii World モノレポプロジェクト用のCursor IDE設定ルールが整理されています。

## 📁 Directory Structure

```
.cursor/rules/
├── README.md                           # このファイル
├── common/                             # 共通ルール
│   ├── base-principles.mdc             # AI対話・Clean Architecture基本原則
│   ├── monorepo-coordination.mdc       # コンポーネント間連携ルール
│   ├── reviewer-assist.mdc             # コードレビュー支援ルール
│   └── security-auth.mdc               # 認証・セキュリティパターン
├── flutter/                            # Flutter App 専用ルール
│   ├── generator.mdc                   # Riverpod・状態管理・アーキテクチャルール
│   ├── quality.mdc                     # 品質保証・テスト・開発フロールール
│   └── performance.mdc                 # パフォーマンス最適化・メモリ管理ルール
├── firebase/                           # Firebase Functions 専用ルール
│   ├── generator.mdc                   # Clean Architecture・API設計ルール
│   ├── cost-optimization.mdc           # コスト最適化・監視・緊急対応ルール
│   └── airtable-integration.mdc        # Airtable統合・サーバーサイドフィルタリングルール
├── supabase/                           # Supabase 専用ルール
│   ├── generator.mdc                   # データベース・RPC・リアルタイム機能ルール
│   └── security.mdc                    # Row Level Security・認証・権限管理ルール
└── system-doc/                         # System Documentation 専用ルール
    └── requirements-design.mdc         # 要件定義・設計ドキュメント品質ルール
```

## 🎛️ Rule Application Settings

### alwaysApply Settings
- **`auto`**: ファイル保存時やコード変更時に自動適用
- **`manual`**: 必要時にのみ手動適用（パフォーマンスや特定作業時）

### Rule Categories

#### **Common Rules** (`common/`)
- **base-principles.mdc** (`alwaysApply: auto`)
  - AI対話の基本ルール
  - Clean Architecture原則
  - セキュリティベースライン

- **monorepo-coordination.mdc** (`alwaysApply: auto`)
  - コンポーネント間API契約
  - 開発フロー調整
  - バージョン管理

- **reviewer-assist.mdc** (`alwaysApply: auto`)
  - 構造化レビューガイドライン
  - Critical/Major/Minor優先度マトリクス

- **security-auth.mdc** (`alwaysApply: manual`)
  - Firebase Authentication統合パターン
  - セキュリティベストプラクティス

#### **Flutter Rules** (`flutter/`)
- **generator.mdc** (`alwaysApply: auto`)
  - Riverpod状態管理パターン
  - Import組織化ルール
  - UI・サービス層分離

- **quality.mdc** (`alwaysApply: auto`)
  - FVM必須使用
  - スクリプト統一
  - テスト品質基準

- **performance.mdc** (`alwaysApply: manual`)
  - JsonIsolate活用
  - Google Maps最適化
  - メモリ管理パターン

#### **Firebase Rules** (`firebase/`)
- **generator.mdc** (`alwaysApply: auto`)
  - Clean Architecture 4層構造
  - TypeScript品質・型安全性
  - API設計原則

- **cost-optimization.mdc** (`alwaysApply: auto`)
  - 70-80%コスト削減戦略
  - キャッシュ階層化
  - 緊急対応手順

- **airtable-integration.mdc** (`alwaysApply: manual`)
  - filterByFormula活用パターン
  - StaticDataService設計
  - エラーハンドリング

#### **Supabase Rules** (`supabase/`)
- **generator.mdc** (`alwaysApply: auto`)
  - PostgreSQL関数設計
  - RPC型安全実装
  - リアルタイム機能

- **security.mdc** (`alwaysApply: manual`)
  - Row Level Security設計
  - Firebase Auth統合
  - GDPR準拠データ削除

#### **System Documentation Rules** (`system-doc/`)
- **requirements-design.mdc** (`alwaysApply: auto`)
  - 要件定義テンプレート
  - API仕様書規約
  - ドキュメント品質基準

## 🚀 Usage Examples

### 日常的な開発作業
```bash
# Flutter開発時 - 自動適用される
- generator.mdc: Riverpod pattern guidance
- quality.mdc: Test and script enforcement
- base-principles.mdc: Clean Architecture adherence

# Firebase Functions開発時 - 自動適用される  
- generator.mdc: 4-layer Clean Architecture
- cost-optimization.mdc: Memory and caching optimization
- base-principles.mdc: Security and error handling
```

### 特定作業時の手動適用
```bash
# パフォーマンス最適化作業時
- flutter/performance.mdc: Memory management patterns
- firebase/cost-optimization.mdc: Cost reduction strategies

# セキュリティ強化作業時
- common/security-auth.mdc: Authentication patterns
- supabase/security.mdc: RLS and data protection

# Airtable統合作業時
- firebase/airtable-integration.mdc: Server-side filtering
```

## 🔄 Rule Updates and Maintenance

### 定期的な見直し
- **月次**: ルール適用状況とコード品質の関係分析
- **四半期**: 新機能・技術変更に伴うルール更新
- **年次**: アーキテクチャ進化に合わせた大幅見直し

### ルール改善プロセス
1. **効果測定**: コード品質メトリクスでルール効果を定量化
2. **フィードバック収集**: 開発者からの使用感・改善提案
3. **ルール調整**: 実際の開発フローに合わせた微調整
4. **ドキュメント更新**: 変更内容の記録と共有

## 📝 Rule Customization

### プロジェクト固有ルールの追加
```bash
# 新しいルールファイルの作成例
.cursor/rules/common/project-specific.mdc
.cursor/rules/flutter/ui-component-patterns.mdc
.cursor/rules/firebase/third-party-integrations.mdc
```

### 既存ルールのカスタマイズ
- **除外設定**: 特定のファイル・ディレクトリをルール適用対象外に
- **重要度調整**: プロジェクトの優先度に合わせたルール重み付け
- **適用タイミング**: `alwaysApply`設定の個別調整

---

**ルール管理方針**: 開発効率と品質向上の両立を目指し、実際の開発フローに適応するルール運用を継続します。定期的な効果測定と改善を通じて、プロジェクトの成長に貢献するルールセットを維持してください。