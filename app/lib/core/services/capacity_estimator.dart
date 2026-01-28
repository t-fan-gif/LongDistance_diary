/// 能力（キャパシティ）推定を行うサービス
/// 
/// 直近の負荷推移からEWMA（指数加重移動平均）で能力を推定する
class CapacityEstimator {
  /// デフォルトの減衰日数（42日）
  static const int defaultTauDays = 42;

  /// EWMA（指数加重移動平均）で能力を推定
  /// 
  /// [dayLoads] : 日付順（古い→新しい）の日負荷リスト
  /// [tauDays] : 減衰定数（日数）。大きいほど過去のデータを重視
  /// 
  /// EWMA計算式: 
  /// α = 2 / (tauDays + 1)
  /// EWMA[0] = dayLoads[0]
  /// EWMA[t] = α × dayLoads[t] + (1 - α) × EWMA[t-1]
  double computeEwma(List<int> dayLoads, {int tauDays = defaultTauDays}) {
    if (dayLoads.isEmpty) {
      return 0.0;
    }

    final alpha = 2.0 / (tauDays + 1);
    double ewma = dayLoads.first.toDouble();

    for (int i = 1; i < dayLoads.length; i++) {
      ewma = alpha * dayLoads[i] + (1 - alpha) * ewma;
    }

    return ewma;
  }

  /// 当日負荷と能力の相対値を計算
  /// 
  /// ゼロ除算を防ぐためepsilon（0.01）を使用
  double computeLoadRatio(int dayLoad, double capacity) {
    const epsilon = 0.01;
    // ゼロ除算およびデータ不足時の異常値を防ぐ
    // 基準値(60.0)未満の場合は、評価に十分な履歴がないとみなし比率0（評価なし/グレー）とする
    // 1時間E走(180)を週数回行うレベルが定着するまでは評価を保留する
    if (capacity < 60.0) {
      return 0.0;
    }
    return dayLoad / capacity;
  }

  /// 日ごとの負荷マップから指定日の能力を推定
  /// 
  /// [dailyLoads] : 日付をキー、負荷を値とするマップ
  /// [targetDate] : 能力を推定したい日付
  /// [lookbackDays] : 遡る日数（デフォルトは2×tau）
  double estimateCapacityForDate(
    Map<DateTime, int> dailyLoads,
    DateTime targetDate, {
    int? lookbackDays,
    int tauDays = defaultTauDays,
  }) {
    lookbackDays ??= tauDays * 2;

    // targetDateより前のデータを取得（古い順）
    final List<int> loads = [];
    for (int i = lookbackDays; i > 0; i--) {
      final date = DateTime(
        targetDate.year,
        targetDate.month,
        targetDate.day - i,
      );
      loads.add(dailyLoads[_normalizeDate(date)] ?? 0);
    }

    return computeEwma(loads, tauDays: tauDays);
  }

  /// 日付を正規化（時刻部分を除去）
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
