import 'package:flutter/material.dart';

import 'qimen/qimen_page.dart';

void main() {
  runApp(const QimenApp());
}

class QimenApp extends StatelessWidget {
  const QimenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A5A2B),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'qimen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6EEDB),
        useMaterial3: true,
      ),
      home: const QimenPage(),
    );
  }
}
