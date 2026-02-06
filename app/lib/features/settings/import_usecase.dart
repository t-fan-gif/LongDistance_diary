import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/enums.dart';
import '../day_detail/day_detail_screen.dart'; // dayRaceProvider
import '../../core/repos/export_repository.dart';
import '../../core/services/service_providers.dart';
import '../calendar/calendar_providers.dart';
import 'export_usecase.dart';
import '../plan_editor/weekly_plan_screen.dart'; // weeklyPlansProviderのため
import 'settings_screen.dart';
import 'target_race_settings_screen.dart'; // allTargetRacesProvider

final importUseCaseProvider = Provider<ImportUseCase>((ref) {
  final repo = ref.watch(exportRepositoryProvider);
  return ImportUseCase(repo, ref);
});

class ImportUseCase {
  ImportUseCase(this._repo, this._ref);

  final ExportRepository _repo;
  final Ref _ref;

  /// ファイルを選択してインポートを実行する
  Future<void> execute() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true, // Webでbytesを取得するために必要
    );

    if (result != null) {
      String jsonString;
      
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes == null) return;
        jsonString = utf8.decode(bytes);
      } else {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        jsonString = await file.readAsString();
      }

      // 予定のみインポート（コーチ配布用）の場合のペース自動調整
      final Map<String, dynamic> data = json.decode(jsonString);
      if (data['type'] == 'plans_only' && data['plans'] != null) {
        final paceService = _ref.read(trainingPaceServiceProvider);
        final plans = data['plans'] as List;
        
        for (final plan in plans) {
          // ペースが未設定かつゾーンが設定されている場合、選手のPBから逆算
          if (plan['pace'] == null && plan['zone'] != null) {
            try {
              final zone = Zone.values.firstWhere((z) => z.name == plan['zone']);
              // プランに設定されている種目を優先し、なければデフォルトでランニング
              final activityType = plan['activity_type'] != null 
                ? ActivityType.values.firstWhere((a) => a.name == plan['activity_type'], orElse: () => ActivityType.running)
                : ActivityType.running;
              
              // 種目に応じた閾値ペースをサービスに渡す必要があるが、
              // TrainingPaceService.getSuggestedPaceForZone は内部でPBを見に行っているわけではなく
              // 単にZoneから強度係数を返すだけなら、ここで計算が必要。
              // 既存実装: getSuggestedPaceForZone(zone, activityType) は
              // リポジトリからPBを取得して計算してくれるはず。
              
              // しかし、importUseCaseはProvider内なので、refから直接最新のPB値を渡して計算させたほうが確実か、
              // あるいはService側がrefを持っているか。
              // TrainingPaceServiceはProviderで提供されているので、内部でRefを持っている。
              // ですが、ここでは async での取得が必要かもしれない。
              
              final suggestedPace = await paceService.getSuggestedPaceForZone(zone, activityType);
              if (suggestedPace != null) {
                plan['pace'] = suggestedPace;
              }
            } catch (_) {
              // 変換エラー等はスキップ
            }
          }
        }
        // 更新したデータを再エンコードして repo に渡す
        // target_races があればそれも含まれている
        jsonString = json.encode(data);
      }
      
      await _repo.importFromJson(jsonString);

      // 全データ無効化
      _ref.invalidate(monthCalendarDataProvider);
      _ref.invalidate(runningThresholdPaceProvider);
      _ref.invalidate(walkingThresholdPaceProvider);
      _ref.invalidate(personalBestsProvider);
      _ref.invalidate(menuPresetsProvider);
      _ref.invalidate(selectedMonthProvider); // カレンダー一式
      _ref.invalidate(weeklyPlansProvider);   // 週間リストも更新
      _ref.invalidate(allTargetRacesProvider);   // ターゲットレースも更新
      _ref.invalidate(dayRaceProvider);       // 日別レース情報も更新
    }
  }
}
