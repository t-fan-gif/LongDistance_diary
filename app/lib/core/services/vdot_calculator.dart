import 'dart:math';

import '../domain/enums.dart';

/// Jack DanielsのVDOT計算とペース算出を行うサービスクラス
class VdotCalculator {
  /// 距離(m)とタイム(秒)からVDOTを計算する
  /// 計算式は近似式を使用し、二分探索で逆算する
  double calculateVdot(int distanceM, int timeSec) {
    if (distanceM <= 0 || timeSec <= 0) return 0;

    final double distMeter = distanceM.toDouble();
    final double timeMin = timeSec / 60.0;
    
    // 速度 (m/min)
    final double v = distMeter / timeMin;

    // VDOTの近似範囲 (10〜85くらいが一般的)
    double lower = 10.0;
    double upper = 85.0;
    double vdot = 0.0;

    // 20回ループで十分な精度が出る
    for (int i = 0; i < 20; i++) {
        double mid = (lower + upper) / 2.0;
        double estimatedTimeMin = _calculateTimeForDistance(distMeter, mid);
        
        if (estimatedTimeMin > timeMin) {
            // 遅すぎる -> VDOTをもっと上げる必要がある
            lower = mid;
        } else {
            // 速すぎる -> VDOTを下げる必要がある
            upper = mid;
        }
        vdot = mid;
    }
    
    return double.parse(vdot.toStringAsFixed(1));
  }

  /// 指定されたVDOTで、指定距離(m)を走るのにかかる時間(分)を算出
  /// Danielsの式: VO2 = -4.60 + 0.182258*v + 0.000104*v^2
  /// %VO2max = 0.8 + 0.1894393*exp(-0.012778*t) + 0.2989558*exp(-0.1932605*t)
  /// VO2 = VDOT * %VO2max
  double _calculateTimeForDistance(double distM, double vdot) {
      // 時間tを仮定して%VO2maxを求め、そこから速度vを求め、距離と比較して合わせ込む
      // というのは逆算が難しいので、ここでは
      // 速度vを仮定 -> 時間tが求まる -> %VO2maxが求まる -> VO2が求まる -> VDOTと比較
      // というアプローチも考えられるが、
      // ここではさらに別の近似として、一般的なVDOTの速度式を使いたいが、
      // 厳密な式の実装は複雑なので、ここでは
      // 「VDOT Xのときの各距離のタイム」を求める関数として実装する。
      
      // 時間 t (分) に対する %VO2max の計算
      double percentMax(double t) {
          return 0.8 + 0.1894393 * exp(-0.012778 * t) + 0.2989558 * exp(-0.1932605 * t);
      }
      
      // 速度 v (m/min) に対する VO2 の計算
      double vo2(double v) {
          return -4.60 + 0.182258 * v + 0.000104 * pow(v, 2);
      }

      // 二分探索でタイムを求める
      double lowT = 1.0; // 1分
      double highT = 1000.0; // 1000分 (約16時間)
      
      for(int i=0; i<20; i++) {
          double midT = (lowT + highT) / 2.0;
          double pMax = percentMax(midT);
          double currentVo2 = vdot * pMax;
          
          // VO2 = -4.60 + 0.182258*v + 0.000104*v^2
          // これを v について解く (解の公式)
          // 0.000104*v^2 + 0.182258*v - (VO2 + 4.60) = 0
          double a = 0.000104;
          double b = 0.182258;
          double c = -(currentVo2 + 4.60);
          
          double v = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a);
          
          double estimatedDist = v * midT;
          
          if (estimatedDist < distM) {
              // 距離が足りない -> もっと長く走る必要がある
              lowT = midT;
          } else {
              highT = midT;
          }
      }
      
