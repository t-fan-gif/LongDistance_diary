import 'dart:math';
import '../db/app_database.dart';
import '../domain/enums.dart';
import '../../features/settings/advanced_settings_screen.dart';

/// セッションの負荷計算を行うサービス
class LoadCalculator {
  /// ペース由来負荷（rTSS風）の計算
  /// 
  /// 計算式: (距離km × ペース係数)
  /// ペース係数はペースが速いほど高くなる（BASE_PACE / 実際のペース）
  static const int _basePaceSecPerKm = 300; // 基準ペース: 5:00/km = 300秒

  /// 1. オリジナル負荷
  /// 計算式: 時間(分) × (閾値ペース / 実際のペース) × ゾーン係数 × RPE(0.5倍)
  int? computeOriginalLoad(Session session, {int? thresholdPaceSecPerKm}) {
    final durationSec = session.durationMainSec;
    final paceSecPerKm = session.paceSecPerKm;
    final distanceM = session.distanceMainM;
    final zone = session.zone;
    final rpe = session.rpeValue;

    if (paceSecPerKm == null || paceSecPerKm <= 0 || rpe == null) {
      return null;
    }

    double durationMin;
    if (durationSec != null && durationSec > 0) {
      durationMin = durationSec / 60.0;
    } else if (distanceM != null && distanceM > 0) {
      durationMin = (distanceM / 1000.0) * paceSecPerKm / 60.0;
    } else {
      return null;
    }

    final tPace = thresholdPaceSecPerKm ?? _basePaceSecPerKm;
    final intensity = tPace / paceSecPerKm;
    final zoneCoefficient = _getZoneCoefficient(zone ?? Zone.E);

    // RPEを調整係数として使用（RPE 6 を基準に ±20% -> ±40% の範囲で調整）
    // 例: RPE 10 -> 1.4倍, RPE 6 -> 1.0倍, RPE 2 -> 0.6倍
    final rpeAdjustment = 1.0 + (rpe - 6) * 0.1;
    
    return (durationMin * intensity * zoneCoefficient * rpeAdjustment).round();
  }

  /// 2. rTSS風（ペース・強度）負荷
  /// 計算式: 時間(分) × (閾値ペース / 実際のペース)^3 × ゾーン係数
  int? computeRtssLoad(Session session, {int? thresholdPaceSecPerKm}) {
    final durationSec = session.durationMainSec;
    final paceSecPerKm = session.paceSecPerKm;
    final distanceM = session.distanceMainM;

    if (paceSecPerKm == null || paceSecPerKm <= 0) return null;
    
    double durationMin;
    if (durationSec != null && durationSec > 0) {
      durationMin = durationSec / 60.0;
    } else if (distanceM != null && distanceM > 0) {
      durationMin = (distanceM / 1000.0) * paceSecPerKm / 60.0;
    } else {
      return null;
    }

    final tPace = thresholdPaceSecPerKm ?? _basePaceSecPerKm;
    final intensity = tPace / paceSecPerKm;
    final zoneCoefficient = _getZoneCoefficient(session.zone ?? Zone.E);

    return (durationMin * pow(intensity, 3) * zoneCoefficient).round();
  }

  /// 3. sRPE（主観的運動強度 × 時間）を計算
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

  /// 4. ゾーン係数 × 時間による負荷計算
  /// ゾーンと時間が必要
  int? computeZoneLoad(Session session) {
    final zone = session.zone;
    final durationSec = session.durationMainSec;

    if (zone == null || durationSec == null || durationSec <= 0) {
      return null;
    }

    final zoneCoefficient = _getZoneCoefficient(zone);
    final durationMin = durationSec / 60.0;
    return (zoneCoefficient * durationMin).round();
  }

  /// ゾーンごとの係数
  double _getZoneCoefficient(Zone zone) {
    switch (zone) {
      case Zone.E: return 1.0;
      case Zone.M: return 1.5;
      case Zone.T: return 2.0;
      case Zone.I: return 3.5;
      case Zone.R: return 4.5;
    }
  }

  /// 代表負荷を計算（優先順位に従う）
  /// 
  /// [mode]: 計算方式（デフォルトは優先順位）
  int? computeSessionRepresentativeLoad(
    Session session, {
    int? thresholdPaceSecPerKm,
    LoadCalculationMode mode = LoadCalculationMode.priority,
  }) {
    switch (mode) {
      case LoadCalculationMode.priority:
        // 1. オリジナル
        final originalLoad = computeOriginalLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);
        if (originalLoad != null) return originalLoad;

        // 2. rTSS風
        final rtssLoad = computeRtssLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);
        if (rtssLoad != null) return rtssLoad;

        // 3. sRPE
        final srpeLoad = computeSrpeLoad(session);
        if (srpeLoad != null) return srpeLoad;

        // 4. ゾーン
        final zoneLoad = computeZoneLoad(session);
        if (zoneLoad != null) return zoneLoad;
        break;

      case LoadCalculationMode.onlyOriginal:
        return computeOriginalLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);

      case LoadCalculationMode.onlyRtss:
        return computeRtssLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);

      case LoadCalculationMode.onlySrpe:
        return computeSrpeLoad(session);

      case LoadCalculationMode.onlyZone:
        return computeZoneLoad(session);

      case LoadCalculationMode.priorityPace:
        return computeSessionRepresentativeLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm, mode: LoadCalculationMode.priority);
    }

    // いずれも計算できない、または該当なしの場合はnull
    return null;
  }

  /// 日単位の代表負荷（その日の全セッションの合計）
  int computeDayLoad(
    List<Session> sessions, {
    int? thresholdPaceSecPerKm,
    LoadCalculationMode mode = LoadCalculationMode.priorityPace,
  }) {
    int total = 0;
    for (final session in sessions) {
      // statusがskippedの場合は負荷0
      if (session.status == SessionStatus.skipped) {
        continue;
      }
      final load = computeSessionRepresentativeLoad(
        session,
        thresholdPaceSecPerKm: thresholdPaceSecPerKm,
        mode: mode,
      );
      if (load != null) {
        total += load;
      }
    }
    return total;
  }
}
