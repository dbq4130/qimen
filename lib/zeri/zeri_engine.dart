import 'package:lunar/calendar/Lunar.dart';
import 'package:lunar/calendar/LunarMonth.dart';
import 'package:lunar/calendar/LunarYear.dart';
import 'package:lunar/calendar/Solar.dart';

import 'zeri_models.dart';

/// 韦松尤天星择日。
///
/// 日课取月支生日支（上吉），或日支克月支（穴位）。
/// 时辰取时支生日支、日支克时支。日支生时支是泄，不取。
/// 地支用正体五行。十二建只作参考。
class ZeriEngine {
  static const int minYear = 1980;
  static const int maxYear = 2100;

  static const List<String> _stems = [
    '甲',
    '乙',
    '丙',
    '丁',
    '戊',
    '己',
    '庚',
    '辛',
    '壬',
    '癸',
  ];
  static const List<String> _branches = [
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
  ];
  static const Map<String, int> _hourStemStart = {
    '甲': 0,
    '己': 0,
    '乙': 2,
    '庚': 2,
    '丙': 4,
    '辛': 4,
    '丁': 6,
    '壬': 6,
    '戊': 8,
    '癸': 8,
  };
  static const List<String> _hourRanges = [
    '23:00-00:59',
    '01:00-02:59',
    '03:00-04:59',
    '05:00-06:59',
    '07:00-08:59',
    '09:00-10:59',
    '11:00-12:59',
    '13:00-14:59',
    '15:00-16:59',
    '17:00-18:59',
    '19:00-20:59',
    '21:00-22:59',
  ];
  static const Map<String, String> _elementOf = {
    '寅': '木',
    '卯': '木',
    '巳': '火',
    '午': '火',
    '申': '金',
    '酉': '金',
    '亥': '水',
    '子': '水',
    '辰': '土',
    '戌': '土',
    '丑': '土',
    '未': '土',
  };
  static const Map<String, String> _generates = {
    '木': '火',
    '火': '土',
    '土': '金',
    '金': '水',
    '水': '木',
  };
  static const Map<String, String> _overcomes = {
    '木': '土',
    '土': '水',
    '水': '火',
    '火': '金',
    '金': '木',
  };

  static ({int year, int month}) currentMonth([DateTime? dateTime]) {
    final lunar = Lunar.fromDate(dateTime ?? DateTime.now());
    var year = lunar.getYear();
    if (year < minYear) {
      year = minYear;
    } else if (year > maxYear) {
      year = maxYear;
    }
    final months = monthsOf(year);
    final month = lunar.getMonth();
    return (year: year, month: months.contains(month) ? month : months.first);
  }

  static List<int> monthsOf(int lunarYear) {
    final leap = LunarYear.fromYear(lunarYear).getLeapMonth();
    final months = <int>[];
    for (var month = 1; month <= 12; month++) {
      months.add(month);
      if (leap == month) {
        months.add(-month);
      }
    }
    return months;
  }

  static ({int year, int month}) currentSolarMonth([DateTime? dateTime]) {
    final now = dateTime ?? DateTime.now();
    var year = now.year;
    if (year < minYear) {
      year = minYear;
    } else if (year > maxYear) {
      year = maxYear;
    }
    return (year: year, month: now.month);
  }

  static const Map<String, String> _changshengOfStem = {
    '甲': '亥',
    '乙': '午',
    '丙': '寅',
    '丁': '酉',
    '戊': '寅',
    '己': '酉',
    '庚': '巳',
    '辛': '子',
    '壬': '申',
    '癸': '卯',
  };
  static const Map<String, String> _sanheOfBranch = {
    '申': '申子辰',
    '子': '申子辰',
    '辰': '申子辰',
    '巳': '巳酉丑',
    '酉': '巳酉丑',
    '丑': '巳酉丑',
    '寅': '寅午戌',
    '午': '寅午戌',
    '戌': '寅午戌',
    '亥': '亥卯未',
    '卯': '亥卯未',
    '未': '亥卯未',
  };
  static const Map<String, String> _chongOfBranch = {
    '子': '午',
    '午': '子',
    '丑': '未',
    '未': '丑',
    '寅': '申',
    '申': '寅',
    '卯': '酉',
    '酉': '卯',
    '辰': '戌',
    '戌': '辰',
    '巳': '亥',
    '亥': '巳',
  };

