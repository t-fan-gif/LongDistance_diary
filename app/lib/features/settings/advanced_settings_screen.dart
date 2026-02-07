import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../calendar/calendar_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/db/db_providers.dart';

/// SharedPreferencesからロードした負荷計算方式を管理するプロバイダ
final loadCalculationModeProvider = StateNotifierProvider<LoadCalculationModeNotifier, LoadCalculationMode>(
  (ref) => LoadCalculationModeNotifier(),
);

class LoadCalculationModeNotifier extends StateNotifier<LoadCalculationMode> {
  LoadCalculationModeNotifier() : super(LoadCalculationMode.priorityPace) {
    _loadFromPrefs();
  }

  static const _key = 'load_calculation_mode';

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    state = LoadCalculationMode.fromName(name);
  }

  Future<void> setMode(LoadCalculationMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
    state = mode;
  }
}

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends ConsumerState<AdvancedSettingsScreen> {
  LoadCalculationMode? _pendingMode;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(loadCalculationModeProvider);
    final displayMode = _pendingMode ?? currentMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, '負荷計算方式の選択'),
          Card(
            child: Column(
              children: LoadCalculationMode.values
                  .where((mode) => mode != LoadCalculationMode.priorityPace) // ペース優先（旧仕様）を除外
                  .map((mode) {
                return RadioListTile<LoadCalculationMode>(
                  title: Text(mode.label),
                  subtitle: Text(mode.description),
                  value: mode,
                  groupValue: displayMode,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _pendingMode = val);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // 保存ボタン
          ElevatedButton.icon(
            onPressed: _pendingMode != null && _pendingMode != currentMode && !_isSaving
                ? _saveMode
                : null,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_isSaving ? '保存中...' : '保存して再計算'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          _buildSectionHeader(context, '計算式の確認'),
          _buildFormulaCard(
            context,
            '1. オリジナル負荷 (ハイブリッド方式)',
            '時間(分) × (閾値ペース / 実際のペース) × ゾーン係数 × RPE調整',
            '走速度と心拍ゾーン係数に加え、独自のRPE（主観的強度）調整係数を組み合わせた、本アプリ推奨の計算方式です。RPE 6 を基準に ±20% の微調整が行われます。',
          ),
          _buildFormulaCard(
            context,
            '2. ペース由来負荷 (rTSS風)',
            '時間(分) × (閾値ペース / 実際のペース)^3 × ゾーン係数',
            '走力（閾値ペース）と実際のペースの比率から算出される最も精密な負荷指標です。',
          ),
          _buildFormulaCard(
            context,
            '3. 主観的負荷 (sRPE)',
            'RPE(0-10) × 時間(分)',
            '主観的なキツさと実施時間の掛け合わせで算出される汎用的な負荷指標です。',
          ),
          _buildFormulaCard(
            context,
            '4. ゾーン由来負荷',
            'ゾーン係数 × 時間(分)',
            '設定された心拍/ペースゾーン（E, M, T, I, R）の強度係数から算出されます。',
          ),
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '※ 選択した方式で保存すると、カレンダーなどの負荷表示が再計算されます。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMode() async {
    if (_pendingMode == null) return;

    setState(() => _isSaving = true);
    try {
      // 方式を保存
      await ref.read(loadCalculationModeProvider.notifier).setMode(_pendingMode!);

      // すべてのデータを無効化して再計算を促す
      ref.invalidate(allSessionsProvider); // 分析画面用
      
      final currentMonth = ref.read(selectedMonthProvider);
      ref.invalidate(monthCalendarDataProvider(currentMonth));
      // 前後の月も無効化（閲覧済みの場合のため）
      ref.invalidate(monthCalendarDataProvider(DateTime(currentMonth.year, currentMonth.month - 1)));
      ref.invalidate(monthCalendarDataProvider(DateTime(currentMonth.year, currentMonth.month + 1)));

      // 確認メッセージ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('負荷計算方式を保存しました。カレンダーと分析データが更新されます。')),
        );
        setState(() => _pendingMode = null);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildFormulaCard(BuildContext context, String title, String formula, String detail) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formula,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(detail, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

