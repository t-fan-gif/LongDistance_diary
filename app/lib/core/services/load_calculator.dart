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
  int? computePaceLoad(Session session) {
    final distanceM = session.distanceMainM;
    final paceSecPerKm = session.paceSecPerKm;

    if (distanceM == null || paceSecPerKm == null || paceSecPerKm <= 0) {
      return null;
    }

    final distanceKm = distanceM / 1000.0;
    // 速いほど係数が高い: 基準ペース/実際のペース
    final paceCoefficient = _basePaceSecPerKm / paceSecPerKm;
    // 負荷 = 距離 × ペース係数 × 15
    // 例: 12kmを5:00/km(300s)で走った場合: 12 * (300/300) * 15 = 180
    return (distanceKm * paceCoefficient * 15).round();
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
  int? computeSessionRepresentativeLoad(Session session) {
    // 1. ペース由来負荷を試す
    final paceLoad = computePaceLoad(session);
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
  int computeDayLoad(List<Session> sessions) {
    int total = 0;
    for (final session in sessions) {
      // statusがskippedの場合は負荷0
      if (session.status == SessionStatus.skipped) {
        continue;
      }
      final load = computeSessionRepresentativeLoad(session);
      if (load != null) {
        total += load;
      }
    }
    return total;
  }
}
