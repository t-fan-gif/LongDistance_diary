# ソフトウェア詳細設計（暫定）

本書はシステム設計の内部工程である「ソフトウェア詳細設計」を扱う。方式設計は `SOFTWARE_ARCHITECTURE.md`、要件は `SOFTWARE_REQUIREMENTS.md` を参照。

## DB設計（drift / SQLite）
### テーブル（案）
- `personal_bests`
  - `id`（PK）
  - `event`（enum）
  - `time_ms`（int）
  - `date`（date, nullable）
  - `note`（text, nullable）
- `plans`
  - `id`（PK）
  - `date`（date）
  - `template_text`（text）
  - `note`（text, nullable）
- `sessions`
  - `id`（PK）
  - `date_time`（datetime）
  - `plan_id`（FK, nullable）
  - `template_text`（text）
  - `distance_main_m`（int, nullable）
  - `duration_main_sec`（int, nullable）
  - `pace_sec_per_km`（int, nullable）
  - `zone`（enum, nullable）
  - `rpe_value`（int, nullable）
  - `rest_type`（enum, nullable）
  - `rest_duration_sec`（int, nullable）
  - `rest_distance_m`（int, nullable）
  - `wu_distance_m`（int, nullable）
  - `wu_duration_sec`（int, nullable）
  - `cd_distance_m`（int, nullable）
  - `cd_duration_sec`（int, nullable）
  - `status`（enum）
  - `note`（text, nullable）

### 制約（案）
- `sessions` は `distance_main_m` と `duration_main_sec` のどちらか（または両方）を許容するが、MVPの入力導線では「距離または時間」の片方を基本とする。
- `rest_type` が `jog` の場合のみ `rest_distance_m` を任意入力として表示する（値はnullable）。

### インデックス（案）
- `sessions(date_time)`（月表示/日集計の高速化）
- `sessions(plan_id)`（テンプレ比較/予定→実績の追跡）

## 入力仕様（UI→内部表現）
### ペース入力（単一）
- UI入力は1フィールドで受け付ける。
  - 例: `430` → `4:30/km`
  - 例: `4:30` → `4:30/km`
- 内部表現は `pace_sec_per_km`（int）で保持する。

### RPE（絵文字スライド）
- 数値入力は要求しない。
- 内部表現は `rpe_value`（0-10想定）で保持する。
- 絵文字/ラベルと `rpe_value` の対応は運用しながら調整可能にする（設定化は将来）。

### レスト
- `rest_duration_sec` は基本入力（クイックボタン＋微調整）。
- `rest_type` は `stop` / `jog`。
- `jog` の場合のみ `rest_distance_m` を任意入力（例: 200m）。

### WU/CD
- UI入力欄は用意するが、MVPでは負荷計算や統計の必須入力にしない。

## 負荷計算（代表負荷）
代表負荷の優先順位は `SOFTWARE_REQUIREMENTS.md` の決定に従う。

### セッション代表負荷（例: 実装用の関数分割）
- `computePaceLoad(session)`（rTSS風）
- `computeSrpeLoad(session)`（sRPE）
- `computeZoneLoad(session)`（暫定）
- `computeSessionRepresentativeLoad(session)`（優先順位で選択）

### 日単位代表負荷
- `computeDayLoad(date)` = `sum(computeSessionRepresentativeLoad(session in day))`
- カレンダー表示は「最大負荷の1件」＋「件数バッジ」、濃淡は日合計を使用（案A）。

### 濃淡（相対化）
- 能力推定（例）: `capacity[d] = ewma(day_load, tau=42d)`
- 相対値: `ratio = day_load / max(capacity, epsilon)`
- 段階化（例）: 閾値は運用で調整（固定/分位のどちらも検討余地）

## エクスポート（設計方針）
- DBスキーマバージョンを持ち、JSONに `schema_version` を含める。
- MVPは「読み出し（エクスポート）」から着手できるようにする。

