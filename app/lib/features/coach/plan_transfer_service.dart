import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/db/app_database.dart';
import '../../core/domain/enums.dart';

import 'package:drift/drift.dart';

final planTransferServiceProvider = Provider((ref) => PlanTransferService());

class PlanTransferService {
  /// 計画リストをQRコード用の圧縮文字列に変換する
  /// JSON -> GZIP -> Base64
  String encodePlans(List<Plan> plans) {
    if (plans.isEmpty) return '';

    final List<Map<String, dynamic>> dataList = plans.map((p) {
      return {
        'dt': p.date.toIso8601String().split('T')[0], // YYYY-MM-DD
        'm': p.menuName,
        if (p.distance != null) 'di': p.distance,
        if (p.duration != null) 'du': p.duration,
        if (p.pace != null) 'p': p.pace,
        if (p.zone != null) 'z': p.zone!.name,
        if (p.reps > 1) 'r': p.reps, // 1の場合は省略
        if (p.note != null && p.note!.isNotEmpty) 'n': p.note,
        if (p.activityType != ActivityType.running) 'at': p.activityType.name, // runningは省略
        if (p.isRace) 'ir': 1,
      };
    }).toList();

    final Map<String, dynamic> payload = {
      'v': 1, // data version
      'd': dataList,
    };

    final jsonString = jsonEncode(payload);
    final bytes = utf8.encode(jsonString);
    final gzipped = GZipEncoder().encode(bytes);
    
    return base64Encode(gzipped);
  }

  /// QRコードの文字列を解析して計画データのリストを返す
  /// Base64 -> GZIP -> JSON -> List<PlanData>
  /// ※DBのPlanクラスはIDが必要なので、ここでは一時的なデータ構造(Map)または
  ///  Insertable[Plan] に変換しやすい形式で返す
  List<PlansCompanion> decodePlans(String encodedData) {
    try {
      final bytes = base64Decode(encodedData);
      final decodedBytes = GZipDecoder().decodeBytes(bytes);
      final jsonString = utf8.decode(decodedBytes);
      final payload = jsonDecode(jsonString) as Map<String, dynamic>;

      final version = payload['v'] as int;
      if (version != 1) {
        throw Exception('Unsupported version: $version');
      }

      final dataList = (payload['d'] as List).cast<Map<String, dynamic>>();
      
      return dataList.map((map) {
        final dateStr = map['dt'] as String;
        final date = DateTime.parse(dateStr);
        
        return PlansCompanion.insert(
          id: 'imported_${DateTime.now().millisecondsSinceEpoch}_$dateStr', // 一時ID、保存時に再生成推奨だがDriftのinsertに任せるならid不要かも
          date: date,
          menuName: map['m'] as String,
          distance: map['di'] != null ? Value(map['di'] as int) : const Value.absent(),
          duration: map['du'] != null ? Value(map['du'] as int) : const Value.absent(),
          pace: map['p'] != null ? Value(map['p'] as int) : const Value.absent(),
          zone: map['z'] != null 
              ? Value(Zone.values.firstWhere((e) => e.name == map['z'], orElse: () => Zone.E))
              : const Value.absent(),
          reps: map['r'] != null ? Value(map['r'] as int) : const Value(1),
          note: map['n'] != null ? Value(map['n'] as String) : const Value.absent(),
          activityType: map['at'] != null
              ? Value(ActivityType.values.firstWhere((e) => e.name == map['at'], orElse: () => ActivityType.running))
              : const Value(ActivityType.running),
          isRace: map['ir'] == 1 ? const Value(true) : const Value(false),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to decode data: $e');
    }
  }
}
