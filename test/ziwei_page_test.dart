import 'package:dart_iztro/dart_iztro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qimen/ziwei/ziwei_page.dart';

void main() {
  testWidgets('紫微页可正常渲染并可点击复制', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final arguments = call.arguments as Map<dynamic, dynamic>?;
          copiedText = arguments?['text'] as String?;
        }
        return null;
      },
    );

    IztroTranslationService.init(initialLocale: 'zh_CN');
    Get.addTranslations(IztroTranslationService.withAppTranslations().keys);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: IztroTranslationService.withAppTranslations(),
        locale: IztroTranslationService.currentLocale,
        fallbackLocale: const Locale('zh', 'CN'),
        home: const ZiweiPage(),
      ),
    );

    await tester.pumpAndSettle();

    final initialException = tester.takeException();
    expect(initialException, isNull, reason: '$initialException');

    expect(find.text('紫微斗数排盘器'), findsOneWidget);
    expect(find.text('紫微命盘'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.copy_all_rounded));
    await tester.pump();

    final copyException = tester.takeException();
    expect(copyException, isNull, reason: '$copyException');
    expect(find.text('紫微斗数排盘信息已复制'), findsOneWidget);
    expect(copiedText, isNotNull);
    expect(copiedText, contains('【紫微斗数排盘】'));
    expect(copiedText, contains('命主：'));
    expect(copiedText, contains(RegExp(r'\d+~\d+岁')));
    expect(copiedText, isNot(contains('参考：')));
    expect(copiedText, isNot(contains('大限：')));
    expect(copiedText, isNot(contains('小限：')));
    expect(copiedText, isNot(contains('流年：')));
    expect(copiedText, isNot(contains('流月：')));
    expect(copiedText, isNot(contains('流日：')));
    expect(copiedText, isNot(contains('流时：')));

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });
}
