
import 'dart:math';

// スタンドアロンテスト用のクラス定義（本体コードと同等のロジックをテスト）
enum Zone { E, M, T, I, R }

class LoadCalculatorStub {
  static const int _basePaceSecPerKm = 300;

  double _getZoneCoefficient(Zone zone) {
    switch (zone) {
      case Zone.E: return 1.0;
      case Zone.M: return 1.5;
      case Zone.T: return 2.0;
      case Zone.I: return 3.0;
      case Zone.R: return 4.0;
    }
  }

  int? computePaceLoad(int durationSec, int paceSecPerKm, int? thresholdPaceSecPerKm, Zone zone) {
    double durationMin = durationSec / 60.0;
    final tPace = thresholdPaceSecPerKm ?? _basePaceSecPerKm;
    final intensity = tPace / paceSecPerKm;

    final baseLoad = durationMin * pow(intensity, 3);
    final zoneCoefficient = _getZoneCoefficient(zone);
    return (baseLoad * zoneCoefficient).round();
  }

  int? computeZoneLoad(int durationSec, Zone zone) {
    final zoneCoefficient = _getZoneCoefficient(zone);
    final durationMin = durationSec / 60.0;
    return (zoneCoefficient * durationMin).round();
  }
}

void main() {
  final calculator = LoadCalculatorStub();
  
  print('--- Hybrid Calculation (Pace Load * ZoneCoeff) ---');
  
  // Case 1: Jog (Zone E, 60min, Int 1.0) -> Expected: 60
  var res = calculator.computePaceLoad(3600, 300, 300, Zone.E);
  print('Case 1: $res (Expected: 60)');

  // Case 2: Jog (Zone E, 60min, Int 0.8) -> Expected: 31
  res = calculator.computePaceLoad(3600, 300, 240, Zone.E);
  print('Case 2: $res (Expected: 31)');

  // Case 3: Threshold (Zone T, 20min, Int 1.0) -> Expected: 40
  res = calculator.computePaceLoad(1200, 240, 240, Zone.T);
  print('Case 3: $res (Expected: 40)');

  // Case 4: Interval (Zone I, 20min, Int 1.0) -> Expected: 60
  res = calculator.computePaceLoad(1200, 240, 240, Zone.I);
  print('Case 4: $res (Expected: 60)');

  // Case 5: Repetition (Zone R, 20min, Int 0.8) -> Expected: 41
  res = calculator.computePaceLoad(1200, 300, 240, Zone.R);
  print('Case 5: $res (Expected: 41)');

  print('\n--- Pure Zone Calculation (ZoneCoeff * Time) ---');
  // Case 6: Zone E for 60min -> Expected: 60
  res = calculator.computeZoneLoad(3600, Zone.E);
  print('Case 6: $res (Expected: 60)');

  // Case 7: Zone I for 20min -> Expected: 60
  res = calculator.computeZoneLoad(1200, Zone.I);
  print('Case 7: $res (Expected: 60)');
}
