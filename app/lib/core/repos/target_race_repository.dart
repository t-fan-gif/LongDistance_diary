import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/db_providers.dart';
import '../domain/enums.dart'; // 追加

final targetRaceRepositoryProvider = Provider<TargetRaceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TargetRaceRepository(db);
});

/// ターゲットレースのリポジトリ
class TargetRaceRepository {
  TargetRaceRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 全てのターゲットレースを取得（日付順）
  Future<List<TargetRace>> listAllRaces() async {
    return (_db.select(_db.targetRaces)
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// メインターゲットを取得（日付順）
  Future<List<TargetRace>> getMainRaces() async {
    return (_db.select(_db.targetRaces)
          ..where((t) => t.isMain.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// サブターゲットのみ取得（日付順）
  Future<List<TargetRace>> getSubRaces() async {
    return (_db.select(_db.targetRaces)
          ..where((t) => t.isMain.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// 未来のレースのみ取得（今日以降、日付順）
  Future<List<TargetRace>> getUpcomingRaces() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (_db.select(_db.targetRaces)
          ..where((t) => t.date.isBiggerOrEqualValue(today))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// 指定日のレースを取得
  Future<List<TargetRace>> getRacesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.targetRaces)
          ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerThanValue(end)))
        .get();
  }

  /// 新規レースを作成
  Future<void> createRace({
    required String name,
    required DateTime date,
    required bool isMain,
    String? note,
    PbEvent? raceType, // 追加
    int? distance,     // 追加 (m)
  }) async {
    await _db.into(_db.targetRaces).insert(
          TargetRacesCompanion(
            id: Value(_uuid.v4()),
            name: Value(name),
            date: Value(date),
            isMain: Value(isMain),
            note: Value(note),
            raceType: Value(raceType),
            distance: Value(distance),
          ),
        );
  }

  /// レースを更新
  Future<void> updateRace({
    required String id,
    required String name,
    required DateTime date,
    required bool isMain,
    String? note,
    PbEvent? raceType, // 追加
    int? distance,     // 追加 (m)
  }) async {
    await (_db.update(_db.targetRaces)..where((t) => t.id.equals(id))).write(
      TargetRacesCompanion(
        name: Value(name),
        date: Value(date),
        isMain: Value(isMain),
        note: Value(note),
        raceType: Value(raceType),
        distance: Value(distance),
      ),
    );
  }

  /// レースを削除
  Future<void> deleteRace(String id) async {
    await (_db.delete(_db.targetRaces)..where((t) => t.id.equals(id))).go();
  }
}
