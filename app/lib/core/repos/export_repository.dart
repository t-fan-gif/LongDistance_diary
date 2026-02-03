import 'dart:convert';

import '../db/app_database.dart';

/// データエクスポートのためのリポジトリ
class ExportRepository {
  ExportRepository(this._db);

  final AppDatabase _db;

  /// 全データをJSON文字列として取得する
  Future<String> exportToJson() async {
    // 全データ取得
    final plans = await _db.select(_db.plans).get();
    final sessions = await _db.select(_db.sessions).get();
    final personalBests = await _db.select(_db.personalBests).get();
    final menuPresets = await _db.select(_db.menuPresets).get();
    final memos = await _db.select(_db.dailyPlanMemos).get();

    // マップ化
    final data = {
      'schema_version': 2,
      'exported_at': DateTime.now().toIso8601String(),
      'plans': plans.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'personal_bests': personalBests.map((e) => e.toJson()).toList(),
      'menu_presets': menuPresets.map((e) => e.toJson()).toList(),
      'daily_plan_memos': memos.map((e) => e.toJson()).toList(),
      'settings': {},
    };

    // JSONエンコード（インデント付きで見やすく）
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// JSONデータからデータをインポート（マージ）する
  Future<void> importFromJson(String jsonString) async {
    final Map<String, dynamic> data = json.decode(jsonString);

    await _db.transaction(() async {
      // インポート処理（既存データは消さず、ID重複のみ上書き）MODE: insertOrReplace

      if (data['plans'] != null) {
        for (final item in data['plans']) {
          await _db.into(_db.plans).insertOnConflictUpdate(Plan.fromJson(item));
        }
      }
      if (data['sessions'] != null) {
        for (final item in data['sessions']) {
          await _db.into(_db.sessions).insertOnConflictUpdate(Session.fromJson(item));
        }
      }
      if (data['personal_bests'] != null) {
        for (final item in data['personal_bests']) {
          await _db.into(_db.personalBests).insertOnConflictUpdate(PersonalBest.fromJson(item));
        }
      }
      if (data['menu_presets'] != null) {
        for (final item in data['menu_presets']) {
          await _db.into(_db.menuPresets).insertOnConflictUpdate(MenuPreset.fromJson(item));
        }
      }
      if (data['daily_plan_memos'] != null) {
        for (final item in data['daily_plan_memos']) {
          await _db.into(_db.dailyPlanMemos).insertOnConflictUpdate(DailyPlanMemo.fromJson(item));
        }
      }
    });
  }

  /// 全データを初期化する
  Future<void> resetData() async {
    await _db.transaction(() async {
      await _db.delete(_db.plans).go();
      await _db.delete(_db.sessions).go();
      await _db.delete(_db.personalBests).go();
      await _db.delete(_db.menuPresets).go();
    });
  }
}
