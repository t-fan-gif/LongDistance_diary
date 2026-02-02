import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/enums.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/repos/plan_repository.dart';
import '../../core/repos/session_repository.dart';
import '../../core/services/capacity_estimator.dart';
import '../../core/services/heatmap_scaler.dart';
import '../../core/services/load_calculator.dart';
import '../../core/services/vdot_calculator.dart';
import '../../core/repos/personal_best_repository.dart';
import '../settings/settings_screen.dart'; // personalBestRepositoryProvider is here? No, check where it is.

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

/// VdotCalculatorのプロバイダ
final vdotCalculatorProvider = Provider<VdotCalculator>((ref) {
  return VdotCalculator();
});

/// ランニングの閾値ペース(s/km)
final runningThresholdPaceProvider = FutureProvider<int?>((ref) async {
  return _getThresholdPace(ref, ActivityType.running);
});

/// 競歩の閾値ペース(s/km)
final walkingThresholdPaceProvider = FutureProvider<int?>((ref) async {
  return _getThresholdPace(ref, ActivityType.walking);
});

Future<int?> _getThresholdPace(Ref ref, ActivityType type) async {
  final pbRepo = ref.watch(personalBestRepositoryProvider);
  final vdotCalc = ref.watch(vdotCalculatorProvider);
  
  final pbs = await pbRepo.listPersonalBests();
  if (pbs.isEmpty) return null;
  
  // 指定されたアクティビティタイプのPBのみ抽出
  final filteredPbs = pbs.where((pb) => pb.activityType == type).toList();
  if (filteredPbs.isEmpty) return null;

  double maxVdot = 0;
  for (final pb in filteredPbs) {
    final dist = vdotCalc.getDistanceForEvent(pb.event);
    final vdot = vdotCalc.calculateVdot(dist, pb.timeMs ~/ 1000);
    if (vdot > maxVdot) maxVdot = vdot;
  }
  
  if (maxVdot == 0) return null;
  
  final paces = vdotCalc.calculatePaces(maxVdot);
  return paces[Zone.T]?.minSec;
}

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
    int maxLoad = -1;
    for (final session in sessions) {
      // 本来は正しい閾値ペースを渡すべきだが、ここでは比較用なので簡易的に計算
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
  
  final runningTpace = (await ref.watch(runningThresholdPaceProvider.future));
  final walkingTpace = (await ref.watch(walkingThresholdPaceProvider.future));

  // 月のセッションとプランを取得
  final sessions = await sessionRepo.listSessionsByMonth(month.year, month.month);
  final plans = await planRepo.listPlansByMonth(month.year, month.month);

  // 能力推定のため過去のセッションも取得
  final lookbackStart = DateTime(month.year, month.month - 3, 1);
  final pastSessions = await sessionRepo.listSessionsByDateRange(
    lookbackStart,
    month,
  );

  final Map<DateTime, double> dailyLoads = {};
  for (final session in [...pastSessions, ...sessions]) {
    final date = _normalizeDate(session.startedAt);
    double load = 0;
    if (session.load != null) {
      load = session.load!;
    } else {
      final tPace = session.activityType == ActivityType.walking ? walkingTpace : runningTpace;
      load = (loadCalc.computeSessionRepresentativeLoad(session, thresholdPaceSecPerKm: tPace) ?? 0).toDouble();
    }
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
    double dayLoad = 0;
    for (final s in daySessions) {
      if (s.status == SessionStatus.skipped) continue;
      if (s.load != null) {
        dayLoad += s.load!;
      } else {
        final tPace = s.activityType == ActivityType.walking ? walkingTpace : runningTpace;
        dayLoad += (loadCalc.computeSessionRepresentativeLoad(s, thresholdPaceSecPerKm: tPace) ?? 0).toDouble();
      }
    }

    // 日合計距離
    int totalDistanceM = 0;
    for (final s in daySessions) {
      if (s.status != SessionStatus.skipped) {
        totalDistanceM += s.distanceMainM ?? 0;
      }
    }

    // 負荷比率と濃淡
    final dayCapacity = capacityEst.estimateCapacityForDate(
      dailyLoads.map((k, v) => MapEntry(k, v.round())), 
      date,
    );
    final loadRatio = capacityEst.computeLoadRatio(dayLoad.round(), dayCapacity);
    final bucket = heatmapScaler.bucketize(loadRatio);

    result.add(DayCalendarData(
      date: date,
      sessions: daySessions,
      plans: dayPlans,
      dayLoad: dayLoad.round(),
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
