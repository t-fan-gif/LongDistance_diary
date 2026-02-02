import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../domain/enums.dart';

/// PersonalBest（自己ベスト）のCRUD操作を行うリポジトリ
class PersonalBestRepository {
  PersonalBestRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// PBを作成または更新（同一種目なら上書き）
  Future<String> upsertPersonalBest({
    required PbEvent event,
    required int timeMs,
    ActivityType activityType = ActivityType.running,
    DateTime? date,
    String? note,
  }) async {
    // 既存のPBを検索
    final existing = await (_db.select(_db.personalBests)
          ..where((t) => t.event.equalsValue(event)))
        .getSingleOrNull();

    if (existing != null) {
      // 更新
      await (_db.update(_db.personalBests)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        PersonalBestsCompanion(
          timeMs: Value(timeMs),
          activityType: Value(activityType),
          date: Value(date),
          note: Value(note),
        ),
      );
      return existing.id;
    } else {
      // 新規作成
      final id = _uuid.v4();
      await _db.into(_db.personalBests).insert(
        PersonalBestsCompanion.insert(
          id: id,
          event: event,
          timeMs: timeMs,
          activityType: Value(activityType),
          date: Value(date),
          note: Value(note),
        ),
      );
      return id;
    }
  }

  /// 全PBを取得
  Future<List<PersonalBest>> listPersonalBests() async {
    return _db.select(_db.personalBests).get();
  }

  /// 特定種目のPBを取得
  Future<PersonalBest?> getPersonalBestByEvent(PbEvent event) async {
    return (_db.select(_db.personalBests)
          ..where((t) => t.event.equalsValue(event)))
        .getSingleOrNull();
  }

  /// PBを削除
  Future<void> deletePersonalBest(String id) async {
    await (_db.delete(_db.personalBests)..where((t) => t.id.equals(id))).go();
  }
}
