import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/qimen/qimen_page.dart';

void main() {
  testWidgets('奇门页支持分开选择年月日且年份可到1980', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QimenPage()));
    await tester.pumpAndSettle();

    final initialException = tester.takeException();
    expect(initialException, isNull, reason: '$initialException');

    expect(find.text('奇门遁甲排盘器'), findsOneWidget);
    expect(find.byKey(const ValueKey('qimen_year_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('qimen_month_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('qimen_day_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('qimen_year_button')));
    await tester.pumpAndSettle();

    expect(find.text('选择年份'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('1980年'),
      -400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('1980年'));
    await tester.pumpAndSettle();

    expect(find.text('年 1980'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('qimen_month_button')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('2月'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('2月'));
    await tester.pumpAndSettle();

    expect(find.text('月 02'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('qimen_day_button')));
    await tester.pumpAndSettle();

    expect(find.text('选择日期'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('29日'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('29日'), findsOneWidget);
    expect(find.text('30日'), findsNothing);

    await tester.tap(find.text('29日'));
    await tester.pumpAndSettle();

    expect(find.text('日 29'), findsOneWidget);
    expect(find.textContaining('1980-02-29'), findsOneWidget);
  });
}
