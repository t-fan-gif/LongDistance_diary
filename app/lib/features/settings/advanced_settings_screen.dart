import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../calendar/calendar_providers.dart';

enum LoadCalculationMode {
  priority('優先順位（推奨）', 'Original > rTSS > sRPE > Zone'),
  onlyOriginal('オリジナルのみ', 'オリジナル負荷計算を使用'),
  onlyRtss('rTSSのみ', 'rTSS風（ペース・強度）計算を使用'),
  onlySrpe('sRPEのみ', 'sRPE（強度×時間）計算を使用'),
  onlyZone('ゾーンのみ', 'ゾーン（強度）計算を使用'),
  // 以前の名称を互換性のために残す（内部的にpriorityにマッピング）
  priorityPace('ペース優先', 'Pace > sRPE > Zone');

  final String label;
  final String description;
  const LoadCalculationMode(this.label, this.description);

  static LoadCalculationMode fromName(String? name) {
    if (name == 'priorityPace') return LoadCalculationMode.priority;
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => LoadCalculationMode.priority,
    );
  }
}

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
              children: LoadCalculationMode.values.map((mode) {
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
            '1. ペース由来負荷 (rTSS風)',
            '時間(分) × (閾値ペース / 実際のペース)^3 × ゾーン係数',
            '走力（閾値ペース）と実際のペースの比率から算出される最も精密な負荷指標です。',
          ),
          _buildFormulaCard(
            context,
            '2. 主観的負荷 (sRPE)',
            'RPE(0-10) × 時間(分)',
            '主観的なキツさと実施時間の掛け合わせで算出される汎用的な負荷指標です。',
          ),
          _buildFormulaCard(
            context,
            '3. ゾーン由来負荷',
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

      // カレンダーデータをすべて無効化して再計算を促す
      final currentMonth = ref.read(selectedMonthProvider);
      ref.invalidate(monthCalendarDataProvider(currentMonth));
      // 前後の月も無効化（閲覧済みの場合のため）
      ref.invalidate(monthCalendarDataProvider(DateTime(currentMonth.year, currentMonth.month - 1)));
      ref.invalidate(monthCalendarDataProvider(DateTime(currentMonth.year, currentMonth.month + 1)));

      // 確認メッセージ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('負荷計算方式を保存しました。カレンダーが再計算されます。')),
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

