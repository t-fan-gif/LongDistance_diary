enum PbEvent {
  m800,
  m1500,
  m3000,
  m3000sc,
  m5000,
  m10000,
  half,
  full,
  // Race Walking
  w3000,
  w5000,
  w10000,
  w20km,
  w35km,
  w50km,
  wHalf,
  wFull,
  other, // その他（距離指定）
}

extension PbEventLabels on PbEvent {
  String get label {
    switch (this) {
      case PbEvent.m800: return '800m';
      case PbEvent.m1500: return '1500m';
      case PbEvent.m3000: return '3000m';
      case PbEvent.m3000sc: return '3000mSC';
      case PbEvent.m5000: return '5000m';
      case PbEvent.m10000: return '10000m';
      case PbEvent.half: return 'ハーフマラソン';
      case PbEvent.full: return 'フルマラソン';
      case PbEvent.w3000: return '3000m競歩';
      case PbEvent.w5000: return '5000m競歩';
      case PbEvent.w10000: return '10000m競歩';
      case PbEvent.w20km: return '20km競歩';
      case PbEvent.w35km: return '35km競歩';
      case PbEvent.w50km: return '50km競歩';
      case PbEvent.wHalf: return 'ハーフマラソン競歩';
      case PbEvent.wFull: return 'フルマラソン競歩';
      case PbEvent.other: return 'その他';
    }
  }
}

enum ActivityType { running, walking }

extension ActivityTypeLabels on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.running: return 'ランニング';
      case ActivityType.walking: return '競歩';
    }
  }
}

enum Zone { E, M, T, I, R }

enum RestType { stop, jog }


enum SessionStatus { done, partial, aborted, skipped }

// 単位列挙型 (予定・実績入力共通)
enum PlanUnit { km, m, min, sec }
