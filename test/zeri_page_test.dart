import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/qimen/qimen_page.dart';
import 'package:qimen/zeri/zeri_engine.dart';
import 'package:qimen/zeri/zeri_models.dart';
import 'package:qimen/zeri/zeri_page.dart';

void main() {
  testWidgets('首页左上角进入择日', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: QimenPage()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('qimen_zeri_button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('qimen_zeri_button')));
    await tester.pumpAndSettle();

    expect(find.text('择日'), findsOneWidget);
    expect(find.byKey(const ValueKey('zeri_bureau_button')), findsOneWidget);
    expect(find.text('火局'), findsOneWidget);
  });

  testWidgets('木局感叹号时辰可选，金局切记时辰不可选', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ZeriPage(
          initialYear: 2019,
          initialMonth: 4,
          initialBureau: SittingBureau.wood,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('4月'), findsOneWidget);
    expect(find.text('2019年'), findsOneWidget);
    expect(find.textContaining(zeriCautionMark), findsWidgets);

    await tester.ensureVisible(
      find.byKey(const ValueKey('zeri_day_2019-04-18')),
    );
    await tester.tap(find.byKey(const ValueKey('zeri_day_2019-04-18')));
    await tester.pumpAndSettle();
    expect(find.text('三月十四'), findsOneWidget);
    expect(find.textContaining('己亥猪年'), findsOneWidget);
    expect(find.textContaining('戊辰月'), findsOneWidget);
    expect(find.textContaining('乙酉日'), findsOneWidget);
    expect(find.textContaining('宜'), findsWidgets);
    expect(find.textContaining('纳采'), findsOneWidget);
    expect(find.textContaining('开市'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('zeri_bureau_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zeri_bureau_metal')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.textContaining('丙戌时').first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('丙戌时').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('已选'), findsNothing);

    await tester.ensureVisible(find.textContaining('庚辰时').first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('庚辰时').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('已选'), findsOneWidget);
    expect(find.textContaining('庚辰时'), findsWidgets);
  });

  testWidgets('不可选的日子点开能看到原因', (tester) async {
    final board = ZeriEngine.buildSolar(
      year: 2019,
      month: 4,
      bureau: SittingBureau.metal,
    );
    final blocked = board.days.firstWhere((day) => day.course == null);

    await tester.pumpWidget(
      const MaterialApp(
        home: ZeriPage(
          initialYear: 2019,
          initialMonth: 4,
          initialBureau: SittingBureau.metal,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(ValueKey('zeri_day_${blocked.solarText}')),
    );
    await tester.tap(find.byKey(ValueKey('zeri_day_${blocked.solarText}')));
    await tester.pumpAndSettle();

    expect(find.text(blocked.unusableReason!), findsOneWidget);
    expect(find.textContaining('已选'), findsNothing);

    final mark = tester.widget<Container>(
      find.byKey(ValueKey('zeri_day_mark_${blocked.solarText}')),
    );
    final decoration = mark.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFD6E3F8));
  });

  testWidgets('忌丁月里的月生日用琥珀色', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ZeriPage(
          initialYear: 2026,
          initialMonth: 10,
          initialBureau: SittingBureau.water,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final markKey = const ValueKey('zeri_day_mark_2026-10-04');
    await tester.ensureVisible(find.byKey(markKey));
    Text number() {
      return tester.widget<Text>(
        find.descendant(of: find.byKey(markKey), matching: find.text('4')),
      );
    }

    expect(number().style?.color, const Color(0xFFC47B2B));

    await tester.tap(find.byKey(const ValueKey('zeri_day_2026-10-04')));
    await tester.pumpAndSettle();

    final mark = tester.widget<Container>(find.byKey(markKey));
    final decoration = mark.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFC47B2B));
    expect(number().style?.color, Colors.white);
    expect(find.textContaining('这一天是月生日'), findsOneWidget);
  });
}
