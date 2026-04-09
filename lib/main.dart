import 'package:dart_iztro/dart_iztro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'qimen/qimen_page.dart';
import 'ziwei/ziwei_engine.dart';

void main() {
  ZiweiEngine.ensureInitialized();
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

    return GetMaterialApp(
      title: '奇门紫薇',
      debugShowCheckedModeBanner: false,
      translations: IztroTranslationService.withAppTranslations(),
      locale: IztroTranslationService.currentLocale,
      fallbackLocale: const Locale('zh', 'CN'),
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6EEDB),
        useMaterial3: true,
      ),
      home: const QimenPage(),
    );
  }
}
