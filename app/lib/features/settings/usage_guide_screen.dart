import 'package:flutter/material.dart';

class UsageGuideScreen extends StatefulWidget {
  const UsageGuideScreen({super.key});

  @override
  State<UsageGuideScreen> createState() => _UsageGuideScreenState();
}

class _UsageGuideScreenState extends State<UsageGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_GuideItem> _guides = [
    _GuideItem(
      title: '毎日の記録',
      description: '「今日」タブの + ボタンから、日々のランニングやウォーキングの実績を記録しましょう。\n\n距離、時間、セット数などを入力して保存すると、カレンダーに自動で反映されます。',
      icon: Icons.directions_run_rounded,
      color: Colors.orange,
    ),
    _GuideItem(
      title: '目標を立てる',
      description: '「設定」>「走行距離目標」から、月間や週間の目標距離を設定できます。\n\n目標に対する進捗状況がグラフで可視化され、モチベーション維持に役立ちます。',
      icon: Icons.flag_rounded,
      color: Colors.blue,
    ),
    _GuideItem(
      title: 'レース管理',
      description: '「設定」>「ターゲットレース」で、出場予定のレースを登録できます。\n\nカウントダウンや、レースごとの目標タイム管理が可能です。',
      icon: Icons.emoji_events_rounded,
      color: Colors.amber,
    ),
    _GuideItem(
      title: 'データのバックアップ',
      description: '「設定」>「データ管理」から、記録データをJSON形式でエクスポートできます。\n\n機種変更時など、大切なデータを守るために定期的なバックアップをお勧めします。',
      icon: Icons.save_alt_rounded,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使い方ガイド'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _guides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = _guides[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 80,
                              color: item.color,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_guides.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _GuideItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
