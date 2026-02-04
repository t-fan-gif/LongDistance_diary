import 'dart:convert';

import 'package:drift/drift.dart';

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
    final targetRaces = await _db.select(_db.targetRaces).get();

    // マップ化
    final data = {
      'schema_version': 2,
      'exported_at': DateTime.now().toIso8601String(),
      'plans': plans.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'personal_bests': personalBests.map((e) => e.toJson()).toList(),
      'menu_presets': menuPresets.map((e) => e.toJson()).toList(),
      'daily_plan_memos': memos.map((e) => e.toJson()).toList(),
      'target_races': targetRaces.map((e) => e.toJson()).toList(),
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
      if (data['target_races'] != null) {
        for (final item in data['target_races']) {
          await _db.into(_db.targetRaces).insertOnConflictUpdate(TargetRace.fromJson(item));
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

  /// 予定のみをエクスポート（日付範囲指定、ペースは除去しゾーンのみ保持）
  Future<String> exportPlansOnly(DateTime startDate, DateTime endDate) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));
    
    final plans = await (_db.select(_db.plans)
      ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end)))
      .get();
    
    final memos = await (_db.select(_db.dailyPlanMemos)
      ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end)))
      .get();

    // ペースを除去してゾーンのみ保持（選手PBで再計算させるため）
    final strippedPlans = plans.map((e) {
      final json = e.toJson();
      json.remove('pace_sec_per_km'); // ペースを削除
      return json;
    }).toList();

    final data = {
      'schema_version': 2,
      'type': 'plans_only',
      'exported_at': DateTime.now().toIso8601String(),
      'date_range': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'plans': strippedPlans,
      'daily_plan_memos': memos.map((e) => e.toJson()).toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }
}
