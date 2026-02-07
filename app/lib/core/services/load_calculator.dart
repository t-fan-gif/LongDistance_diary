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

    // 修正: ユーザー要望により、固定係数3.0を削除し、Zone係数を乗算するハイブリッド方式に変更
    // 負荷 = 時間(分) × 強度^3 × ゾーン係数
    
    // 1. ベースのペース由来負荷 (時間 x 強度^3)
    final baseLoad = durationMin * pow(intensity, 3);

    // 2. ゾーン係数を取得 (Zone未設定時は 1.0 とする)
    final zoneCoefficient = _getZoneCoefficient(session.zone ?? Zone.E);

    // 3. 最終負荷
    return (baseLoad * zoneCoefficient).round();
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
    // 修正: スケール統一のため 3倍の固定係数を削除
    // 負荷 = ゾーン係数 × 分
    // 例: Zone E(1.0)で60分走った場合: 1.0 * 60 = 60
    return (zoneCoefficient * durationMin).round();
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
  /// [mode]: 計算方式（デフォルトはペース優先）
  int? computeSessionRepresentativeLoad(
    Session session, {
    int? thresholdPaceSecPerKm,
    LoadCalculationMode mode = LoadCalculationMode.priorityPace,
  }) {
    switch (mode) {
      case LoadCalculationMode.priorityPace:
        // 1. ペース由来負荷を試す
        final paceLoad = computePaceLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);
        if (paceLoad != null) return paceLoad;

        // 2. sRPEを試す
        final srpeLoad = computeSrpeLoad(session);
        if (srpeLoad != null) return srpeLoad;

        // 3. ゾーン負荷を試す
        final zoneLoad = computeZoneLoad(session);
        if (zoneLoad != null) return zoneLoad;
        break;

      case LoadCalculationMode.onlyPace:
        return computePaceLoad(session, thresholdPaceSecPerKm: thresholdPaceSecPerKm);

      case LoadCalculationMode.onlySrpe:
        return computeSrpeLoad(session);

      case LoadCalculationMode.onlyZone:
        return computeZoneLoad(session);
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
