import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'routing/app_router.dart';

void main() {
  // Webの場合、ハッシュモードを使用してブラウザ履歴問題を解消
  usePathUrlStrategy();
  runApp(const ProviderScope(child: LongDistanceDiaryApp()));
}

class LongDistanceDiaryApp extends ConsumerWidget {
  const LongDistanceDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'LongDistance Diary',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      routerConfig: appRouter,
    );
  }
}
