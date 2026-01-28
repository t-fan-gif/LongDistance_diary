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
}
