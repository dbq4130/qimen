import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/qimen/qimen_engine.dart';
import 'package:qimen/qimen/qimen_models.dart';

QimenPan _buildPan(DateTime dateTime) {
  return QimenEngine.generate(
    dateTime: dateTime,
    manualDunType: null,
    useAutoDunType: true,
    panMode: QimenPanMode.zhuan,
    setupMethod: QimenSetupMethod.chaibu,
    manualBureau: null,
    useAutoBureau: true,
  );
}

QimenPanCell _cell(QimenPan pan, int palaceNumber) {
  return pan.cells.firstWhere((cell) => cell.palaceNumber == palaceNumber);
}

void main() {
  test('基础自动排盘字段正确', () {
    final pan = _buildPan(DateTime(2026, 4, 3, 14, 7));

    expect(pan.yearGanzhi, equals('丙午'));
    expect(pan.monthGanzhi, equals('辛卯'));
    expect(pan.dayGanzhi, equals('丁未'));
    expect(pan.hourGanzhi, equals('丁未'));
    expect(pan.yuan, equals('下元'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(6));
    expect(pan.xunShou, equals('甲辰'));
    expect(pan.xunYi, equals('壬'));
    expect(pan.valueStar, equals('天蓬'));
    expect(pan.valueGate, equals('休门'));
    expect(pan.horseStar, equals('巳'));

    final li9 = _cell(pan, 9);
    expect(li9.deity, equals('太阴'));
    expect(li9.star, equals('天冲'));
    expect(li9.gate, equals('生门'));
  });

  test('阴遁基础盘保持正确', () {
    final pan = _buildPan(DateTime(2026, 11, 3, 15, 50));

    expect(pan.hourGanzhi, equals('丙申'));
    expect(pan.dunType, equals(QimenDunType.yin));
    expect(pan.bureau, equals(5));
    expect(pan.xunShou, equals('甲午'));
    expect(pan.valueStar, equals('天芮'));
    expect(pan.valueGate, equals('死门'));
    expect(pan.horseStar, equals('寅'));

    final dui7 = _cell(pan, 7);
    expect(dui7.deity, equals('值符'));
    expect(dui7.star, equals('天芮'));
    expect(dui7.gate, equals('开门'));
    expect(dui7.hasTianQinStar, isTrue);
  });

  test('阴遁中宫寄艮逻辑正确', () {
    final pan = _buildPan(DateTime(2022, 8, 3, 16, 4));

    expect(pan.hourGanzhi, equals('庚申'));
    expect(pan.dunType, equals(QimenDunType.yin));
    expect(pan.bureau, equals(1));
    expect(pan.xunShou, equals('甲寅'));
    expect(pan.valueStar, equals('天禽'));
    expect(pan.valueGate, equals('死门'));
    expect(pan.horseStar, equals('寅'));

    final kun2 = _cell(pan, 2);
    final gen8 = _cell(pan, 8);
    expect(kun2.deity, equals('白虎'));
    expect(kun2.star, equals('天芮'));
    expect(kun2.gate, equals('生门'));
    expect(kun2.hasTianQinStar, isTrue);

    expect(gen8.deity, equals('值符'));
    expect(gen8.star, equals('天任'));
    expect(gen8.gate, equals('死门'));
    expect(gen8.hasTianQinStem, isTrue);
    expect(gen8.isHorseStar, isTrue);
  });

  test('阳遁中宫寄坤和马星入宫正确', () {
    final pan = _buildPan(DateTime(2027, 4, 22, 18, 50));

    expect(pan.yearGanzhi, equals('丁未'));
    expect(pan.monthGanzhi, equals('甲辰'));
    expect(pan.dayGanzhi, equals('辛未'));
    expect(pan.hourGanzhi, equals('丁酉'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(2));
    expect(pan.xunShou, equals('甲午'));
    expect(pan.valueStar, equals('天禽'));
    expect(pan.valueGate, equals('死门'));
    expect(pan.horseStar, equals('亥'));

    final xun4 = _cell(pan, 4);
    final li9 = _cell(pan, 9);
    final gen8 = _cell(pan, 8);
    final qian6 = _cell(pan, 6);

    expect(xun4.deity, equals('太阴'));
    expect(xun4.star, equals('天心'));
    expect(xun4.gate, equals('开门'));

    expect(li9.deity, equals('六合'));
    expect(li9.star, equals('天蓬'));
    expect(li9.gate, equals('休门'));

    expect(gen8.deity, equals('值符'));
    expect(gen8.star, equals('天芮'));
    expect(gen8.gate, equals('死门'));
    expect(gen8.hasTianQinStar, isTrue);

    expect(qian6.deity, equals('九地'));
    expect(qian6.star, equals('天辅'));
    expect(qian6.gate, equals('杜门'));
    expect(qian6.isHorseStar, isTrue);
  });

  test('甲子旬和空亡宫位保持正确', () {
    final pan = _buildPan(DateTime(2029, 4, 19, 16, 33));

    expect(pan.hourGanzhi, equals('壬申'));
    expect(pan.dunType, equals(QimenDunType.yang));
    expect(pan.bureau, equals(4));
    expect(pan.xunShou, equals('甲子'));
    expect(pan.valueStar, equals('天辅'));
    expect(pan.valueGate, equals('杜门'));
    expect(pan.horseStar, equals('寅'));

    final gen8 = _cell(pan, 8);
    final qian6 = _cell(pan, 6);
    expect(gen8.deity, equals('值符'));
    expect(gen8.star, equals('天辅'));
    expect(gen8.gate, equals('伤门'));
    expect(qian6.isKongWang, isTrue);
  });
}
