import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/qimen/qimen_engine.dart';
import 'package:qimen/qimen/qimen_models.dart';

void main() {
  test('验证 2026年4月3日 14:07 的排盘结果（自动计算局数）', () {
    final dateTime = DateTime(2026, 4, 3, 14, 7);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月3日 14:07 排盘结果 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('三元: ${pan.yuan}');
    print('局数: ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('值符: ${pan.valueStar}');
    print('值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('节气: ${pan.solarTerm}');
    print('时辰: ${pan.hourLabel}');
    print('=============================');

    // 验证四柱
    expect(pan.yearGanzhi, equals('丙午'));
    expect(pan.monthGanzhi, equals('辛卯'));
    expect(pan.dayGanzhi, equals('丁未'));
    expect(pan.hourGanzhi, equals('丁未'));

    // 验证三元（甲辰旬，辰属四季，为下元）
    expect(pan.yuan, equals('下元'));

    // 验证局数（春分下元阳遁6局）
    expect(pan.bureau, equals(6));
    expect(pan.dunType, equals(QimenDunType.yang));

    // 验证旬首 (丁未日，距甲辰3位，所以旬首是甲辰)
    expect(pan.xunShou, equals('甲辰'));
    expect(pan.xunYi, equals('壬'));

    // 验证值符值使
    expect(pan.valueStar, equals('天蓬'));
    expect(pan.valueGate, equals('休门'));

    // 验证马星 (未时，亥卯未马在巳)
    expect(pan.horseStar, equals('巳'));

    // 输出九宫详细信息
    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      print('${cell.palaceName}: 神=${cell.deity}, 星=${cell.star}, 门=${cell.gate}, 天盘=${cell.heavenStem}, 地盘=${cell.earthStem}');
    }
    print('====================');

    // 验证离9宫（参考图：太阴、天冲、生门）
    final li9 = pan.cells.firstWhere((c) => c.palaceNumber == 9);
    print('\n离9宫验证: 神=${li9.deity}, 星=${li9.star}, 门=${li9.gate}');
  });

  test('验证 2026年4月3日 15:28 申时排盘（与参考图对比）', () {
    final dateTime = DateTime(2026, 4, 3, 15, 28);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月3日 15:28 申时排盘 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('三元: ${pan.yuan}');
    print('局数: ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar}');
    print('值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('戊申')); // 申时
    expect(pan.kongWang, equals('寅卯'));   // 甲辰旬空亡寅卯
    expect(pan.valueStar, equals('天蓬'));
    expect(pan.valueGate, equals('休门'));
    expect(pan.horseStar, equals('寅'));    // 申寅相冲

    print('\n===== 九宫排盘对比参考图 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final heavenText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.heavenStem}' : cell.heavenStem;
      final earthText = cell.hasTianQinStem ? '${cell.tianQinStem}${cell.earthStem}' : cell.earthStem;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天$heavenText 地$earthText$kongText');
    }
    print('=============================');
    
    // 参考图各宫验证
    // 乾6宫：玄武、丙芮禽乙癸、开门辛
    final qian6 = pan.cells.firstWhere((c) => c.palaceNumber == 6);
    print('\n乾6宫: ${qian6.deity}, ${qian6.star}, ${qian6.gate}, 天${qian6.heavenStem}, 地${qian6.earthStem}');
  });

  test('验证 2026年4月3日 19:39 戌时排盘', () {
    final dateTime = DateTime(2026, 4, 3, 19, 39);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月3日 19:39 戌时排盘 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 验证时柱
    expect(pan.hourGanzhi, equals('庚戌'));
    // 马星：戌时（寅午戌马在申）
    expect(pan.horseStar, equals('申'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2026年4月2日 06:44 卯时排盘', () {
    final dateTime = DateTime(2026, 4, 2, 6, 44);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月2日 06:44 卯时排盘 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('辛卯'));
    expect(pan.xunShou, equals('甲申'));
    expect(pan.valueStar, equals('天任'));
    expect(pan.valueGate, equals('生门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2026年11月3日 15:50 申时（阴5局）', () {
    final dateTime = DateTime(2026, 11, 3, 15, 50);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年11月3日 15:50 申时（阴5局）=====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 验证（辛巳在六十甲子第17位，第4组，上元，霜降上元阴5局）
    expect(pan.hourGanzhi, equals('丙申'));
    expect(pan.dunType, equals(QimenDunType.yin));
    expect(pan.bureau, equals(5));
    expect(pan.xunShou, equals('甲午'));
    expect(pan.valueStar, equals('天芮'));
    expect(pan.valueGate, equals('死门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2024年4月1日 15:49 申时（阳3局）', () {
    final dateTime = DateTime(2024, 4, 1, 15, 49);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2024年4月1日 15:49 申时（阳3局）=====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('甲申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(3));
    expect(pan.xunShou, equals('甲申'));
    expect(pan.valueStar, equals('天禽'));
    expect(pan.valueGate, equals('死门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2019年4月3日 16:03 申时（阳9局）', () {
    final dateTime = DateTime(2019, 4, 3, 16, 3);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2019年4月3日 16:03 申时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 验证（庚午在六十甲子第6位，第2组，中元，春分中元阳9局）
    expect(pan.hourGanzhi, equals('甲申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(9));
    expect(pan.xunShou, equals('甲申'));
    expect(pan.valueStar, equals('天芮'));
    expect(pan.valueGate, equals('死门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2022年8月3日 16:04 申时（阴1局）', () {
    final dateTime = DateTime(2022, 8, 3, 16, 4);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2022年8月3日 16:04 申时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('庚申'));
    expect(pan.dunType, equals(QimenDunType.yin));
    expect(pan.bureau, equals(1));
    expect(pan.xunShou, equals('甲寅'));
    expect(pan.valueStar, equals('天禽'));
    expect(pan.valueGate, equals('死门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2026年6月3日 16:03 申时（阳8局）', () {
    final dateTime = DateTime(2026, 6, 3, 16, 3);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年6月3日 16:03 申时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('庚申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(8));
    expect(pan.xunShou, equals('甲寅'));
    expect(pan.valueStar, equals('天辅'));
    expect(pan.valueGate, equals('杜门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2027年4月3日 16:07 申时（阳3局）', () {
    final dateTime = DateTime(2027, 4, 3, 16, 7);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2027年4月3日 16:07 申时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 验证（壬子在六十甲子第48位，第10组，上元，春分上元阳3局）
    expect(pan.hourGanzhi, equals('戊申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(3));
    expect(pan.xunShou, equals('甲辰'));
    expect(pan.valueStar, equals('天柱'));
    expect(pan.valueGate, equals('惊门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2029年4月3日 16:28 申时（阳6局）', () {
    final dateTime = DateTime(2029, 4, 3, 16, 28);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2029年4月3日 16:28 申时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('庚申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(6));
    expect(pan.xunShou, equals('甲寅'));
    expect(pan.valueStar, equals('天芮'));
    expect(pan.valueGate, equals('死门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });

  test('验证 2026年4月21日 17:46 酉时（阳5局）', () {
    final dateTime = DateTime(2026, 4, 21, 17, 46);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月21日 17:46 酉时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('');
    print('===== 九宫八门 =====');
    for (final cell in pan.cells) {
      print('${cell.palaceName}: ${cell.gate}');
    }
    print('=============================');
    
    // 参考图验证
    expect(pan.bureau, equals(5));
    expect(pan.valueStar, equals('天柱'));
    expect(pan.valueGate, equals('惊门'));
  });

  test('验证 2026年4月8日 17:36 酉时', () {
    final dateTime = DateTime(2026, 4, 8, 17, 36);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月8日 17:36 酉时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('');
    print('===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final deityText = cell.deity == '值符' ? '值符' : cell.deity;
      print('${cell.palaceName}: $deityText | $starText | ${cell.gate}');
    }
    print('=============================');
  });

  test('验证 2026年4月5日 17:28 酉时', () {
    final dateTime = DateTime(2026, 4, 5, 17, 28);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2026年4月5日 17:28 酉时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('');
    print('===== 九宫八门 =====');
    for (final cell in pan.cells) {
      print('${cell.palaceName}: ${cell.gate}');
    }
    print('=============================');
  });

  test('验证 2029年4月19日 16:33 申时（阳4局）', () {
    final dateTime = DateTime(2029, 4, 19, 16, 33);
    final pan = QimenEngine.generate(
      dateTime: dateTime,
      manualDunType: null,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: null,
      useAutoBureau: true,
    );

    print('===== 2029年4月19日 16:33 申时 =====');
    print('四柱: ${pan.yearGanzhi} ${pan.monthGanzhi} ${pan.dayGanzhi} ${pan.hourGanzhi}');
    print('局数: ${pan.yuan} ${pan.dunType.label}${pan.bureau}局');
    print('旬首: ${pan.xunShou}${pan.xunYi}');
    print('空亡: ${pan.kongWang}');
    print('值符: ${pan.valueStar} 值使: ${pan.valueGate}');
    print('马星: ${pan.horseStar}');
    print('=============================');

    // 参考图验证
    expect(pan.hourGanzhi, equals('壬申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(4));
    expect(pan.xunShou, equals('甲子'));
    expect(pan.valueStar, equals('天辅'));
    expect(pan.valueGate, equals('杜门'));

    print('\n===== 九宫排盘 =====');
    for (final cell in pan.cells) {
      final starText = cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star;
      final kongText = cell.isKongWang ? ' [空]' : '';
      print('${cell.palaceName}: ${cell.deity} | $starText | ${cell.gate} | 天${cell.heavenStem} 地${cell.earthStem}$kongText');
    }
    print('=============================');
  });
}
