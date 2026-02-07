
import '../lib/core/services/load_calculator.dart';
import '../lib/core/db/app_database.dart';
import '../lib/core/domain/enums.dart';

// 簡易モック
class MockSession extends Session {
  final int? _durationMainSec;
  final int? _paceSecPerKm;
  final Zone? _zone;
  final int? _distanceMainM;

  MockSession({
    int? durationMainSec,
    int? paceSecPerKm,
    Zone? zone,
    int? distanceMainM,
  }) : 
    _durationMainSec = durationMainSec,
    _paceSecPerKm = paceSecPerKm,
    _zone = zone,
    _distanceMainM = distanceMainM,
    super(
      id: 'mock', 
      startedAt: DateTime.now(), 
      templateText: '', 
      status: SessionStatus.done
    );

  @override
  int? get durationMainSec => _durationMainSec;
  @override
  int? get paceSecPerKm => _paceSecPerKm;
  @override
  Zone? get zone => _zone;
  @override
  int? get distanceMainM => _distanceMainM;
}

void main() {
  final calculator = LoadCalculator();
  
  // Test Case 1: Jog (Zone E)
  // 60 min, Intensity 1.0 (Threshold Pace = Actual Pace for simplicity of math check)
  // Expect: 60 * 1^3 * 1.0 = 60
  final jogSession = MockSession(
    durationMainSec: 60 * 60, // 60 min
    paceSecPerKm: 300,        // 5:00/km
    zone: Zone.E,
  );
  // Threshold also 5:00/km -> Intensity 1.0
  final jogLoad = calculator.computePaceLoad(jogSession, thresholdPaceSecPerKm: 300);
  print('Case 1: Jog (Zone E, 60min, Int 1.0) -> Load: $jogLoad (Expected: 60)');

  // Test Case 2: Jog (Zone E) - Slower
  // 60 min, Intensity 0.8 (T=4:00(240s), Actual=5:00(300s))
  // Expect: 60 * 0.8^3 * 1.0 = 60 * 0.512 * 1.0 = 30.72 -> 31
  final jogSlowSession = MockSession(
    durationMainSec: 60 * 60,
    paceSecPerKm: 300,
    zone: Zone.E,
  );
  final jogSlowLoad = calculator.computePaceLoad(jogSlowSession, thresholdPaceSecPerKm: 240);
  print('Case 2: Jog (Zone E, 60min, Int 0.8) -> Load: $jogSlowLoad (Expected: 31)');


  // Test Case 3: Threshold Run (Zone T)
  // 20 min, Intensity 1.0
  // Expect: 20 * 1^3 * 2.0 (Zone T coeff) = 40
  final tSession = MockSession(
    durationMainSec: 20 * 60,
    paceSecPerKm: 240,
    zone: Zone.T,
  );
  final tLoad = calculator.computePaceLoad(tSession, thresholdPaceSecPerKm: 240);
  print('Case 3: Threshold (Zone T, 20min, Int 1.0) -> Load: $tLoad (Expected: 40)');

  // Test Case 4: Interval (Zone I)
  // 20 min, Intensity 1.0 (Avg Pace matches Threshold, though actually faster segments)
  // Expect: 20 * 1^3 * 3.0 (Zone I coeff) = 60
  final iSession = MockSession(
    durationMainSec: 20 * 60,
    paceSecPerKm: 240,
    zone: Zone.I,
  );
  final iLoad = calculator.computePaceLoad(iSession, thresholdPaceSecPerKm: 240);
  print('Case 4: Interval (Zone I, 20min, Int 1.0) -> Load: $iLoad (Expected: 60)');

  // Test Case 5: Repetition (Zone R)
  // 20 min, Intensity 0.8 (Avg pace slower due to rest)
  // Expect: 20 * 0.8^3 * 4.0 = 20 * 0.512 * 4.0 = 40.96 -> 41
  final rSession = MockSession(
    durationMainSec: 20 * 60,
    paceSecPerKm: 300, // slower avg
    zone: Zone.R,
  );
  final rLoad = calculator.computePaceLoad(rSession, thresholdPaceSecPerKm: 240);
  print('Case 5: Repetition (Zone R, 20min, Int 0.8) -> Load: $rLoad (Expected: 41)');
}
