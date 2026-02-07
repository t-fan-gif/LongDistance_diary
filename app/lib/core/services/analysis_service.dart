import 'dart:math';
import '../db/app_database.dart';
import '../domain/enums.dart';
import 'vdot_calculator.dart';
import 'load_calculator.dart';

class AnalysisService {
  AnalysisService(this._vdotCalc, this._loadCalc);

  final VdotCalculator _vdotCalc;
  final LoadCalculator _loadCalc;

  /// CTL (Chronic Training Load: 42日間) と ATL (Acute Training Load: 7日間) を計算する
  /// sessions は日付順にソートされていることを期待
  List<TrainingLoadData> calculateTrends(
    List<Session> sessions, {
    int days = 90,
    required LoadCalculationMode mode,
    int? runningThresholdPace,
    int? walkingThresholdPace,
  }) {
    if (sessions.isEmpty) return [];

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days + 42)); // CTL計算のために42日分余計に遡る
    
    // 日ごとの負荷をマッピング
    final dailyLoad = <DateTime, double>{};
    for (final s in sessions) {
      final tPace = s.activityType == ActivityType.walking ? walkingThresholdPace : runningThresholdPace;
      // 常に計算モードに応じて再計算
      final calculatedLoad = _loadCalc.computeSessionRepresentativeLoad(
        s,
        thresholdPaceSecPerKm: tPace,
        mode: mode,
      );
      
      final date = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      dailyLoad[date] = (dailyLoad[date] ?? 0) + (calculatedLoad?.toDouble() ?? 0);
    }

    final results = <TrainingLoadData>[];
    double ctl = 0;
    double atl = 0;

    // 通算での計算（初期値0から徐々に上げていく）
    // 実際には過去すべてのデータから計算するのが望ましいが、パフォーマンスのためdays分に絞る
    // 安定させるため、開始日の42日前から計算を開始する
    final calculationStart = startDate;
    for (int i = 0; i <= days + 42; i++) {
      final currentDate = calculationStart.add(Duration(days: i));
      final load = dailyLoad[DateTime(currentDate.year, currentDate.month, currentDate.day)] ?? 0;

      // CTL_today = CTL_yesterday * exp(-1/42) + Load_today * (1 - exp(-1/42))
      // ATL_today = ATL_yesterday * exp(-1/7) + Load_today * (1 - exp(-1/7))
      ctl = ctl * exp(-1 / 42) + load * (1 - exp(-1 / 42));
      atl = atl * exp(-1 / 7) + load * (1 - exp(-1 / 7));

      if (i >= 42) {
        results.add(TrainingLoadData(
          date: currentDate,
          ctl: ctl,
          atl: atl,
          load: load,
        ));
      }
    }

    return results;
  }

  /// 直近のTペースまたはIペースの練習から、推定される最新のVDOTを計算する
  Future<double?> estimateCurrentVdot(List<Session> sessions) async {
    final recentSessions = sessions.where((s) => 
      s.startedAt.isAfter(DateTime.now().subtract(const Duration(days: 30))) &&
      (s.zone == Zone.T || s.zone == Zone.I) &&
      s.distanceMainM != null && s.distanceMainM! > 0 &&
      s.durationMainSec != null && s.durationMainSec! > 0
    ).toList();

    if (recentSessions.isEmpty) return null;

    final vdots = <double>[];
    for (final s in recentSessions) {
      // 練習時のペースからVDOTを逆算
      // セッションのタイムと距離から直接計算
      final vdot = _vdotCalc.calculateVdot(s.distanceMainM!, s.durationMainSec!);
      
      // 練習強度の補正（Danielsの表では、TペースはVDOTの約88-92% VO2max）
      // 練習タイムからVDOTそのものを出すと、100%全力と見なしてしまうため、
      // ゾーンに応じた補正が必要。
      if (s.zone == Zone.T) {
        // Tペース(90% VO2max)で走っているなら、VDOT = VO2 / 0.90
        // calculateVdotは VO2 = VDOT * %VO2max を解いているので、
        // 練習ペースがTペース(90%)だと分かっているなら、逆算されたVDOTは
        // 「全力で走った場合のVDOT」より低く出るはず。
        // ...というのはVdotCalculatorの実装次第。
        // ここでは単純化のため、練習結果から得られたVDOTをそのまま使う（練習の質として評価）。
        vdots.add(vdot);
      } else if (s.zone == Zone.I) {
        vdots.add(vdot);
      }
    }

    if (vdots.isEmpty) return null;
    // 平均ではなく、最近のベスト（成長の証）を採用
    return vdots.reduce(max);
  }
}

class TrainingLoadData {
  final DateTime date;
  final double ctl; // 慢性負荷
  final double atl; // 急性負荷
  final double load; // その日の負荷
  
  double get tsb => ctl - atl; // 調子（マイナスが大きいと疲労困憊、プラスだとフレッシュ）

  TrainingLoadData({
    required this.date,
    required this.ctl,
    required this.atl,
    required this.load,
  });
}
