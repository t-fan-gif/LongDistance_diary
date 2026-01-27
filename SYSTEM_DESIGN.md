# システム設計（暫定）

本書はウォーターフォール工程の「システム設計」を扱う。要件は `SYSTEM_REQUIREMENTS.md` / `SOFTWARE_REQUIREMENTS.md` を参照。

## 全体アーキテクチャ
- クライアント: Flutter（Androidを先行、将来iOS対応）
- 動作方針: offline-first（端末内で記録・閲覧・集計が完結）
- 構成: UI（画面）→ 状態管理 → リポジトリ → ローカルDB

## 技術選定（推奨）
### 決定
- ローカルDB: SQLite + `drift`
- 状態管理: `riverpod`

### 補足（なぜ必要か）
- SQLite: 端末内で「構造化された記録（Plan/Session/PB）」を永続化し、検索・集計（週負荷/移動平均/強度分布など）を安定して行うための土台。
- drift: SQLiteをFlutterから扱いやすくし、型安全なクエリとスキーマ更新（マイグレーション）を提供するために使う。
- riverpod: 画面（UI）とデータ取得/計算（DB・負荷計算）を分離し、依存関係のある画面（カレンダー→日詳細→編集）の更新を安全に行うために使う。

## モジュール構成（案）
- `lib/core/`
  - `db/`（drift定義、マイグレーション）
  - `models/`（ドメインモデル）
  - `services/`（負荷計算、EWMA等の集計ロジック）
- `lib/features/`
  - `calendar/`（月表示、濃淡、日詳細への導線）
  - `plan/`（予定作成/編集）
  - `session/`（実績入力/編集）
  - `settings/`（PB入力、表示設定）

## 主要画面（高レベル）
- カレンダー（月）
  - 日セル: 「最大負荷の1件」＋「件数バッジ」
  - 背景濃淡: 日単位代表負荷（合計）を能力推定で相対化した値
- 日詳細
  - その日のセッション一覧（予定/実績、負荷内訳）
  - 追加/編集への導線
- 予定作成（Plan）
- 実績入力（Session）
- 設定（PB、濃淡スケールの設定、エクスポート等）

## データモデル（概要）
- `PersonalBest`
  - `event`（800/1500/3000/3000SC/5000/10000/HM/Full）
  - `timeMs`、`date?`、`note?`
- `Plan`
  - `date`、`template`（距離or時間 + 強度）、`note?`
- `Session`
  - `dateTime`（決定: 1日複数を許容するため日時で保持。日付単位の集計は`dateTime`から切り出す）
  - `planId?`
  - `template`（Planから複製可）
  - `distanceMain?` / `durationMain?`（距離または時間）
  - `paceSecPerKm?`（単一入力）
  - `zone?`（E/M/T/I/R）
  - `rpe?`（絵文字選択→内部値）
  - `restType?`（stop/jog）、`restDurationSec?`、`restDistanceM?`
  - `wuDistance?`/`wuDuration?`、`cdDistance?`/`cdDuration?`（MVPでは分析必須にしない）
  - `status`（planned/done/partial/aborted/skipped）
  - `note?`

## 負荷計算（代表負荷）
- セッション代表負荷（優先順位は `SOFTWARE_REQUIREMENTS.md` の決定に従う）
  1) ペース+距離or時間: ペース由来負荷（rTSS風）
  2) RPE+時間: sRPE（RPE×時間）
  3) ゾーン+時間: ゾーン係数×時間（暫定）
- 日単位代表負荷: その日の全セッション代表負荷の合計
- 濃淡: 直近負荷推移から能力を推定（例: EWMA 42日）し、比率で相対化（閾値は運用で調整）

## データ保全（設計方針）
- エクスポート/インポートを想定し、DBスキーマはバージョン管理する。
- MVPでは「JSONエクスポート（読み取り専用でも可）」から着手できるようにする。
