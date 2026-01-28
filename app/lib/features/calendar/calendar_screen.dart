import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: const Center(
        child: Text('MVP: カレンダー表示（負荷の濃淡）はここから実装します'),
      ),
    );
  }
}

