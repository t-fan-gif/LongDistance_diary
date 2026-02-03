import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routing/app_router.dart';

void main() {
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
