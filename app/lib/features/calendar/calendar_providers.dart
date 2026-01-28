import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/enums.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/repos/plan_repository.dart';
import '../../core/repos/session_repository.dart';
import '../../core/services/capacity_estimator.dart';
import '../../core/services/heatmap_scaler.dart';
import '../../core/services/load_calculator.dart';

/// 現在表示中の年月
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// PlanRepositoryのプロバイダ
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlanRepository(db);
});

/// SessionRepositoryのプロバイダ
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionRepository(db);
});

/// LoadCalculatorのプロバイダ
final loadCalculatorProvider = Provider<LoadCalculator>((ref) {
  return LoadCalculator();
});

/// CapacityEstimatorのプロバイダ
final capacityEstimatorProvider = Provider<CapacityEstimator>((ref) {
  return CapacityEstimator();
});

/// HeatmapScalerのプロバイダ
final heatmapScalerProvider = Provider<HeatmapScaler>((ref) {
  return HeatmapScaler();
});

/// 1日分のカレンダーデータ
class DayCalendarData {
  DayCalendarData({
    required this.date,
    required this.sessions,
    required this.plans,
    required this.dayLoad,
    required this.totalDistanceM,
    required this.loadRatio,
    required this.heatmapBucket,
  });

  final DateTime date;
  final List<Session> sessions;
  final List<Plan> plans;
  final int dayLoad;
  final int totalDistanceM;
  final double loadRatio;
  final int heatmapBucket;

  /// セッション数
  int get sessionCount => sessions.length;

  /// 予定数
  int get planCount => plans.length;

  /// 最大負荷のセッション
  Session? get maxLoadSession {
    if (sessions.isEmpty) return null;
    final loadCalc = LoadCalculator();
    Session? maxSession;
    int maxLoad = 0;
    for (final session in sessions) {
      final load = loadCalc.computeSessionRepresentativeLoad(session) ?? 0;
      if (load > maxLoad) {
        maxLoad = load;
        maxSession = session;
      }
    }
    return maxSession;
  }
}

/// 月のカレンダーデータを取得するプロバイダ
final monthCalendarDataProvider =
    FutureProvider.family<List<DayCalendarData>, DateTime>((ref, month) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final planRepo = ref.watch(planRepositoryProvider);
  final loadCalc = ref.watch(loadCalculatorProvider);
  final capacityEst = ref.watch(capacityEstimatorProvider);
  final heatmapScaler = ref.watch(heatmapScalerProvider);

  // 月のセッションとプランを取得
  final sessions = await sessionRepo.listSessionsByMonth(month.year, month.month);
  final plans = await planRepo.listPlansByMonth(month.year, month.month);

  // 能力推定のため過去のセッションも取得
  final lookbackStart = DateTime(month.year, month.month - 3, 1);
  final pastSessions = await sessionRepo.listSessionsByDateRange(
    lookbackStart,
    month,
  );

  // 日ごとの負荷マップを作成
  final Map<DateTime, int> dailyLoads = {};
  for (final session in [...pastSessions, ...sessions]) {
    final date = _normalizeDate(session.startedAt);
    final load = loadCalc.computeSessionRepresentativeLoad(session) ?? 0;
    dailyLoads[date] = (dailyLoads[date] ?? 0) + load;
  }

  // 月の各日のデータを作成
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final List<DayCalendarData> result = [];

  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(month.year, month.month, day);
    final normalizedDate = _normalizeDate(date);

    // その日のセッションとプラン
    final daySessions = sessions
        .where((s) => _normalizeDate(s.startedAt) == normalizedDate)
        .toList();
    final dayPlans = plans
        .where((p) => _normalizeDate(p.date) == normalizedDate)
        .toList();

    // 日負荷
    final dayLoad = loadCalc.computeDayLoad(daySessions);

    // 日合計距離
    int totalDistanceM = 0;
    for (final s in daySessions) {
      if (s.status != SessionStatus.skipped) {
        totalDistanceM += s.distanceMainM ?? 0;
      }
    }

    // 負荷比率と濃淡
    final dayCapacity = capacityEst.estimateCapacityForDate(dailyLoads, date);
    final loadRatio = capacityEst.computeLoadRatio(dayLoad, dayCapacity);
    final bucket = heatmapScaler.bucketize(loadRatio);

    result.add(DayCalendarData(
      date: date,
      sessions: daySessions,
      plans: dayPlans,
      dayLoad: dayLoad,
      totalDistanceM: totalDistanceM,
      loadRatio: loadRatio,
      heatmapBucket: bucket,
    ));
  }

  return result;
});

DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
