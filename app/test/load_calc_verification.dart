import 'package:long_distance_diary/core/services/load_calculator.dart';
import 'package:long_distance_diary/core/db/app_database.dart';
import 'package:long_distance_diary/core/domain/enums.dart';

// 簡易モック
class MockSession extends Session {
  final int? _durationMainSec;
  final int? _paceSecPerKm;
  final Zone? _zone;
  final int? _distanceMainM;
  final int? _rpeValue;

  MockSession({
    int? durationMainSec,
    int? paceSecPerKm,
    Zone? zone,
    int? distanceMainM,
    int? rpeValue,
  }) : 
    _durationMainSec = durationMainSec,
    _paceSecPerKm = paceSecPerKm,
    _zone = zone,
    _distanceMainM = distanceMainM,
    _rpeValue = rpeValue,
    super(
      id: 'mock', 
      startedAt: DateTime.now(), 
      templateText: '', 
      status: SessionStatus.done,
      activityType: ActivityType.running,
      isRace: false,
    );

  @override
  int? get durationMainSec => _durationMainSec;
  @override
  int? get paceSecPerKm => _paceSecPerKm;
  @override
  Zone? get zone => _zone;
  @override
  int? get distanceMainM => _distanceMainM;
  @override
  int? get rpeValue => _rpeValue;
}

void main() {
  final calculator = LoadCalculator();
  
  // Test Case 1: Original Load (v1.3.20+9: RPE scaling 0.5)
  // 60 min, Intensity 1.0, Zone E(1.0), RPE 2
  // Expect: 60 * 1.0 * 1.0 * (2 * 0.5) = 60
  final jogSession = MockSession(
    durationMainSec: 60 * 60,
    paceSecPerKm: 300,
    zone: Zone.E,
    rpeValue: 2,
  );
  final jogLoad = calculator.computeOriginalLoad(jogSession, thresholdPaceSecPerKm: 300);
  print('Case 1: Original (Zone E, 60min, Int 1.0, RPE 2) -> Load: $jogLoad (Expected: 60)');

  // Test Case 2: Original Load (No duration, calculated from distance)
  // 10km, 5:00/km (300s/km) -> 50 min
  // Intensity 1.0, Zone E(1.0), RPE 4
  // Expect: 50 * 1.0 * 1.0 * (4 * 0.5) = 100
  final distSession = MockSession(
    distanceMainM: 10000,
    paceSecPerKm: 300,
    zone: Zone.E,
    rpeValue: 4,
  );
  final distLoad = calculator.computeOriginalLoad(distSession, thresholdPaceSecPerKm: 300);
  print('Case 2: Original (10km, 5:00/km, RPE 4) -> Load: $distLoad (Expected: 100)');

  // Test Case 3: rTSS Load (3x multiplier)
  // 60 min (1.0h), Intensity 1.0
  // Expect: 1.0 * 3 * 1.0^2 = 3
  final rtssSession = MockSession(
    durationMainSec: 60 * 60,
    paceSecPerKm: 300,
    zone: Zone.E,
  );
  final rtssLoad = calculator.computeRtssLoad(rtssSession, thresholdPaceSecPerKm: 300);
  print('Case 3: rTSS (1.0h, Int 1.0) -> Load: $rtssLoad (Expected: 3)');

  // Test Case 4: sRPE Load
  // 30 min, RPE 5
  // Expect: 30 * 5 = 150
  final srpeSession = MockSession(
    durationMainSec: 30 * 60,
    rpeValue: 5,
  );
  final srpeLoad = calculator.computeSrpeLoad(srpeSession);
  print('Case 4: sRPE (30min, RPE 5) -> Load: $srpeLoad (Expected: 150)');
}
