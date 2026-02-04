import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../domain/enums.dart';

/// Session（実績）のCRUD操作を行うリポジトリ
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 新規Sessionを作成
  Future<String> createSession({
    required DateTime startedAt,
    required String templateText,
    required SessionStatus status,
    String? planId,
    int? distanceMainM,
    int? durationMainSec,
    int? paceSecPerKm,
    Zone? zone,
    int? rpeValue,
    RestType? restType,
    int? restDurationSec,
    int? restDistanceM,
    int? wuDistanceM,
    int? wuDurationSec,
    int? cdDistanceM,
    int? cdDurationSec,
    String? note,
    double? load,
    int? repLoad,
    ActivityType activityType = ActivityType.running,
    bool isRace = false, // 追加
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.sessions).insert(
      SessionsCompanion.insert(
        id: id,
        startedAt: startedAt,
        templateText: templateText,
        status: status,
        planId: Value(planId),
        distanceMainM: Value(distanceMainM),
        durationMainSec: Value(durationMainSec),
        paceSecPerKm: Value(paceSecPerKm),
        zone: Value(zone),
        rpeValue: Value(rpeValue),
        restType: Value(restType),
        restDurationSec: Value(restDurationSec),
        restDistanceM: Value(restDistanceM),
        wuDistanceM: Value(wuDistanceM),
        wuDurationSec: Value(wuDurationSec),
        cdDistanceM: Value(cdDistanceM),
        cdDurationSec: Value(cdDurationSec),
        note: Value(note),
        load: Value(load),
        repLoad: Value(repLoad),
        activityType: Value(activityType),
        isRace: Value(isRace), // 追加
      ),
    );
    return id;
  }

  /// Sessionを更新
  Future<void> updateSession({
    required String id,
    DateTime? startedAt,
    String? templateText,
    SessionStatus? status,
    String? planId,
    int? distanceMainM,
    int? durationMainSec,
    int? paceSecPerKm,
    Zone? zone,
    int? rpeValue,
    RestType? restType,
    int? restDurationSec,
    int? restDistanceM,
    int? wuDistanceM,
    int? wuDurationSec,
    int? cdDistanceM,
    int? cdDurationSec,
    String? note,
    double? load,
    int? repLoad,
    ActivityType? activityType,
    bool? isRace, // 追加
  }) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(id))).write(
      SessionsCompanion(
        startedAt: startedAt != null ? Value(startedAt) : const Value.absent(),
        templateText: templateText != null
            ? Value(templateText)
            : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        planId: planId != null ? Value(planId) : const Value.absent(),
        distanceMainM:
            distanceMainM != null ? Value(distanceMainM) : const Value.absent(),
        durationMainSec: durationMainSec != null
            ? Value(durationMainSec)
            : const Value.absent(),
        paceSecPerKm:
            paceSecPerKm != null ? Value(paceSecPerKm) : const Value.absent(),
        zone: zone != null ? Value(zone) : const Value.absent(),
        rpeValue: rpeValue != null ? Value(rpeValue) : const Value.absent(),
        restType: restType != null ? Value(restType) : const Value.absent(),
        restDurationSec: restDurationSec != null
            ? Value(restDurationSec)
            : const Value.absent(),
        restDistanceM:
            restDistanceM != null ? Value(restDistanceM) : const Value.absent(),
        wuDistanceM:
            wuDistanceM != null ? Value(wuDistanceM) : const Value.absent(),
        wuDurationSec:
            wuDurationSec != null ? Value(wuDurationSec) : const Value.absent(),
        cdDistanceM:
            cdDistanceM != null ? Value(cdDistanceM) : const Value.absent(),
        cdDurationSec:
            cdDurationSec != null ? Value(cdDurationSec) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
        load: load != null ? Value(load) : const Value.absent(),
        repLoad: repLoad != null ? Value(repLoad) : const Value.absent(),
        activityType: activityType != null ? Value(activityType) : const Value.absent(),
        isRace: isRace != null ? Value(isRace) : const Value.absent(), // 追加
      ),
    );
  }

  /// Sessionを削除
  Future<void> deleteSession(String id) async {
    await (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();
  }

  /// 指定日のSession一覧を取得
  Future<List<Session>> listSessionsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.sessions)
          ..where(
            (t) =>
                t.startedAt.isBiggerOrEqualValue(startOfDay) &
                t.startedAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }

  /// IDでSessionを取得
  Future<Session?> getSessionById(String id) async {
    return (_db.select(_db.sessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 指定月のSession一覧を取得
  Future<List<Session>> listSessionsByMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    return (_db.select(_db.sessions)
          ..where(
            (t) =>
                t.startedAt.isBiggerOrEqualValue(startOfMonth) &
                t.startedAt.isSmallerThanValue(endOfMonth),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }

  /// 指定期間のSession一覧を取得（EWMA計算用）
  Future<List<Session>> listSessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return (_db.select(_db.sessions)
          ..where(
            (t) =>
                t.startedAt.isBiggerOrEqualValue(start) &
                t.startedAt.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
  }
}
