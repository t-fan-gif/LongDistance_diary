import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'export_usecase.dart';
import 'import_usecase.dart';
import 'settings_screen.dart';
import '../../core/repos/export_repository.dart';
import '../../core/services/service_providers.dart';

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
                subtitle: const Text('JSONファイルからデータを復元します。現在のデータは上書きされます'),
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
                subtitle: const Text('指定期間の予定のみをファイルに出力します'),
                onTap: _isProcessing ? null : () => _handlePlansOnlyExport(),
              ),
              ListTile(
                leading: const Icon(Icons.download_for_offline, color: Colors.teal),
                title: const Text('練習予定を読み込む'),
                subtitle: const Text('予定ファイルを読み込みます。PBや実績は上書きされません'),
                onTap: _isProcessing ? null : () => _handlePlansOnlyImport(),
              ),
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
        content: const Text('ファイルからデータを読み込みます。現在のアプリ内のデータは全て削除され、ファイルの内容で上書きされますがよろしいですか？'),
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
      ref.invalidate(personalBestsProvider);
      ref.invalidate(menuPresetsProvider);
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

  Future<void> _handlePlansOnlyImport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予定の読み込み'),
        content: const Text('ファイルから練習予定を読み込みます。\n\n• 自己ベストや実績は影響を受けません\n• ゾーン指定の予定は、あなたPBに合わせてペースが自動計算されます'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('読み込む')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await ref.read(importUseCaseProvider).executePlansOnly();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('予定を読み込みました')),
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
}