  static const List<String> _branchOrder = [
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
  ];

  /// 阳支顺三位、阴支逆三位，作为相通。
  static String _tongOfBranch(String branch) {
    const yang = {'子', '寅', '辰', '午', '申', '戌'};
    final index = _branchOrder.indexOf(branch);
    final delta = yang.contains(branch) ? 3 : -3;
    return _branchOrder[(index + delta + 12) % 12];
  }

  static YongshenMonths monthsOfMountain(YongshenMountain mountain) {
    final namedChangsheng = mountain.group != '地支';
    final changsheng = namedChangsheng
        ? _changshengOfStem[mountain.stem]!
        : mountain.stem;
    final chong = _chongOfBranch[changsheng]!;
    final tong = _tongOfBranch(changsheng);
    final branches = <String>[changsheng];
    final sanhe = _sanheOfBranch[changsheng]!;
    for (var index = 0; index < sanhe.length; index++) {
      final branch = sanhe.substring(index, index + 1);
      if (!branches.contains(branch)) {
        branches.add(branch);
      }
    }
    if (!branches.contains(chong)) {
      branches.add(chong);
    }
    if (!branches.contains(tong)) {
      branches.add(tong);
    }
    return YongshenMonths(
      changsheng: changsheng,
      chong: chong,
      tong: tong,
      branches: branches,
      namedChangsheng: namedChangsheng,
    );
  }

  static ZeriMonthBoard buildSolar({
    required int year,
    required int month,
    required SittingBureau bureau,
    YongshenMountain? mountain,
  }) {
    final dayCount = DateTime(year, month + 1, 0).day;
    final days = <ZeriDay>[];
    for (var day = 1; day <= dayCount; day++) {
      final lunar = Solar.fromYmd(year, month, day).getLunar();
      final viewed = _viewDay(
        lunar: lunar,
        bureau: bureau,
        mountain: mountain,
        requireCourse: false,
      );
      if (viewed != null) {
        days.add(viewed);
      }
    }
    return ZeriMonthBoard(
      lunarYear: year,
      lunarMonth: month,
      title: '$year年$month月',
      days: days,
    );
  }

  static ZeriMonthBoard build({
    required int lunarYear,
    required int lunarMonth,
    required SittingBureau bureau,
  }) {
    final month = LunarMonth.fromYm(lunarYear, lunarMonth);
    final days = <ZeriDay>[];
    final dayCount = month?.getDayCount() ?? 0;
    for (var lunarDay = 1; lunarDay <= dayCount; lunarDay++) {
      final viewed = _viewDay(
        lunar: Lunar.fromYmd(lunarYear, lunarMonth, lunarDay),
        bureau: bureau,
      );
      if (viewed != null) {
        days.add(viewed);
      }
    }
    return ZeriMonthBoard(
      lunarYear: lunarYear,
      lunarMonth: lunarMonth,
      title: _monthTitle(lunarYear, lunarMonth),
      days: days,
    );
  }

