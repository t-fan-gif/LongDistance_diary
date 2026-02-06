import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/repos/menu_preset_repository.dart';
import '../../core/services/service_providers.dart'; // personalBestRepositoryProvider はここから

/// 全PBを取得
final personalBestsProvider = FutureProvider<List<PersonalBest>>((ref) async {
  final repo = ref.watch(personalBestRepositoryProvider);
  return repo.listPersonalBests();
});

/// MenuPresetRepositoryのプロバイダ
final menuPresetRepositoryProvider = Provider<MenuPresetRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MenuPresetRepository(db);
});

/// 全プリセットを取得
final menuPresetsProvider = FutureProvider<List<MenuPreset>>((ref) async {
  final repo = ref.watch(menuPresetRepositoryProvider);
  return repo.listPresets();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      appBar: AppBar(
        title: const Text('設定'),
        leading: const BackButton(),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, '入力補助'),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('カスタムメニュー管理'),
            subtitle: const Text('よく使うメニュー名の登録'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/presets'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'データと同期'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('データ管理'),
            subtitle: const Text('エクスポート、インポート、初期化'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/data'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('詳細設定'),
            subtitle: const Text('負荷計算方式の確認と選択'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/advanced'),
          ),
          const Divider(),
          _buildSectionHeader(context, '目標・レース設定'),
          _buildSettingTile(
            context,
            icon: Icons.flag_outlined,
            title: '走行距離目標',
            subtitle: '月間・週間の目標距離を設定',
            onTap: () => context.push('/settings/goals'),
          ),
          _buildSettingTile(
            context,
            icon: Icons.emoji_events_outlined,
            title: 'ターゲットレース',
            subtitle: '目標とするレースの管理',
            onTap: () => context.push('/settings/target-race'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'パフォーマンス設定'),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('自己ベスト管理'),
            subtitle: const Text('VDOT・推奨ペースの算出基準'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/pb'),
          ),
          const Divider(),
          _buildSectionHeader(context, 'アプリについて'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Long Distance Diary'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
              children: [
                Text(
                  'Version 1.3.10 (Round 9.10)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
