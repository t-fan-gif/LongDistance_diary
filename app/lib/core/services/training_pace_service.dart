import '../domain/enums.dart';
import '../services/vdot_calculator.dart';
import '../repos/personal_best_repository.dart';

class TrainingPaceService {
  TrainingPaceService(this._vdotCalc, this._pbRepo);

  final VdotCalculator _vdotCalc;
  final PersonalBestRepository _pbRepo;

  /// 最新の自己ベストを取得してVDOTを計算する
  Future<double?> getLatestVdot(ActivityType activityType) async {
    final pbs = await _pbRepo.listPersonalBests();
    final activityPbs = pbs.where((pb) => pb.activityType == activityType).toList();
    if (activityPbs.isEmpty) return null;

    // 最新（あるいは最も高いVDOT？）を取得。ここでは簡単のため日付が新しいもの。
    activityPbs.sort((a, b) => (b.date ?? DateTime(2000)).compareTo(a.date ?? DateTime(2000)));
    
    final best = activityPbs.first;
    return _vdotCalc.calculateVdot(_vdotCalc.getDistanceForEvent(best.event), best.timeMs ~/ 1000);
  }

  /// ペースから該当するゾーンを推定する
  Future<Zone?> estimateZoneFromPace(int paceSec, ActivityType activityType) async {
    final vdot = await getLatestVdot(activityType);
    if (vdot == null) return null;

    final zones = _vdotCalc.calculatePaces(vdot);
    
    // R -> I -> T -> M -> E の順にチェック（速い順）
    if (paceSec <= zones[Zone.R]!.maxSec) return Zone.R;
    if (paceSec <= zones[Zone.I]!.maxSec) return Zone.I;
    if (paceSec <= zones[Zone.T]!.maxSec) return Zone.T;
    if (paceSec <= zones[Zone.M]!.maxSec) return Zone.M;
    if (paceSec <= zones[Zone.E]!.maxSec) return Zone.E;
    
    return null;
  }

  /// ゾーンから推奨ペースを取得する
  Future<int?> getSuggestedPaceForZone(Zone zone, ActivityType activityType) async {
    final vdot = await getLatestVdot(activityType);
    if (vdot == null) return null;

    final zones = _vdotCalc.calculatePaces(vdot);
    final range = zones[zone];
    if (range == null) return null;

    // 中間値を返す
    return (range.minSec + range.maxSec) ~/ 2;
  }
}
