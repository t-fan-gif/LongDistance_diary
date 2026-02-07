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
import '../settings/settings_screen.dart';
import '../settings/advanced_settings_screen.dart';
import '../../core/services/service_providers.dart'; // vdotCalculatorProvider, loadCalculatorProvider はここから取得

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

// LoadCalculatorのプロバイダは service_providers.dart で定義済み

/// CapacityEstimatorのプロバイダ
final capacityEstimatorProvider = Provider<CapacityEstimator>((ref) {
  return CapacityEstimator();
});

/// HeatmapScalerのプロバイダ
final heatmapScalerProvider = Provider<HeatmapScaler>((ref) {
  return HeatmapScaler();
});

// VdotCalculatorのプロバイダは service_providers.dart で定義済み

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
    this.maxLoadSession,
  });

  final DateTime date;
  final List<Session> sessions;
  final List<Plan> plans;
  final int dayLoad;
  final int totalDistanceM;
  final double loadRatio;
  final int heatmapBucket;
  final Session? maxLoadSession;

}

/// 月のカレンダーデータを取得するプロバイダ
final monthCalendarDataProvider =
    FutureProvider.family<List<DayCalendarData>, DateTime>((ref, month) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final planRepo = ref.watch(planRepositoryProvider);
  final loadCalc = ref.watch(loadCalculatorProvider);
  final capacityEst = ref.watch(capacityEstimatorProvider);
  final heatmapScaler = ref.watch(heatmapScalerProvider);
  final loadMode = ref.watch(loadCalculationModeProvider);
  
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
    final tPace = session.activityType == ActivityType.walking ? walkingTpace : runningTpace;
    // 常に計算モードに応じて再計算（計算できない場合は保存値を使用）
    final calculatedLoad = loadCalc.computeSessionRepresentativeLoad(
      session,
      thresholdPaceSecPerKm: tPace,
      mode: loadMode,
    );
    final load = calculatedLoad?.toDouble() ?? session.load ?? 0;
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
    Session? maxSession;
    int maxLoad = -1;

    for (final s in daySessions) {
      if (s.status == SessionStatus.skipped) continue;
      final tPace = s.activityType == ActivityType.walking ? walkingTpace : runningTpace;
      // 常に計算モードに応じて再計算
      final loadValue = loadCalc.computeSessionRepresentativeLoad(
        s,
        thresholdPaceSecPerKm: tPace,
        mode: loadMode,
      ) ?? 0;
      
      dayLoad += loadValue.toDouble();
      
      if (loadValue > maxLoad) {
        maxLoad = loadValue;
        maxSession = s;
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
    final loadRatio = capacityEst.computeLoadRatio(dayLoad.round(), dayCapacity, mode: loadMode);
    final bucket = heatmapScaler.bucketize(loadRatio);

    result.add(DayCalendarData(
      date: date,
      sessions: daySessions,
      plans: dayPlans,
      dayLoad: dayLoad.round(),
      totalDistanceM: totalDistanceM,
      loadRatio: loadRatio,
      heatmapBucket: bucket,
      maxLoadSession: maxSession,
    ));
  }

  return result;
});

DateTime _normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
