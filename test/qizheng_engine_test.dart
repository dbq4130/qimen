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

    expect(
      _angularDistance(luoHou.longitude, jiDu.longitude),
      closeTo(180, 0.01),
    );
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

    expect(
      chart.houseOf(1).cuspLongitude,
      closeTo(chart.ascendantLongitude, 0.001),
    );
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
    expect(QizhengEngine.fatePalaceText(chart), equals('辰宫'));
    expect(QizhengEngine.bodyPalaceText(chart), equals('财帛 卯宫'));
    expect(QizhengEngine.fateDegreeText(chart), equals('角木蛟 2度09分'));
    expect(QizhengEngine.bodyDegreeText(chart), equals('氐土貉 10度38分'));
    expect(QizhengEngine.lodgingDegreeText(chart), equals('斗木獬 13度45分 水分金'));
    expect(QizhengEngine.fateMasterText(chart), equals('太阳'));
    expect(QizhengEngine.bodyMasterText(chart), equals('太阴'));
    expect(QizhengEngine.palaceMasterText(chart), equals('金星'));
    expect(QizhengEngine.degreeMasterText(chart), equals('木星'));
    expect(QizhengEngine.bodyDegreeMasterText(chart), equals('土星'));
    expect(QizhengEngine.dayNightText(chart), equals('昼生'));
    expect(QizhengEngine.masterFocusText(chart), equals('昼生重命度主木星'));
    expect(
      QizhengEngine.palaceDegreeCommentary(chart).first,
      equals('宫主金星居兄弟弱宫，度主木星居夫妻强宫。'),
    );
    expect(text, contains('【七政四余校准盘】'));
    expect(text, contains('地点：上海'));
    expect(text, contains('命宫：辰宫'));
    expect(text, contains('身宫：财帛 卯宫'));
    expect(text, contains('命度：角木蛟 2度09分'));
    expect(text, contains('身度：氐土貉 10度38分'));
    expect(text, contains('宿度：斗木獬 13度45分 水分金'));
    expect(text, contains('命主：太阳'));
    expect(text, contains('身主：太阴'));
    expect(text, contains('宫主：金星'));
    expect(text, contains('度主：木星'));
    expect(text, contains('身度主：土星'));
    expect(text, contains('主看：昼生重命度主木星'));
    expect(text, contains('宫度主论：'));
    expect(text, contains('宫主金星居兄弟弱宫，度主木星居夫妻强宫。'));
    expect(text, contains('宫主与度主五行金克木；依宫度主论，这类情形宜先守度主，主看木星。'));
    expect(text, contains('值日宿：西方白虎 · 胃土彘 · 吉'));
    expect(text, contains('太阳 落斗木獬13度45分 水分金 入田宅'));
    expect(text, contains('太阴 落氐土貉10度38分 土分金 入财帛'));
    expect(text, contains('十一曜躔次：'));
    expect(text, contains('值宿宿辞：胃星造作事如何'));
    expect(text, isNot(contains('角点：ASC')));
    expect(text, isNot(contains('主要相位：')));
    expect(text, contains('安命度法已接入'));
  });

  test('二十八宿落度与分金按黄道宿度换算', () {
    final ariesStart = QizhengEngine.lodgingOfLongitude(0);
    final taurusStart = QizhengEngine.lodgingOfLongitude(30);
    final libraStart = QizhengEngine.lodgingOfLongitude(180);
    final segments = QizhengEngine.lodgingSegments();

    expect(ariesStart.fullName, equals('奎木狼'));
    expect(ariesStart.degreeText, equals('1度74分'));
    expect(ariesStart.finenessText, equals('水分金'));

    expect(taurusStart.fullName, equals('胃土雉'));
    expect(taurusStart.degreeText, equals('3度75分'));
    expect(taurusStart.finenessText, equals('土分金'));

    expect(libraStart.fullName, equals('轸水蚓'));
    expect(libraStart.degreeText, equals('10度08分'));
    expect(libraStart.finenessText, equals('火分金'));

    expect(segments, hasLength(28));
    expect(
      segments.first.startLongitude,
      lessThan(segments.last.startLongitude),
    );
  });

  test('命宫与命度按生时加太阳宫推得', () {
    final chart = QizhengEngine.generateFromInput(
      QizhengInput(
        localDateTime: DateTime(2000, 1, 1, 12),
        locationLabel: '上海',
        longitude: 121.4737,
        latitude: 31.2304,
        utcOffsetMinutes: 480,
      ),
    );

    expect(QizhengEngine.fatePalaceText(chart), equals('辰宫'));
    expect(
      QizhengEngine.traditionalPalaceTextOfLongitude(
        chart,
        chart.positionOf(QizhengBody.moon).longitude,
      ),
      equals('财帛 卯宫'),
    );
    expect(
      QizhengEngine.formatLongitude(QizhengEngine.fateDegreeLongitude(chart)),
      equals('190°03′'),
    );
    expect(QizhengEngine.fateDegreeText(chart), equals('角木蛟 2度09分'));
    expect(QizhengEngine.palaceMasterText(chart), equals('金星'));
    expect(QizhengEngine.degreeMasterText(chart), equals('木星'));
    expect(
      QizhengEngine.palaceDegreeCommentary(chart),
      contains('身度主土星居疾厄弱宫，可与身宫财帛 卯宫互参。'),
    );
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
