import 'package:dart_iztro/dart_iztro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/ziwei/ziwei_engine.dart';
import 'package:qimen/ziwei/ziwei_models.dart';

void main() {
  test('年份列表保留完整支持范围', () {
    final years = ZiweiEngine.yearOptions();

    expect(years.first, equals(ZiweiEngine.minSupportedYear));
    expect(years.last, equals(ZiweiEngine.maxSupportedYear));
    expect(years, contains(ZiweiEngine.defaultVisibleYear));
  });

  test('紫微斗数基础农历排盘正确', () {
    ZiweiEngine.ensureInitialized();

    const input = ZiweiBirthInput(
      lunarYear: 1990,
      lunarMonth: 1,
      lunarDay: 1,
      timeIndex: 0,
      gender: ZiweiGender.male,
    );

    final chart = ZiweiEngine.buildChart(input);
    final soulPalace = chart.palace(0)!;
    final spousePalace = chart.palace(10)!;
    final careerPalace = chart.palace(4)!;

    expect(chart.solarDate, equals('1990-01-27'));
    expect(chart.lunarDate, equals('一九九〇年正月初一'));
    expect(chart.chineseDate, equals('己巳 丁丑 壬辰 庚子'));
    expect(chart.fiveElementClass.title, equals('火六局'));

    expect(soulPalace.name.title, equals('命宫'));
    expect(ZiweiEngine.majorStarsText(soulPalace), equals('空宫'));

    expect(spousePalace.name.title, equals('夫妻'));
    expect(ZiweiEngine.majorStarsText(spousePalace), equals('天梁'));
    expect(ZiweiEngine.denseSupportStarsText(spousePalace), isNotEmpty);
    expect(
      ZiweiEngine.palaceFlagsText(soulPalace),
      contains(soulPalace.jiangQian12.title),
    );
    expect(
      ZiweiEngine.palaceFlagsText(soulPalace),
      contains(soulPalace.suiQian12.title),
    );

    final flyTargets = ZiweiEngine.flyTargetsOf(careerPalace);
    expect(
      flyTargets.map((item) => item.targetName).toList(),
      equals(['官禄', '田宅', '迁移', '福德']),
    );

    final surrounded = ZiweiEngine.surroundedIndexes(chart, soulPalace.index);
    expect(surrounded, equals([0, 6, 8, 4]));
  });

  test('紫微四化摘要保持稳定', () {
    ZiweiEngine.ensureInitialized();

    const input = ZiweiBirthInput(
      lunarYear: 1990,
      lunarMonth: 1,
      lunarDay: 1,
      timeIndex: 0,
      gender: ZiweiGender.male,
    );

    final chart = ZiweiEngine.buildChart(input);
    final mutagens = ZiweiEngine.collectMutagenSummaries(chart);

    expect(
      mutagens.map((item) => item.label).toList(),
      equals(['禄', '权', '科', '忌']),
    );
    expect(
      mutagens.map((item) => item.starName).toList(),
      equals(['武曲', '贪狼', '天梁', '文曲']),
    );
    expect(
      mutagens.map((item) => item.palaceName).toList(),
      equals(['田宅', '疾厄', '夫妻', '福德']),
    );
  });

  test('紫微运限摘要保持稳定', () {
    ZiweiEngine.ensureInitialized();

    const input = ZiweiBirthInput(
      lunarYear: 1990,
      lunarMonth: 1,
      lunarDay: 1,
      timeIndex: 0,
      gender: ZiweiGender.male,
    );

    final chart = ZiweiEngine.buildChart(input);
    final horoscope = ZiweiEngine.buildHoroscope(
      chart,
      DateTime(2026, 4, 8, 10, 0),
    );

    expect(horoscope.age.nominalAge, equals(37));
    expect(chart.palace(horoscope.age.index)?.name.title, equals('仆役'));

    expect(horoscope.decadal.heavenlyStem.title, equals('乙'));
    expect(horoscope.decadal.earthlyBranch.title, equals('亥'));
    expect(chart.palace(horoscope.decadal.index)?.name.title, equals('子女'));

    expect(horoscope.yearly.heavenlyStem.title, equals('丙'));
    expect(horoscope.yearly.earthlyBranch.title, equals('午'));
    expect(chart.palace(horoscope.yearly.index)?.name.title, equals('官禄'));

    expect(horoscope.monthly.heavenlyStem.title, equals('壬'));
    expect(horoscope.monthly.earthlyBranch.title, equals('辰'));
    expect(chart.palace(horoscope.monthly.index)?.name.title, equals('仆役'));

    expect(horoscope.daily.heavenlyStem.title, equals('壬'));
    expect(horoscope.daily.earthlyBranch.title, equals('子'));
    expect(chart.palace(horoscope.daily.index)?.name.title, equals('父母'));

    expect(horoscope.hourly.heavenlyStem.title, equals('乙'));
    expect(horoscope.hourly.earthlyBranch.title, equals('巳'));
    expect(chart.palace(horoscope.hourly.index)?.name.title, equals('迁移'));

    expect(
      ZiweiEngine.scopePalaceTitleAt(
        ZiweiDisplayScope.yearly,
        horoscope,
        horoscope.yearly.index,
      ),
      equals('命宫'),
    );
    expect(
      ZiweiEngine.mappedPalaceForScope(
        ZiweiDisplayScope.yearly,
        horoscope,
        PalaceName.soulPalace,
      )?.name.title,
      equals('官禄'),
    );
    expect(
      ZiweiEngine.mappedPalaceForScope(
        ZiweiDisplayScope.age,
        horoscope,
        PalaceName.soulPalace,
      )?.name.title,
      equals('仆役'),
    );
  });
}