  static ZeriDay? _viewDay({
    required Lunar lunar,
    required SittingBureau bureau,
    YongshenMountain? mountain,
    bool requireCourse = true,
  }) {
    final monthZhi = lunar.getMonthZhi();
    final dayZhi = lunar.getDayZhi();
    final dayGan = lunar.getDayGan();
    final course = _courseOf(monthZhi, dayZhi);
    if (course == null && requireCourse) {
      return null;
    }

    final yearGanzhi = lunar.getYearInGanZhi();
    final monthGanzhi = lunar.getMonthInGanZhi();
    final dayGanzhi = lunar.getDayInGanZhi();
    final sharedHits = [
      ..._hits('年', yearGanzhi, bureau),
      ..._hits('月', monthGanzhi, bureau),
      ..._hits('日', dayGanzhi, bureau),
    ];
    final blockedReason = _blockedReason(monthZhi, dayGan, dayGanzhi);
    final sharedStrict = sharedHits.any((hit) => hit.strict);
    final hours = <ZeriHour>[];
    final stemStart = _hourStemStart[dayGan]!;
    for (var index = 0; index < _branches.length; index++) {
      if (course == null) {
        break;
      }
      final zhi = _branches[index];
      final relation = _relationOf(dayZhi, zhi);
      if (relation == null) {
        continue;
      }
      final ganzhi = '${_stems[(stemStart + index) % 10]}$zhi';
      final hourHits = _hits('时', ganzhi, bureau);
      final sealedByTaboo = sharedStrict || hourHits.any((hit) => hit.strict);
      final sealed = blockedReason != null || sealedByTaboo;
      hours.add(
        ZeriHour(
          ganzhi: ganzhi,
          zhi: zhi,
          relation: relation,
          relationDetail: _relationDetail(relation, dayZhi, zhi),
          rangeText: _hourRanges[index],
          startText: _hourRanges[index].split('-').first,
          hourHits: hourHits,
          selectable: !sealed,
          showExclamation:
              !sealed && (sharedHits.isNotEmpty || hourHits.isNotEmpty),
          sealedLabel: sealed ? (blockedReason != null ? '不能用' : '切记') : null,
        ),
      );
    }

    final favoredMonth =
        mountain != null &&
        monthsOfMountain(mountain).branches.contains(monthZhi);

    final jianchu = lunar.getZhiXing();
    final solar = lunar.getSolar();
    return ZeriDay(
      lunarDay: lunar.getDay(),
      lunarDayLabel: lunar.getDayInChinese(),
      lunarMark: lunar.getDay() == 1
          ? _lunarMonthName(lunar)
          : lunar.getDayInChinese(),
      lunarDateText: _lunarDateText(lunar),
      yearAnimal: lunar.getYearShengXiao(),
      solarDay: solar.getDay(),
      weekday: DateTime(
        solar.getYear(),
        solar.getMonth(),
        solar.getDay(),
      ).weekday,
      solarText: _solarText(lunar),
      yearGanzhi: yearGanzhi,
      monthGanzhi: monthGanzhi,
      dayGanzhi: dayGanzhi,
      course: course,
      courseDetail: switch (course) {
        DayCourse.generate => '月支$monthZhi生 日支$dayZhi',
        DayCourse.control => '日支$dayZhi克 月支$monthZhi',
        null => '',
      },
      jianchu: jianchu,
      jianchuTone: _jianchuTone(jianchu),
      blockedReason: blockedReason,
      sharedHits: sharedHits,
      hours: hours,
      favoredMonth: favoredMonth,
      yi: lunar.getDayYi(),
      ji: lunar.getDayJi(),
      unusableReason: _unusableReason(
        bureau: bureau,
        blockedReason: blockedReason,
        course: course,
        monthZhi: monthZhi,
        dayZhi: dayZhi,
        sharedHits: sharedHits,
        hours: hours,
      ),
    );
  }

