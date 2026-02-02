import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_screen.dart';

class MenuPresetSettingsPage extends ConsumerWidget {
  const MenuPresetSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(menuPresetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('カスタムメニュー管理'),
      ),
      body: presetsAsync.when(
        data: (presets) {
          if (presets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'よく使うメニュー名を登録しておくと、予定入力時に素早く入力できるようになります。',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: presets.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final preset = presets[index];
              return ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(preset.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deletePreset(context, ref, preset.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPresetEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPresetEditor(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('メニュー名を登録'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例: インターバル',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref.read(menuPresetRepositoryProvider).createPreset(name);
                ref.invalidate(menuPresetsProvider);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePreset(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: const Text('このプリセットを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(menuPresetRepositoryProvider).deletePreset(id);
      ref.invalidate(menuPresetsProvider);
    }
  }
}
