import 'package:flutter_test/flutter_test.dart';
import 'package:qimen/zeri/zeri_engine.dart';
import 'package:qimen/zeri/zeri_models.dart';

void main() {
  ZeriDay dayOf(ZeriMonthBoard board, String ganzhi) {
    return board.days.singleWhere((day) => day.dayGanzhi == ganzhi);
  }

  ZeriHour hourOf(ZeriDay day, String ganzhi) {
    return day.hours.singleWhere((hour) => hour.ganzhi == ganzhi);
  }

  test('庚山例课：戊辰月乙酉日庚辰时是上吉时生日', () {
    final board = ZeriEngine.build(
      lunarYear: 2019,
      lunarMonth: 3,
      bureau: SittingBureau.metal,
    );
    final day = board.days.singleWhere((item) => item.lunarDay == 14);

    expect(board.title, '2019年三月');
    expect(day.yearGanzhi, '己亥');
    expect(day.monthGanzhi, '戊辰');
    expect(day.dayGanzhi, '乙酉');
    expect(day.solarText, '2019-04-18');
    expect(day.course, DayCourse.generate);
    expect(day.jianchu, '执');
    expect(day.jianchuTone, '黄');
    expect(day.hours.map((hour) => hour.zhi).toList(), [
      '丑',
      '寅',
      '卯',
      '辰',
      '未',
      '戌',
    ]);

    final chen = hourOf(day, '庚辰');
    expect(chen.relation, HourRelation.hourGeneratesDay);
    expect(chen.selectable, isTrue);
    expect(chen.showExclamation, isFalse);
    expect(chen.startText, '07:00');
    expect(day.yi, contains('纳采'));
    expect(day.ji, contains('开市'));
    expect(day.lunarMark, '十四');
    expect(day.lunarDateText, '三月十四');
    expect(day.yearAnimal, '猪');

    final yin = hourOf(day, '戊寅');
    expect(yin.relation, HourRelation.dayControlsHour);
    expect(yin.selectable, isTrue);

    final xu = hourOf(day, '丙戌');
    expect(xu.relation, HourRelation.hourGeneratesDay);
    expect(xu.selectable, isFalse);
    expect(xu.sealedLabel, '切记');
    expect(xu.showExclamation, isFalse);
    expect(day.hours.any((hour) => hour.zhi == '子'), isFalse);
  });

  test('没写切记的忌用时辰标感叹号且仍可选', () {
    final board = ZeriEngine.build(
      lunarYear: 2019,
      lunarMonth: 3,
      bureau: SittingBureau.wood,
    );
    final day = board.days.singleWhere((item) => item.lunarDay == 14);
    final chen = hourOf(day, '庚辰');
    final chou = hourOf(day, '丁丑');

    expect(day.sharedHits.map((hit) => hit.character), contains('戊'));
    expect(chen.selectable, isTrue);
    expect(chen.showExclamation, isTrue);
    expect(chou.selectable, isTrue);
    expect(chou.showExclamation, isTrue);
    expect(chou.hourHits.map((hit) => hit.character), contains('丑'));
  });

  test('土局犯辰未仍可选，水局犯丁不可选', () {
    final earth = ZeriEngine.build(
      lunarYear: 2019,
      lunarMonth: 3,
      bureau: SittingBureau.earth,
    );
    final earthDay = earth.days.singleWhere((item) => item.lunarDay == 14);
    final earthHour = hourOf(earthDay, '庚辰');
    expect(earthHour.selectable, isTrue);
    expect(earthHour.showExclamation, isTrue);

    final water = ZeriEngine.build(
      lunarYear: 2019,
      lunarMonth: 3,
      bureau: SittingBureau.water,
    );
    final waterHour = hourOf(
      water.days.singleWhere((item) => item.lunarDay == 14),
      '丁丑',
    );
    expect(waterHour.selectable, isFalse);
    expect(waterHour.sealedLabel, '切记');
    expect(waterHour.showExclamation, isFalse);
  });

  test('己亥日和重丧日不能选', () {
    final jihaiBoard = ZeriEngine.build(
      lunarYear: 2024,
      lunarMonth: 4,
      bureau: SittingBureau.wood,
    );
    final jihai = dayOf(jihaiBoard, '己亥');
    expect(jihai.course, DayCourse.control);
    expect(jihai.blockedReason, contains('天地大重丧'));
    expect(jihai.unusableReason, contains('天地大重丧'));
    expect(jihai.hours.map((hour) => hour.zhi), ['巳', '午', '申', '酉']);
    expect(
      jihai.hours
          .where((hour) => hour.zhi == '巳' || hour.zhi == '午')
          .every((hour) => hour.relation == HourRelation.dayControlsHour),
      isTrue,
    );
    expect(
      jihai.hours
          .where((hour) => hour.zhi == '申' || hour.zhi == '酉')
          .every((hour) => hour.relation == HourRelation.hourGeneratesDay),
      isTrue,
    );
    expect(jihai.hours.every((hour) => !hour.selectable), isTrue);
    expect(jihai.hours.every((hour) => !hour.showExclamation), isTrue);

    final heavy = ZeriEngine.build(
      lunarYear: 2024,
      lunarMonth: 3,
      bureau: SittingBureau.metal,
    );
    final chong = dayOf(heavy, '戊申');
    expect(chong.blockedReason, contains('重丧'));
    expect(chong.hours.every((hour) => hour.sealedLabel == '不能用'), isTrue);
  });

  test('用神山天干取长生，再加三合和相冲', () {
    final jia = ZeriEngine.monthsOfMountain(YongshenMountain.jia);
    expect(jia.changsheng, '亥');
    expect(jia.tong, '申');
    expect(jia.branches, ['亥', '卯', '未', '巳', '申']);
    expect(
      ZeriEngine.monthsOfMountain(YongshenMountain.qian).branches,
      jia.branches,
    );

    final geng = ZeriEngine.monthsOfMountain(YongshenMountain.geng);
    expect(geng.changsheng, '巳');
    expect(geng.tong, '寅');
    expect(geng.branches, ['巳', '酉', '丑', '亥', '寅']);
    expect(
      ZeriEngine.monthsOfMountain(YongshenMountain.zhen).branches,
      geng.branches,
    );
    expect(ZeriEngine.monthsOfMountain(YongshenMountain.kan).changsheng, '卯');

    expect(YongshenMountain.branches.map((item) => item.label).toList(), [
      '子',
      '丑',
      '寅',
      '卯',
      '辰',
      '巳',
      '午',
      '未',
      '申',
      '酉',
      '戌',
      '亥',
    ]);
    expect(ZeriEngine.monthsOfMountain(YongshenMountain.zi).branches, [
      '子',
      '申',
      '辰',
      '午',
      '卯',
    ]);
    expect(ZeriEngine.monthsOfMountain(YongshenMountain.hai).branches, [
      '亥',
      '卯',
      '未',
      '巳',
      '申',
    ]);

    final chen = ZeriEngine.monthsOfMountain(YongshenMountain.chen);
    expect(chen.namedChangsheng, isFalse);
    expect(chen.branches, ['辰', '申', '子', '戌', '未']);
    expect(ZeriEngine.monthsOfMountain(YongshenMountain.xu).branches, [
      '戌',
      '寅',
      '午',
      '辰',
      '丑',
    ]);
    expect(ZeriEngine.monthsOfMountain(YongshenMountain.chou).branches, [
      '丑',
      '巳',
      '酉',
      '未',
      '戌',
    ]);
    expect(ZeriEngine.monthsOfMountain(YongshenMountain.wei).branches, [
      '未',
      '亥',
      '卯',
      '丑',
      '辰',
    ]);
  });

  test('用神山月份只作参考，定不了月时日子仍可选', () {
    final otherMonth = ZeriEngine.buildSolar(
      year: 2019,
      month: 4,
      bureau: SittingBureau.metal,
      mountain: YongshenMountain.jia,
    );
    final chenDay = otherMonth.days.singleWhere((item) => item.solarDay == 18);
    expect(chenDay.monthGanzhi, '戊辰');
    expect(chenDay.favoredMonth, isFalse);
    expect(chenDay.selectable, isTrue);

    final favored = ZeriEngine.buildSolar(
      year: 2019,
      month: 4,
      bureau: SittingBureau.metal,
      mountain: YongshenMountain.ren,
    );
    final favoredDay = favored.days.singleWhere((item) => item.solarDay == 18);
    expect(favoredDay.favoredMonth, isTrue);
    expect(favoredDay.selectable, isTrue);
  });

  test('公历月历列出整月，可选日带宜忌', () {
    final board = ZeriEngine.buildSolar(
      year: 2019,
      month: 4,
      bureau: SittingBureau.metal,
    );
    final day = board.days.singleWhere((item) => item.solarDay == 18);

    expect(board.title, '2019年4月');
    expect(board.days, hasLength(30));
    expect(day.dayGanzhi, '乙酉');
    expect(day.selectable, isTrue);
    expect(day.yi, contains('纳采'));
    expect(day.ji, contains('动土'));
    expect(board.days.where((item) => !item.selectable), isNotEmpty);

    final plain = board.days.firstWhere((item) => item.course == null);
    expect(plain.selectable, isFalse);
    expect(plain.unusableReason, contains('不生'));
    expect(plain.unusableReason, contains('也不克'));
  });

  test('辛酉日不取泄金的子时', () {
    ZeriDay? found;
    for (var month = 1; month <= 12 && found == null; month++) {
      final board = ZeriEngine.buildSolar(
        year: 2026,
        month: month,
        bureau: SittingBureau.fire,
      );
      for (final day in board.days) {
        if (day.dayGanzhi == '辛酉' && day.course != null) {
          found = day;
          break;
        }
      }
    }

    expect(found, isNotNull);
    expect(found!.hours.map((hour) => hour.zhi).toList(), [
      '丑',
      '寅',
      '卯',
      '辰',
      '未',
      '戌',
    ]);
    expect(found.hours.map((hour) => hour.ganzhi), isNot(contains('戊子')));
  });
}