  static String? _unusableReason({
    required SittingBureau bureau,
    required String? blockedReason,
    required DayCourse? course,
    required String monthZhi,
    required String dayZhi,
    required List<ZeriHit> sharedHits,
    required List<ZeriHour> hours,
  }) {
    if (hours.any((hour) => hour.selectable)) {
      return null;
    }
    if (blockedReason != null) {
      return blockedReason;
    }
    if (course == null) {
      return '月支$monthZhi不生 日支$dayZhi，日支$dayZhi也不克月支$monthZhi';
    }
    final parts = <String>[
      for (final hit in sharedHits)
        if (hit.strict) '${hit.where}柱含${hit.character}',
    ];
    if (parts.isEmpty) {
      for (final hour in hours) {
        for (final hit in hour.hourHits) {
          if (hit.strict) {
            parts.add('${hour.ganzhi}时含${hit.character}');
          }
        }
      }
    }
    final avoid = bureau.avoid.join('、');
    if (parts.isEmpty) {
      return '${bureau.label}忌$avoid';
    }
    return '${bureau.label}忌$avoid，${parts.join('、')}';
  }

  static DayCourse? _courseOf(String monthZhi, String dayZhi) {
    if (_generatesBranch(monthZhi, dayZhi)) {
      return DayCourse.generate;
    }
    if (_overcomesBranch(dayZhi, monthZhi)) {
      return DayCourse.control;
    }
    return null;
  }

  static HourRelation? _relationOf(String dayZhi, String hourZhi) {
    if (_generatesBranch(hourZhi, dayZhi)) {
      return HourRelation.hourGeneratesDay;
    }
    if (_overcomesBranch(dayZhi, hourZhi)) {
      return HourRelation.dayControlsHour;
    }
    return null;
  }

  static String _relationDetail(
    HourRelation relation,
    String dayZhi,
    String hourZhi,
  ) {
    return switch (relation) {
      HourRelation.hourGeneratesDay => '时支$hourZhi生 日支$dayZhi',
      HourRelation.dayControlsHour => '日支$dayZhi克 时支$hourZhi',
    };
  }

  static List<ZeriHit> _hits(
    String where,
    String ganzhi,
    SittingBureau bureau,
  ) {
    return [
      for (final character in bureau.avoid)
        if (ganzhi.contains(character))
          ZeriHit(where: where, character: character, strict: bureau.strict),
    ];
  }

  static String? _blockedReason(
    String monthZhi,
    String dayGan,
    String dayGanzhi,
  ) {
    if (dayGanzhi == '己亥') {
      return '己亥日，天地大重丧，不能用';
    }
    if ('辰戌丑未'.contains(monthZhi) && (dayGan == '戊' || dayGan == '己')) {
      return '辰戌丑未月忌用戊己日，重丧日，不能用';
    }
    return null;
  }

  static bool _generatesBranch(String from, String to) {
    return _generates[_elementOf[from]] == _elementOf[to];
  }

  static bool _overcomesBranch(String from, String to) {
    return _overcomes[_elementOf[from]] == _elementOf[to];
  }

  static String _jianchuTone(String name) {
    const black = {'建', '满', '平', '收'};
    const yellow = {'除', '危', '定', '执'};
    const usable = {'成', '开'};
    const poor = {'闭', '破'};
    if (black.contains(name)) {
      return '黑';
    }
    if (yellow.contains(name)) {
      return '黄';
    }
    if (usable.contains(name)) {
      return '可用';
    }
    if (poor.contains(name)) {
      return '不相当';
    }
    return '参考';
  }

  static String _lunarMonthName(Lunar lunar) {
    final month = lunar.getMonthInChinese();
    if (month == '正') {
      return '正月';
    }
    return '$month月';
  }

  static String _lunarDateText(Lunar lunar) {
    return '${_lunarMonthName(lunar)}${lunar.getDayInChinese()}';
  }

  static String _monthTitle(int year, int month) {
    final name = Lunar.fromYmd(year, month, 1).getMonthInChinese();
    if (name == '正') {
      return '$year年正月';
    }
    return '$year年$name月';
  }

  static String _solarText(Lunar lunar) {
    final solar = lunar.getSolar();
    final month = solar.getMonth().toString().padLeft(2, '0');
    final day = solar.getDay().toString().padLeft(2, '0');
    return '${solar.getYear()}-$month-$day';
  }
}
