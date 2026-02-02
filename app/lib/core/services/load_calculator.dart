import 'dart:math';
import '../db/app_database.dart';
import '../domain/enums.dart';

/// セッションの負荷計算を行うサービス
class LoadCalculator {
  /// ペース由来負荷（rTSS風）の計算
  /// 
  /// 計算式: (距離km × ペース係数)
  /// ペース係数はペースが速いほど高くなる（BASE_PACE / 実際のペース）
  static const int _basePaceSecPerKm = 300; // 基準ペース: 5:00/km = 300秒

  /// ペース由来負荷を計算
  /// 距離とペースが必要
  /// 
  /// [thresholdPaceSecPerKm]: その日のユーザーの閾値ペース（Tペース）
  int? computePaceLoad(Session session, {int? thresholdPaceSecPerKm}) {
    final durationSec = session.durationMainSec;
    final paceSecPerKm = session.paceSecPerKm;
    final distanceM = session.distanceMainM;

    // ペースと（時間または距離）が必要
    if (paceSecPerKm == null || paceSecPerKm <= 0) return null;
    
    double durationMin;
    if (durationSec != null && durationSec > 0) {
      durationMin = durationSec / 60.0;
    } else if (distanceM != null && distanceM > 0) {
      durationMin = (distanceM / 1000.0) * paceSecPerKm / 60.0;
    } else {
      return null;
    }

    // 閾値ペースがない場合はデフォルトを使用
    final tPace = thresholdPaceSecPerKm ?? _basePaceSecPerKm;

    // 相対強度 = 閾値ペース / 実際のペース
    // 例: 閾値 4:00(240s) の人が 5:00(300s) で走る場合、強度は 240/300 = 0.8
    final intensity = tPace / paceSecPerKm;

    // 負荷 = 時間(分) × 強度^3 × 修正係数
    // 3乗にすることで、ジョグの負荷を抑え、インターバルの負荷を鋭く評価する
    // 基準1.0の時、1時間で60ポイント程度になるよう調整（あるいは以前のスケールに合わせるなら 3.0倍など）
    // 以前は 5:00(300s) 基準で 1時間180ポイントだったので、係数は 3.0 にする
    return (durationMin * pow(intensity, 3) * 3.0).round();
  }

  /// sRPE（主観的運動強度 × 時間）を計算
  /// RPEと時間（秒）が必要
  int? computeSrpeLoad(Session session) {
    final rpeValue = session.rpeValue;
    final durationSec = session.durationMainSec;

    if (rpeValue == null || durationSec == null || durationSec <= 0) {
      return null;
    }

    // sRPE = RPE × 時間（分）
    final durationMin = durationSec / 60.0;
    return (rpeValue * durationMin).round();
  }

  /// ゾーン係数 × 時間による負荷計算（暫定）
  /// ゾーンと時間が必要
  int? computeZoneLoad(Session session) {
    final zone = session.zone;
    final durationSec = session.durationMainSec;

    if (zone == null || durationSec == null || durationSec <= 0) {
      return null;
    }

    final zoneCoefficient = _getZoneCoefficient(zone);
    final durationMin = durationSec / 60.0;
    // 負荷 = ゾーン係数 × 分 × 3
    // 例: Zone E(1.0)で60分走った場合: 1.0 * 60 * 3 = 180
    return (zoneCoefficient * durationMin * 3).round();
  }

  /// ゾーンごとの係数
  double _getZoneCoefficient(Zone zone) {
    switch (zone) {
      case Zone.E:
        return 1.0;
      case Zone.M:
        return 1.5;
      case Zone.T:
        return 2.0;
      case Zone.I:
        return 3.0;
      case Zone.R:
        return 4.0;
    }
  }

  /// 代表負荷を計算（優先順位に従う）
  /// 
  /// 優先順位:
  /// 1. ペース由来負荷（距離+ペースがある場合）
  /// 2. sRPE（RPE+時間がある場合）
  /// 3. ゾーン負荷（ゾーン+時間がある場合）
  int? computeSessionRepresentativeLoad(Session session, {int? thresholdPaceSecPerKm}) {
    // 1. ペース由来負荷を試す
    final paceLoad = computePaceLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);
    if (paceLoad != null) {
      return paceLoad;
    }

    // 2. sRPEを試す
    final srpeLoad = computeSrpeLoad(session);
    if (srpeLoad != null) {
      return srpeLoad;
    }

    // 3. ゾーン負荷を試す
    final zoneLoad = computeZoneLoad(session);
    if (zoneLoad != null) {
      return zoneLoad;
    }

    // いずれも計算できない場合はnull
    return null;
  }

  /// 日単位の代表負荷（その日の全セッションの合計）
  int computeDayLoad(List<Session> sessions, {int? thresholdPaceSecPerKm}) {
    int total = 0;
    for (final session in sessions) {
      // statusがskippedの場合は負荷0
      if (session.status == SessionStatus.skipped) {
        continue;
      }
      final load = computeSessionRepresentativeLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);
      if (load != null) {
        total += load;
      }
    }
    return total;
  }
}
