import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/qizheng/qizheng_engine.dart';
import 'package:qimen/qizheng/qizheng_models.dart';

void main() {
  test('七政四余基础星历保持稳定', () {
    final chart = QizhengEngine.generateFromInput(
      QizhengInput(
        localDateTime: DateTime.utc(2000, 1, 1, 12),
        locationLabel: 'UTC',
        longitude: 0,
        latitude: 0,
        utcOffsetMinutes: 0,
      ),
    );

    expect(chart.positions, hasLength(11));
    expect(chart.lunarDateText, equals('一九九九年冬月廿五'));
    expect(chart.ganzhiText, equals('己卯 丙子 戊午 戊午'));

    final sun = chart.positionOf(QizhengBody.sun);
    final moon = chart.positionOf(QizhengBody.moon);
    final mercury = chart.positionOf(QizhengBody.mercury);
    final saturn = chart.positionOf(QizhengBody.saturn);

    expect(sun.sign, equals(QizhengZodiacSign.capricorn));
    expect(sun.longitude, closeTo(280.38, 0.2));
    expect(moon.sign, equals(QizhengZodiacSign.scorpio));
    expect(moon.longitude, closeTo(223.35, 0.3));
    expect(mercury.sign, equals(QizhengZodiacSign.capricorn));
    expect(mercury.longitude, closeTo(271.90, 0.3));

    expect(saturn.sign, equals(QizhengZodiacSign.taurus));
    expect(saturn.motion, equals(QizhengBodyMotion.stationary));

    expect(
      QizhengEngine.dominantSignsText(chart),
      equals('射手2曜 · 摩羯2曜 · 水瓶2曜'),
    );
    expect(QizhengEngine.retrogradeText(chart), equals('罗喉、计都'));
  });

  test('四余基础关系与主要相位成立', () {
    final chart = QizhengEngine.generateFromInput(
      QizhengInput(
        localDateTime: DateTime.utc(2000, 1, 1, 12),
        locationLabel: 'UTC',
        longitude: 0,
        latitude: 0,
        utcOffsetMinutes: 0,
      ),
    );
    final luoHou = chart.positionOf(QizhengBody.luoHou);
    final jiDu = chart.positionOf(QizhengBody.jiDu);
    final yueBei = chart.positionOf(QizhengBody.yueBei);
    final ziQi = chart.positionOf(QizhengBody.ziQi);

    expect(_angularDistance(luoHou.longitude, jiDu.longitude), closeTo(180, 0.01));
    expect(luoHou.isRetrograde, isTrue);
    expect(jiDu.isRetrograde, isTrue);
    expect(yueBei.motion, equals(QizhengBodyMotion.direct));
    expect(ziQi.motion, equals(QizhengBodyMotion.direct));
    expect(yueBei.longitude, closeTo(263.35, 0.2));
    expect(ziQi.longitude, closeTo(188.73, 0.2));

    expect(chart.aspects.first.type, equals(QizhengAspectType.opposition));
    expect(chart.aspects.first.leftBody, equals(QizhengBody.luoHou));
    expect(chart.aspects.first.rightBody, equals(QizhengBody.jiDu));
    expect(chart.aspects.first.orb, closeTo(0, 0.01));
  });

  test('角点和等宫结果与公开示例接近', () {
    final chart = QizhengEngine.generateFromInput(
      QizhengInput(
        localDateTime: DateTime.utc(2016, 11, 2, 21, 17, 30),
        locationLabel: 'Enschede',
        longitude: 6.9,
        latitude: 52.2167,
        utcOffsetMinutes: 0,
      ),
    );

    expect(chart.localSiderealTime, closeTo(8.8483, 0.05));
    expect(chart.midheavenLongitude, closeTo(9.6291, 0.2));
    expect(chart.ascendantLongitude, closeTo(123.5081, 0.3));

    expect(chart.houseOf(1).cuspLongitude, closeTo(chart.ascendantLongitude, 0.001));
    expect(
      chart.houseOf(10).cuspLongitude,
      closeTo((chart.ascendantLongitude + 270) % 360, 0.001),
    );
  });

  test('七政四余复制文本包含关键字段', () {
    final chart = QizhengEngine.generateFromInput(
      QizhengInput(
        localDateTime: DateTime(2000, 1, 1, 12),
        locationLabel: '上海',
        longitude: 121.4737,
        latitude: 31.2304,
        utcOffsetMinutes: 480,
      ),
    );
    final text = QizhengEngine.generateCopyText(chart);

    expect(chart.xiuInfo.fullName, equals('胃土彘'));
    expect(chart.xiuInfo.guardian, equals('白虎'));
    expect(chart.xiuInfo.luck, equals('吉'));
    expect(
      QizhengEngine.branchTextOfLongitude(chart.ascendantLongitude),
      equals('戌宫 17°01′'),
    );
    expect(QizhengEngine.bodyPalaceText(chart), equals('夫妻 7宫'));
    expect(QizhengEngine.fateDegreeText(chart), equals('戌宫 10°03′'));
    expect(QizhengEngine.bodyDegreeText(chart), equals('卯宫 09°20′'));
    expect(QizhengEngine.lodgingDegreeText(chart), equals('胃土彘 · 吉'));
    expect(text, contains('【七政四余校准盘】'));
    expect(text, contains('地点：上海'));
    expect(text, contains('命宫起度：戌宫 17°01′'));
    expect(text, contains('身宫：夫妻 7宫'));
    expect(text, contains('命度：戌宫 10°03′'));
    expect(text, contains('身度：卯宫 09°20′'));
    expect(text, contains('宿度：胃土彘 · 吉'));
    expect(text, contains('值日宿：西方白虎 · 胃土彘 · 吉'));
    expect(text, contains('十一曜躔次：'));
    expect(text, contains('值宿宿辞：胃星造作事如何'));
    expect(text, isNot(contains('角点：ASC')));
    expect(text, isNot(contains('主要相位：')));
    expect(text, contains('说明：当前版本先收口为圆盘校准盘'));
  });

  test('四柱化曜与基础批注可生成', () {
    final chart = QizhengEngine.generateFromInput(
      QizhengInput(
        localDateTime: DateTime(1994, 4, 7, 16, 14),
        locationLabel: '上海',
        longitude: 121.4737,
        latitude: 31.2304,
        utcOffsetMinutes: 480,
      ),
    );

    final pillars = QizhengEngine.pillarsOf(chart);
    final transforms = QizhengEngine.transformationsOf(chart);
    final patterns = QizhengEngine.patternTexts(chart);
    final notes = QizhengEngine.noteTexts(chart);

    expect(pillars, hasLength(4));
    expect(transforms, hasLength(4));
    expect(chart.xiuInfo.fullName, isNotEmpty);
    expect(transforms.first.pillarLabel, equals('年柱'));
    expect(transforms.first.role, isNotEmpty);
    expect(transforms.first.domain, isNotEmpty);
    expect(patterns, isNotEmpty);
    expect(notes, isNotEmpty);
  });
}

double _angularDistance(double left, double right) {
  final normalized = ((left - right).abs()) % 360;
  return normalized > 180 ? 360 - normalized : normalized;
}
