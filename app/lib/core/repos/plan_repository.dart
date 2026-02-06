import 'dart:developer' as dev;
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../domain/enums.dart';

/// Plan（予定）のCRUD操作を行うリポジトリ
class PlanRepository {
  PlanRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  /// 指定日のPlanを一括更新（全削除して再作成）
  Future<void> updatePlansForDate(DateTime date, List<PlanInput> inputs) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    dev.log('[PlanRepo] updatePlansForDate: date=$startOfDay, count=${inputs.length}');

    try {
      await _db.transaction(() async {
        dev.log('[PlanRepo] Transaction started');
        
        // 指定日の既存Planを削除
        final deleted = await (_db.delete(_db.plans)
              ..where((t) =>
                  t.date.isBiggerOrEqualValue(startOfDay) &
                  t.date.isSmallerThanValue(endOfDay)))
            .go();
        dev.log('[PlanRepo] Deleted $deleted existing plans');

        // 新しいPlanを一括登録
        for (final input in inputs) {
          dev.log('[PlanRepo] Inserting plan: ${input.menuName}, dist=${input.distance}, reps=${input.reps}');
          await _db.into(_db.plans).insert(
                PlansCompanion.insert(
                  id: _uuid.v4(),
                  date: startOfDay, // 時間情報は切り捨てて日付だけで管理
                  menuName: input.menuName,
                  distance: Value(input.distance),
                  pace: Value(input.pace),
                  zone: Value(input.zone),
                  reps: Value(input.reps),
                  note: Value(input.note),
                  activityType: Value(input.activityType),
                  isRace: Value(input.isRace),
                  duration: Value(input.duration), // 追加
                ),
              );
        }
        dev.log('[PlanRepo] Insert loop completed');
      });
      dev.log('[PlanRepo] Transaction committed successfully');
    } catch (e, st) {
      dev.log('[PlanRepo] Error in updatePlansForDate', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// 指定日のメモを取得
  Future<DailyPlanMemo?> getDailyMemo(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return (_db.select(_db.dailyPlanMemos)..where((t) => t.date.equals(startOfDay))).getSingleOrNull();
  }

  /// 指定日のメモを更新
  Future<void> updateDailyMemo(DateTime date, String note) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    if (note.isEmpty) {
      await (_db.delete(_db.dailyPlanMemos)..where((t) => t.date.equals(startOfDay))).go();
      return;
    }
    await _db.into(_db.dailyPlanMemos).insertOnConflictUpdate(
          DailyPlanMemosCompanion.insert(
            date: startOfDay,
            note: note,
          ),
        );
  }

  /// 指定日のPlan一覧を取得（日付の日部分で抽出）
  Future<List<Plan>> listPlansByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.plans)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(startOfDay) &
                t.date.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)])) // 作成順(ID順ではないので注意が必要だが、DriftのRowId順になるか？ DateTimeが同じ場合不定になるかも。本来はSortOrderカラムがあると良いが、今回は簡易的に)
        .get();
  }

  /// 指定月のPlan一覧を取得
  Future<List<Plan>> listPlansByMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);

    return (_db.select(_db.plans)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(startOfMonth) &
                t.date.isSmallerThanValue(endOfMonth),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }
}

/// Plan作成・更新用の入力データ
class PlanInput {
  const PlanInput({
    required this.menuName,
    this.distance,
    this.pace,
    this.zone,
    this.reps = 1,
    this.note,
    this.activityType = ActivityType.running,
    this.isRace = false,
    this.duration, // 追加
  });

  final String menuName;
  final int? distance;
  final int? pace;
  final Zone? zone;
  final int reps;
  final String? note;
  final ActivityType activityType;
  final bool isRace;
  final int? duration; // 追加
}
