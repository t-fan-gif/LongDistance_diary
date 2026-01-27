# ソフトウェア方式設計（暫定）

本書はシステム設計の内部工程である「ソフトウェア方式設計」を扱う。要件は `SOFTWARE_REQUIREMENTS.md`、システム方式は `SYSTEM_DESIGN.md` を参照。

## 技術スタック（決定）
- Flutter（Android先行、将来iOS）
- ローカルDB: SQLite + `drift`
- 状態管理: `riverpod`

## レイヤ構成（推奨）
- UI層: 画面、入力コンポーネント、ルーティング
- アプリケーション層: ユースケース（Plan作成、Session登録、集計の呼び出し）
- ドメイン/サービス層: 負荷計算、EWMA等の集計ロジック
- 永続化層: drift（テーブル、クエリ、マイグレーション）

## モジュール構成（案）
- `lib/core/`
  - `db/`（drift定義、マイグレーション）
  - `domain/`（値オブジェクト、列挙、共通ロジック）
  - `services/`（負荷計算、EWMA等）
  - `repos/`（Plan/Session/PBのリポジトリ）
- `lib/features/`
  - `calendar/`（月表示、濃淡、日詳細導線）
  - `day_detail/`（日単位の一覧と合計）
  - `plan_editor/`（予定作成/編集）
  - `session_editor/`（実績入力/編集）
  - `settings/`（PB、表示設定、エクスポート）

## 主要データモデル（概要）
詳細なテーブル/制約は `SOFTWARE_DETAILED_DESIGN.md` に記載する。

- `PersonalBest`
  - `event`（800/1500/3000/3000SC/5000/10000/HM/Full）
  - `timeMs`、`date?`、`note?`
- `Plan`
  - `date`、`template`（距離or時間 + 強度）、`note?`
- `Session`
  - `dateTime`（決定: 1日複数を許容するため日時で保持）
  - `planId?`（予定なし実績も許容）
  - `distanceMain?` / `durationMain?`（距離または時間）
  - `paceSecPerKm?`（単一入力）
  - `zone?`（E/M/T/I/R）
  - `rpe?`（絵文字選択→内部値）
  - `restType?`/`restDurationSec?`/`restDistanceM?`
  - `wu*`/`cd*`（任意、MVPでは分析必須にしない）
  - `status`（planned/done/partial/aborted/skipped）

## 集計パイプライン（カレンダー濃淡）
- 入力: 日ごとの代表負荷（その日の全セッション代表負荷の合計）
- 能力推定: 直近負荷推移から推定（例: EWMA 42日）
- 出力: 相対値（当日の負荷 / 能力）を段階化して濃淡に変換
- 代表負荷の算出優先順位は `SOFTWARE_REQUIREMENTS.md` の決定に従う

## 設計上の未決事項（後で確定）
## 方式上の決定（MVP）
### ルーティング
- 決定: `go_router` を採用する（画面遷移と戻る挙動を宣言的に管理し、将来のDeep Linkにも備える）。

### ID方式
- 決定: UUID（文字列）を採用する。
  - 根拠: 将来の端末間移行/同期に備えつつ、ローカル生成で衝突しにくい。

### エクスポート/インポート
- 決定: JSONのみ（`SYSTEM_DESIGN.md` に準拠）。
- 範囲: Session / Plan / PB / 最低限の設定（`SYSTEM_DESIGN.md` に準拠）。
- 暗号化: MVPでは必須にしない（必要になったら追加）。

## 完了条件チェックリスト
- [x] レイヤ（UI/アプリケーション/ドメイン/永続化）の責務が説明されている
- [x] モジュール分割（`lib/core`/`lib/features`）が要件と対応している
- [x] 集計パイプライン（代表負荷→日負荷→能力推定→濃淡）が説明されている
- [x] 未決事項が列挙され、決める場所（方式or詳細or運用）が分かる
