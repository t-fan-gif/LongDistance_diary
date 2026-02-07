import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/db/app_database.dart';
import '../../core/db/db_providers.dart';
import '../../core/repos/plan_repository.dart';
import '../calendar/calendar_providers.dart';
import 'plan_transfer_service.dart';

class PlanQrDisplayDialog extends ConsumerStatefulWidget {
  const PlanQrDisplayDialog({super.key});

  @override
  ConsumerState<PlanQrDisplayDialog> createState() => _PlanQrDisplayDialogState();
}

class _PlanQrDisplayDialogState extends ConsumerState<PlanQrDisplayDialog> {
  DateTimeRange? _selectedRange;
  String? _encodedData;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // デフォルトで今週（月〜日）を選択
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    _selectedRange = DateTimeRange(start: monday, end: sunday);
    
    // 初期データの生成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQrCode();
    });
  }

  Future<void> _generateQrCode() async {
    if (_selectedRange == null) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _encodedData = null;
    });

    try {
      final repo = ref.read(planRepositoryProvider);
      // 期間指定でプランを取得（リポジトリにメソッドがない場合はフィルタリングする必要があるが、
      // ここでは簡易的に全取得してからフィルタリングするか、リポジトリに追加するか。
      // パフォーマンスを考慮して期間指定メソッドを利用したいが、既存にあるか確認。
      // listPlansByDateは1日分。listPlans(start, end)があるか？
      // db_providers.dart の allPlansProvider から取得してフィルタリングするのが手軽。
      
      final allPlans = await ref.read(allPlansProvider.future);
      
      // 期間でフィルタリング
      // DateTimeRangeのendは「含む」かどうか仕様によるが、通常は start <= d < end ではなく start <= d <= end で扱いたい
      // しかし DateTimeRange.duration は end - start。
      // 日付比較は YYYY-MM-DD で行うのが安全。
      
      final plansInRange = allPlans.where((p) {
        final pDate = DateTime(p.date.year, p.date.month, p.date.day);
        final start = DateTime(_selectedRange!.start.year, _selectedRange!.start.month, _selectedRange!.start.day);
        final end = DateTime(_selectedRange!.end.year, _selectedRange!.end.month, _selectedRange!.end.day);
        return pDate.compareTo(start) >= 0 && pDate.compareTo(end) <= 0;
      }).toList();

      if (plansInRange.isEmpty) {
        setState(() {
          _errorMessage = '指定期間に計画がありません';
          _isLoading = false;
        });
        return;
      }

      // エンコード
      final service = ref.read(planTransferServiceProvider);
      final encoded = service.encodePlans(plansInRange);
      
      setState(() {
        _encodedData = encoded;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = '生成に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      helpText: '共有する期間を選択',
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
      _generateQrCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('計画を共有 (QRコード)'),
      content: SingleChildScrollView( // 画面が小さい場合にスクロール可能に
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 中央揃え
          children: [
            const Text(
              'このQRコードを選手のアプリで読み取ると、\n計画データが転送されます。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // 期間選択ボタン
            OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(_selectedRange == null 
                ? '期間を選択' 
                : '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}'),
            ),
            const SizedBox(height: 16),
        
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage.isNotEmpty)
              SizedBox(
                height: 200,
                child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))),
              )
            else if (_encodedData != null)
              Column(
                children: [
                   Container(
                    width: 280, // 固定幅
                    height: 280, // 固定高さ
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: QrImageView(
                        data: _encodedData!,
                        version: QrVersions.auto,
                        size: 240,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.L, // データ量確保のため低めに設定
                      ),
                    ),
                  ),
                   const SizedBox(height: 8),
                   Text(
                     'データサイズ: ${_encodedData!.length} bytes',
                     style: const TextStyle(fontSize: 10, color: Colors.grey),
                   ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.month}/${d.day}';
  }
}
