import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'export_usecase.dart';
import 'import_usecase.dart';
import 'settings_screen.dart';
import 'target_race_settings_screen.dart';
import '../calendar/calendar_providers.dart';
import '../day_detail/day_detail_screen.dart';
import '../../core/db/db_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/repos/session_repository.dart';
import '../../core/repos/plan_repository.dart';
import '../../core/repos/target_race_repository.dart';
import '../../core/services/service_providers.dart';
import '../plan_editor/weekly_plan_screen.dart';
import '../coach/plan_qr_display_dialog.dart';
import '../coach/plan_qr_scan_screen.dart';

class DataSettingsPage extends ConsumerStatefulWidget {
  const DataSettingsPage({super.key});

  @override
  ConsumerState<DataSettingsPage> createState() => _DataSettingsPageState();
}

class _DataSettingsPageState extends ConsumerState<DataSettingsPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データ管理'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'データのバックアップと移行',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('データをエクスポート'),
                subtitle: const Text('現在の全てのデータをJSONファイルで保存します'),
                onTap: _isProcessing ? null : () => _handleExport(),
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('データをインポート'),
                subtitle: const Text('JSONファイルからデータを復元します。同じIDのデータは上書きされ、新しいデータは追加されます'),
                onTap: _isProcessing ? null : () => _handleImport(),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'データの初期化',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('全てのデータを削除', style: TextStyle(color: Colors.red)),
                subtitle: const Text('アプリ内の全ての記録を消去します。元に戻すことはできません'),
                onTap: _isProcessing ? null : () => _handleReset(),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'コーチ向け予定配布',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.event_note, color: Colors.teal),
                title: const Text('練習予定をエクスポート'),
                subtitle: const Text('指定期間の予定のみをファイルに出力します（ペースは除去されます）'),
                onTap: _isProcessing ? null : () => _handlePlansOnlyExport(),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.teal),
                title: const Text('QRコードで計画を共有'),
                subtitle: const Text('期間を選択してQRコードを表示します'),
                onTap: _isProcessing ? null : () => _showQrExportDialog(),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: Colors.teal),
                title: const Text('QRコードから計画を読み込む'),
                subtitle: const Text('コーチの端末のQRコードをスキャンして取り込みます'),
                onTap: _isProcessing ? null : () => _openQrScanner(),
              ),
              /*
              */
            ],
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(exportUseCaseProvider).execute();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('インポートの確認'),
        content: const Text('ファイルからデータを読み込みます。\n\n• 同じIDのデータは上書きされます\n• 未登録のデータは新しく追加されます\n• ファイルにない既存データはそのまま残ります'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('実行')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(importUseCaseProvider).execute();
      
      // プロバイダのリセット
      ref.invalidate(personalBestsProvider);
      ref.invalidate(menuPresetsProvider);
      ref.invalidate(daySessionsProvider);
      ref.invalidate(dayPlansProvider);
      ref.invalidate(dayRaceProvider);
      ref.invalidate(monthCalendarDataProvider);
      ref.invalidate(allSessionsProvider);
      ref.invalidate(allPlansProvider);
      ref.invalidate(upcomingRacesProvider);
      ref.invalidate(allTargetRacesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('インポートが完了しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReset() async {
     final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データの初期化'),
        content: const Text('本当に全てのデータを削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除する', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(exportRepositoryProvider).resetData();
      
      // 全ての主要データを無効化
      ref.invalidate(personalBestsProvider);
      ref.invalidate(menuPresetsProvider);
      ref.invalidate(daySessionsProvider);
      ref.invalidate(dayPlansProvider);
      ref.invalidate(dayRaceProvider);
      ref.invalidate(monthCalendarDataProvider);
      ref.invalidate(allSessionsProvider);
      ref.invalidate(allPlansProvider);
      ref.invalidate(upcomingRacesProvider);
      ref.invalidate(allTargetRacesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('データを初期化しました')),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handlePlansOnlyExport() async {
    // 日付範囲選択ダイアログ
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 7)),
      ),
      helpText: 'エクスポートする期間を選択',
    );
    if (range == null) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(exportUseCaseProvider).executePlansOnly(range.start, range.end);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showQrExportDialog() {
    showDialog(
      context: context,
      builder: (context) => const PlanQrDisplayDialog(),
    );
  }

  void _openQrScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PlanQrScanScreen()),
    );
  }
  /*
  */
}