      return (lowT + highT) / 2.0;
  }

  /// VDOTに基づき各Zoneのペース（秒/km）を算出
  Map<Zone, PaceRange> calculatePaces(double vdot) {
    // 基準ペース（1km走るのにかかる秒数）を計算
    
    // Eペース: 65-79% VO2max (一般的にはVDOTの一定割合)
    // 実用的には、VDOTに対応するEペースの表があるが、ここでは近似計算を行う。
    // E Pace is typically roughly 1.15 to 1.30 times slower than M Pace? No.
    // Let's use %VO2max based calculation.
    
    // しかし厳密な式より、VDOTから直接ペースを導く簡易係数の方が実装しやすい。
    // ここでは簡易的に、Danielsの表に近い値が出るよう調整した %VO2max を使用する。
    
    // M Pace: ~85% VO2max (VDOTによって異なるが近似)
    // T Pace: ~90% VO2max
    // I Pace: ~100% VO2max
    // R Pace: >100% (200m/400m Reps intensity)
    
    // 逆算ロジック:
    // 指定された %VO2max になるような VO2 を求め、それを速度 v に変換し、ペース(s/km)にする。
    
    int getPace(double percent) {
        double targetVo2 = vdot * percent;
        // 0.000104*v^2 + 0.182258*v - (targetVo2 + 4.60) = 0
        double a = 0.000104;
        double b = 0.182258;
        double c = -(targetVo2 + 4.60);
        double v = (-b + sqrt(pow(b, 2) - 4 * a * c)) / (2 * a); // m/min
        if (v <= 0) return 0;
        return (1000 / v * 60).round(); // s/km
    }
    
    // E: 59% - 74% VO2max (Daniels 2nd ed) -> Easy range 
    // M: 79 - 89% 
    // T: 88 - 92%
    // I: 97 - 100%
    // R: ~105-110%
    
    // Approximate ranges:
    final ePaceSlow = getPace(0.65);
    final ePaceFast = getPace(0.79);
    final mPace = getPace(0.85); // Approximate Marathon intensity
    final tPace = getPace(0.90); // Threshold
    final iPace = getPace(1.00); // Interval
    final rPace = getPace(1.10); // Repetition
    
    return {
      Zone.E: PaceRange(minSec: ePaceFast, maxSec: ePaceSlow),
      Zone.M: PaceRange(minSec: mPace, maxSec: mPace), // Point value
      Zone.T: PaceRange(minSec: tPace, maxSec: tPace),
      Zone.I: PaceRange(minSec: iPace, maxSec: iPace),
      Zone.R: PaceRange(minSec: rPace, maxSec: rPace),
    };
  }

  /// 指定されたVDOTで主要距離の予測タイムを計算する
  Map<PbEvent, int> predictTimes(double vdot) {
    final results = <PbEvent, int>{};
    final events = [
      PbEvent.m5000,
      PbEvent.m10000,
      PbEvent.half,
      PbEvent.full,
    ];

    for (final event in events) {
      final dist = getDistanceForEvent(event);
      final timeMin = _calculateTimeForDistance(dist.toDouble(), vdot);
      results[event] = (timeMin * 60).round();
    }
    return results;
  }

  /// PbEventに対応する距離(m)を返す
  int getDistanceForEvent(PbEvent event) {
    switch (event) {
      case PbEvent.m800: return 800;
      case PbEvent.m1500: return 1500;
      case PbEvent.m3000: return 3000;
      case PbEvent.m3000sc: return 3000;
      case PbEvent.m5000: return 5000;
      case PbEvent.m10000: return 10000;
      case PbEvent.half: return 21097;
      case PbEvent.full: return 42195;
      case PbEvent.w3000: return 3000;
      case PbEvent.w5000: return 5000;
      case PbEvent.w10000: return 10000;
      case PbEvent.w20km: return 20000;
      case PbEvent.w35km: return 35000;
      case PbEvent.w50km: return 50000;
      case PbEvent.wHalf: return 21097;
      case PbEvent.wFull: return 42195;
      case PbEvent.other: return 0; // その他の場合はとりあえず0（VDOT計算には使えない）
    }
  }
}

class PaceRange {
  final int minSec; // 速い方のペース（秒数値は小さい）
  final int maxSec; // 遅い方のペース（秒数値は大きい）
  
  const PaceRange({required this.minSec, required this.maxSec});
  
  @override
  String toString() {
    if (minSec == maxSec) {
        return _fmt(minSec);
    }
    return '${_fmt(minSec)} - ${_fmt(maxSec)}';
  }
  
  String _fmt(int sec) {
      final m = sec ~/ 60;
      final s = sec % 60;
      return '$m:${s.toString().padLeft(2, '0')}';
  }
}
