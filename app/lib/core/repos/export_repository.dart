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

    // マップ化
    final data = {
      'schema_version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'plans': plans.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'personal_bests': personalBests.map((e) => e.toJson()).toList(),
      'settings': {}, // 現状設定項目はないが枠だけ確保
    };

    // JSONエンコード（インデント付きで見やすく）
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// JSONデータから全データを復元する
  Future<void> importFromJson(String jsonString) async {
    final Map<String, dynamic> data = json.decode(jsonString);

    await _db.transaction(() async {
      // 既存データを削除
      await _db.delete(_db.plans).go();
      await _db.delete(_db.sessions).go();
      await _db.delete(_db.personalBests).go();
      await _db.delete(_db.menuPresets).go();

      // インポート処理
      if (data['plans'] != null) {
        for (final item in data['plans']) {
          await _db.into(_db.plans).insert(Plan.fromJson(item));
        }
      }
      if (data['sessions'] != null) {
        for (final item in data['sessions']) {
          await _db.into(_db.sessions).insert(Session.fromJson(item));
        }
      }
      if (data['personal_bests'] != null) {
        for (final item in data['personal_bests']) {
          await _db.into(_db.personalBests).insert(PersonalBest.fromJson(item));
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
