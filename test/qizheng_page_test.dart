import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/qizheng/qizheng_page.dart';

void main() {
  testWidgets('七政四余页可正常渲染并可点击复制', (tester) async {
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

    await tester.pumpWidget(
      const MaterialApp(home: QizhengPage()),
    );

    await tester.pumpAndSettle();

    final initialException = tester.takeException();
    expect(initialException, isNull, reason: '$initialException');

    expect(find.text('七政四余'), findsOneWidget);
    expect(find.text('圆盘总览'), findsOneWidget);
    expect(find.text('排盘参数'), findsNothing);
    expect(find.text('校准摘要'), findsNothing);
    expect(find.text('二十八宿'), findsNothing);
    expect(find.text('校准要点'), findsNothing);
    expect(find.text('黄道分布'), findsNothing);
    expect(find.text('十二命宫'), findsNothing);
    expect(find.text('命盘信息层'), findsNothing);

    await tester.tap(find.byTooltip('排盘参数'));
    await tester.pumpAndSettle();

    expect(find.text('排盘参数'), findsOneWidget);
    expect(find.text('重排七政四余校准盘'), findsOneWidget);

    Navigator.of(tester.element(find.text('排盘参数'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.copy_all_rounded));
    await tester.pump();

    final copyException = tester.takeException();
    expect(copyException, isNull, reason: '$copyException');
    expect(find.text('七政四余校准盘信息已复制'), findsOneWidget);
    expect(copiedText, isNotNull);
    expect(copiedText, contains('【七政四余校准盘】'));
    expect(copiedText, contains('命度：'));
    expect(copiedText, contains('身度：'));
    expect(copiedText, contains('宿度：'));
    expect(copiedText, contains('值日宿：'));
    expect(copiedText, isNot(contains('角点：ASC')));
    expect(copiedText, isNot(contains('主要相位：')));

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });
}
