import 'package:flutter/material.dart';

/// 負荷比率を濃淡（ヒートマップ色）に変換するサービス
class HeatmapScaler {
  /// 負荷比率を段階（バケット）に変換
  /// 
  /// 段階:
  /// 0: 負荷なし（ratio = 0）
  /// 1: 非常に軽い（ratio < 0.5）
  /// 2: 軽い（0.5 <= ratio < 0.8）
  /// 3: 普通（0.8 <= ratio < 1.2）
  /// 4: やや高い（1.2 <= ratio < 1.5）
  /// 5: 高い（1.5 <= ratio < 2.0）
  /// 6: 非常に高い（ratio >= 2.0）
  int bucketize(double ratio) {
    if (ratio <= 0) return 0;
    if (ratio < 0.5) return 1;
    if (ratio < 0.8) return 2;
    if (ratio < 1.2) return 3;
    if (ratio < 1.5) return 4;
    if (ratio < 2.0) return 5;
    return 6;
  }

  /// 段階から色を取得
  /// 
  /// 青（低負荷）→ 緑 → 黄 → オレンジ → 赤（高負荷）のグラデーション
  Color getColorForBucket(int bucket) {
    switch (bucket) {
      case 0:
        return Colors.transparent; // 負荷なし（透明）
      case 1:
        return Colors.blue.shade50.withValues(alpha: 0.7); // 非常に軽い
      case 2:
        return Colors.green.shade50.withValues(alpha: 0.7); // 軽い
      case 3:
        return Colors.green.shade100.withValues(alpha: 0.7); // 普通
      case 4:
        return Colors.yellow.shade100.withValues(alpha: 0.7); // やや高い
      case 5:
        return Colors.orange.shade100.withValues(alpha: 0.7); // 高い
      case 6:
        return Colors.red.shade100.withValues(alpha: 0.7); // 非常に高い
      default:
        return Colors.transparent;
    }
  }

  /// 負荷比率から直接色を取得
  Color getColorForRatio(double ratio) {
    final bucket = bucketize(ratio);
    return getColorForBucket(bucket);
  }

  /// 段階の説明テキストを取得
  String getLabelForBucket(int bucket) {
    switch (bucket) {
      case 0:
        return '記録なし';
      case 1:
        return '非常に軽い';
      case 2:
        return '軽い';
      case 3:
        return '普通';
      case 4:
        return 'やや高い';
      case 5:
        return '高い';
      case 6:
        return '非常に高い';
      default:
        return '不明';
    }
  }
}
