import 'dart:math';
import '../db/app_database.dart';
import '../domain/enums.dart';
import 'vdot_calculator.dart';
import 'load_calculator.dart';
import '../repos/session_repository.dart';

class AnalysisService {
  AnalysisService(this._vdotCalc, this._loadCalc, this._sessionRepo);

  final VdotCalculator _vdotCalc;
  final LoadCalculator _loadCalc;
  final SessionRepository _sessionRepo;

  /// 予定プランの負荷を予測する
  Future<int> predictPlanLoad(Plan plan) async {
    // すでに距離も時間もなければ負荷は0
    if ((plan.distance == null || plan.distance! <= 0) &&
        (plan.duration == null || plan.duration! <= 0)) {
        return 0;
    }

    final predictedRpe = await _predictRpe(plan);
    
    // 予測RPEを使って負荷計算
    // LoadCalculatorはSessionを受け取るが、ここではPlanから仮のSessionを作るか、
    // LoadCalculatorにPlan用のメソッドを追加するか、あるいは直接計算ロジックを呼ぶ。
    // ここでは、LoadCalculatorの既存ロジックを再利用するために、便宜上Sessionオブジェクトを作成する。
    // ただし、IDなどはダミー。
    final dummySession = Session(
      id: 'dummy',
      startedAt: plan.date,
      templateText: plan.menuName,
      status: SessionStatus.done,
      planId: plan.id,
      distanceMainM: plan.distance,
      durationMainSec: plan.duration, // plan.durationは秒単位
      paceSecPerKm: plan.pace,
      zone: plan.zone,
      rpeValue: predictedRpe,
      activityType: plan.activityType,
      isRace: plan.isRace,
      reps: plan.reps,
    );

    // 負荷計算
    // 設定された閾値ペースが必要だが、Service内で保持していないため、
    // 呼び出し元から渡すか、あるいはここではデフォルト値（またはPlanのPace）で計算する。
    // AnalysisServiceのcalculateTrendsでは引数でもらっている。
    // ここでは簡易的に、PlanのPaceがあればそれ、なければVDOTから...といきたいが、
    // ユーザー設定値を取得するにはRefが必要。
    // 一旦、LoadCalculatorのデフォルト挙動に任せるか、
    // AnalysisServiceに閾値ペースを注入する必要があるかもしれない。
    // 今回は、LoadCalculator内でデフォルト値（基準ペース）が使われることを許容する、
    // または、Paceがある場合はそのPace自体を基準として相対強度1.0として計算される（Zone係数が効く）。
    
    // thresholdPaceがnullの場合、LoadCalculatorは_basePaceSecPerKmを使う。
    // 正確には VDOT Tペースなどを渡すべきだが、非同期で取得するのが手間。
    // UI側で計算して渡す設計に変えるか？
    // -> AnalysisScreenでこれを呼ぶとき、あちらはProvider経由でTPaceを持っている。
    // メソッドの引数に追加するのが良さそう。
    return 0; // 呼び出し側で thresholdPace を渡せるようにメソッドシグネチャを変える必要があるため、修正時は注意
  }

  Future<int> predictPlanLoadWithPace(Plan plan, {int? runningThresholdPace, int? walkingThresholdPace}) async {
     // すでに距離も時間もなければ負荷は0
    if ((plan.distance == null || plan.distance! <= 0) &&
        (plan.duration == null || plan.duration! <= 0)) {
        return 0;
    }

    final predictedRpe = await _predictRpe(plan);
    
    int? durationSec = plan.duration;
    // 距離だけで時間がnullの場合、ペースがあれば時間を計算
    if ((durationSec == null || durationSec <= 0) && plan.distance != null && plan.pace != null && plan.pace! > 0) {
      durationSec = (plan.distance! / 1000.0 * plan.pace!).round();
    }

    final dummySession = Session(
      id: 'dummy',
      startedAt: plan.date,
      templateText: plan.menuName,
      status: SessionStatus.done,
      planId: plan.id,
      distanceMainM: plan.distance,
      durationMainSec: durationSec,
      paceSecPerKm: plan.pace,
      zone: plan.zone,
      rpeValue: predictedRpe.round(), // ダミーには丸めた値を入れるが...
      activityType: plan.activityType,
      isRace: plan.isRace,
      reps: plan.reps,
    );

    final tPace = plan.activityType == ActivityType.walking ? walkingThresholdPace : runningThresholdPace;
    final mode = LoadCalculationMode.priority; // 予測では標準的な計算を使う

    final load = _loadCalc.computeSessionRepresentativeLoad(
      dummySession,
      thresholdPaceSecPerKm: tPace,
      mode: mode,
      rpeOverride: predictedRpe, // 正確な値を渡す
    );

    return load ?? 0;
  }

  Future<double> _predictRpe(Plan plan) async {
    // 1. 直近のセッションを取得 (過去90日)
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    final end = now;
    
    // DBから直接クエリする機能がRepoにない場合は追加が必要だが、
    // listSessionsByDateRange はある。
    final history = await _sessionRepo.listSessionsByDateRange(start, end);
    
    // 同じActivityTypeでフィルタ
    final sameTypeSessions = history.where((s) => s.activityType == plan.activityType).toList();

    if (sameTypeSessions.isEmpty) {
      return _getDefaultRpeForZone(plan.zone);
    }

    // 2. 類似セッションを探す
    // 条件:
    // - 距離が ±20% 以内 (距離指定がある場合)
    // - ペースが ±10% 以内 (ペース指定がある場合)
    // - レストやスキップは除外
    final targetDist = plan.distance;
    final targetPace = plan.pace;

    final candidates = sameTypeSessions.where((s) {
      if (s.status == SessionStatus.skipped) return false;
      if (s.templateText == 'レスト') return false;
      if (s.rpeValue == null || s.rpeValue == 0) return false;

      bool distMatch = true;
      if (targetDist != null && targetDist > 0) {
        final sDist = s.distanceMainM ?? 0;
        if (sDist == 0) return false;
        final diff = (sDist - targetDist).abs();
        if (diff / targetDist > 0.2) distMatch = false; // 20%乖離
      }

      bool paceMatch = true;
      if (targetPace != null && targetPace > 0) {
        final sPace = s.paceSecPerKm ?? 0;
        if (sPace == 0) return false; // ペース不明なものは比較できない
        final diff = (sPace - targetPace).abs();
        if (diff / targetPace > 0.1) paceMatch = false; // 10%乖離
      }

      return distMatch && paceMatch;
    }).toList();

    if (candidates.isEmpty) {
      return _getDefaultRpeForZone(plan.zone);
    }

    // 3. 直近5件の平均RPEを採用
    // 日付降順にソート済みであることを期待（Repoの実装依存だが、listSessionsByDateRangeは昇順なので反転）
    final sorted = candidates.reversed.toList();
    final recent = sorted.take(5);
    
    final sumRpe = recent.fold<int>(0, (sum, s) => sum + s.rpeValue!);
    return sumRpe / recent.length;
  }

  double _getDefaultRpeForZone(Zone? zone) {
    if (zone == null) return 3.0; // デフォルトはE相当
    switch (zone) {
      case Zone.E: return 3.0;
      case Zone.M: return 5.0;
      case Zone.T: return 7.0;
      case Zone.I: return 8.5; 
      case Zone.R: return 10.0;
    }
  }

  /// トレーニング負荷のトレンド（CTL, ATL, TSB）を計算する
  Future<List<TrainingLoadData>> calculateTrends(List<Session> sessions, {int days = 90, int? runningThresholdPace, int? walkingThresholdPace, LoadCalculationMode mode = LoadCalculationMode.priority}) async {
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
