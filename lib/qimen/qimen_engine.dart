import 'qimen_models.dart';

class QimenEngine {
  static const List<String> _tiangan = [
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
  static const List<String> _dizhi = [
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
  static const List<String> _solarTermNames = [
    '小寒',
    '大寒',
    '立春',
    '雨水',
    '惊蛰',
    '春分',
    '清明',
    '谷雨',
    '立夏',
    '小满',
    '芒种',
    '夏至',
    '小暑',
    '大暑',
    '立秋',
    '处暑',
    '白露',
    '秋分',
    '寒露',
    '霜降',
    '立冬',
    '小雪',
    '大雪',
    '冬至',
  ];
  static const List<double> _solarTermCenturyValue21 = [
    5.4055,
    20.12,
    3.87,
    18.73,
    5.63,
    20.646,
    4.81,
    20.1,
    5.52,
    21.04,
    5.678,
    21.37,
    7.108,
    22.83,
    7.5,
    23.13,
    7.646,
    23.042,
    8.318,
    23.438,
    7.438,
    22.36,
    7.18,
    21.94,
  ];
  static const List<int> _solarTermMonths = [
    1,
    1,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    7,
    7,
    8,
    8,
    9,
    9,
    10,
    10,
    11,
    11,
    12,
    12,
  ];
  static const List<int> _zhuanNinePalaceOrder = [1, 8, 3, 4, 9, 2, 7, 6, 5];
  static const List<int> _zhuanRingPalaceOrder = [1, 8, 3, 4, 9, 2, 7, 6];
  static const List<int> _feiNinePalaceOrder = [1, 2, 3, 4, 9, 8, 7, 6, 5];
  static const List<int> _feiRingPalaceOrder = [1, 2, 3, 4, 9, 8, 7, 6];
  static const List<int> displayOrder = [4, 9, 2, 3, 5, 7, 8, 1, 6];

  static const Map<int, String> _palaceNames = {
    1: '坎一宫',
    2: '坤二宫',
    3: '震三宫',
    4: '巽四宫',
    5: '中五宫',
    6: '乾六宫',
    7: '兑七宫',
    8: '艮八宫',
    9: '离九宫',
  };

  static const List<String> _stems = [
    '戊',
    '己',
    '庚',
    '辛',
    '壬',
    '癸',
    '丁',
    '丙',
    '乙',
  ];
  static const List<String> _stars = [
    '天蓬',
    '天任',
    '天冲',
    '天辅',
    '天英',
    '天芮',
    '天柱',
    '天心',
    '天禽',
  ];
  static const List<String> _gates = [
    '休门',
    '生门',
    '伤门',
    '杜门',
    '景门',
    '死门',
    '惊门',
    '开门',
  ];
  static const List<String> _yangDeities = [
    '值符',
    '腾蛇',
    '太阴',
    '六合',
    '白虎',
    '玄武',
    '九地',
    '九天',
  ];
  static const List<String> _yinDeities = [
    '值符',
    '九天',
    '九地',
    '玄武',
    '白虎',
    '六合',
    '太阴',
    '腾蛇',
  ];
  static const List<String> _hourBranches = [
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

  static QimenPan generate({
    required DateTime dateTime,
    required QimenDunType? manualDunType,
    required bool useAutoDunType,
    required QimenPanMode panMode,
    required QimenSetupMethod setupMethod,
    required int bureau,
  }) {
    final solarTerm = _resolveSolarTerm(dateTime);
    final autoDunType = _resolveDunTypeFromSolarTerm(solarTerm.name);
    final dunType = useAutoDunType
        ? autoDunType
        : (manualDunType ?? autoDunType);
    final yearGanzhi = _resolveYearGanzhi(dateTime);
    final monthGanzhi = _resolveMonthGanzhi(dateTime, yearGanzhi);
    final dayGanzhi = _resolveDayGanzhi(dateTime);
    final hourGanzhi = _resolveHourGanzhi(dateTime, dayGanzhi);
    final ninePalaceOrder = panMode == QimenPanMode.zhuan
        ? _zhuanNinePalaceOrder
        : _feiNinePalaceOrder;
    final ringPalaceOrder = panMode == QimenPanMode.zhuan
        ? _zhuanRingPalaceOrder
        : _feiRingPalaceOrder;
    final setupShift = _setupMethodShift(setupMethod);
    final panModeShift = panMode == QimenPanMode.fei ? 2 : 0;
    final daySeed = dateTime.difference(DateTime(2024, 1, 1)).inDays;
    final hourIndex = ((dateTime.hour + 1) ~/ 2) % 12;
    final direction = dunType == QimenDunType.yang ? 1 : -1;

    final earthByPalace = _placeNine(
      _stems,
      ninePalaceOrder,
      direction * (bureau - 1 + setupShift),
    );
    final heavenByPalace = _placeNine(
      _stems,
      ninePalaceOrder,
      direction * (hourIndex + bureau - 1 + setupShift + panModeShift),
    );
    final starsByPalace = _placeNine(
      _stars,
      ninePalaceOrder,
      direction * (daySeed + bureau - 1 + panModeShift),
    );
    final gatesByPalace = _placeEight(
      _gates,
      ringPalaceOrder,
      direction *
          (hourIndex +
              bureau -
              1 +
              panModeShift +
              (setupMethod == QimenSetupMethod.zhishimen ? 1 : 0)),
    );
    final deitiesByPalace = _placeEight(
      dunType == QimenDunType.yang ? _yangDeities : _yinDeities,
      ringPalaceOrder,
      direction *
          (hourIndex +
              (panMode == QimenPanMode.fei ? 1 : 0) +
              (setupMethod == QimenSetupMethod.angan ? 1 : 0)),
    );

    final valueStar = _rotate(
      _stars,
      direction * (daySeed + bureau - 1 + panModeShift),
    ).first;
    final valueGate = _rotate(
      _gates,
      direction *
          (hourIndex +
              bureau -
              1 +
              panModeShift +
              (setupMethod == QimenSetupMethod.zhishimen ? 1 : 0)),
    ).first;
    final chiefDeity = _rotate(
      dunType == QimenDunType.yang ? _yangDeities : _yinDeities,
      direction *
          (hourIndex +
              (panMode == QimenPanMode.fei ? 1 : 0) +
              (setupMethod == QimenSetupMethod.angan ? 1 : 0)),
    ).first;

    final cells = displayOrder
        .map(
          (palace) => QimenPanCell(
            palaceNumber: palace,
            palaceName: _palaceNames[palace] ?? '$palace宫',
            deity: palace == 5 ? chiefDeity : (deitiesByPalace[palace] ?? ''),
            star: starsByPalace[palace] ?? '',
            gate: palace == 5 ? '中宫' : (gatesByPalace[palace] ?? '寄宫'),
            heavenStem: heavenByPalace[palace] ?? '',
            earthStem: earthByPalace[palace] ?? '',
            isCenter: palace == 5,
          ),
        )
        .toList(growable: false);

    return QimenPan(
      generatedAt: dateTime,
      solarTerm: solarTerm.name,
      yearGanzhi: yearGanzhi,
      monthGanzhi: monthGanzhi,
      dayGanzhi: dayGanzhi,
      hourGanzhi: hourGanzhi,
      dunType: dunType,
      panMode: panMode,
      setupMethod: setupMethod,
      bureau: bureau,
      hourLabel: '${_hourBranches[hourIndex]}时',
      valueStar: valueStar,
      valueGate: valueGate,
      chiefDeity: chiefDeity,
      note:
          '当前采用${panMode.label} + ${setupMethod.label}的工程化起盘规则。已支持节气自动判定阴遁/阳遁与年、月、日、时干支自动换算；局数仍保留手动选择，方便后续继续接入完整传统起局算法。',
      cells: cells,
    );
  }

  static String formatDateTime(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  static Map<int, String> _placeNine(
    List<String> items,
    List<int> palaceOrder,
    int shift,
  ) {
    final rotated = _rotate(items, shift);
    final result = <int, String>{};
    for (var index = 0; index < palaceOrder.length; index++) {
      result[palaceOrder[index]] = rotated[index];
    }
    return result;
  }

  static Map<int, String> _placeEight(
    List<String> items,
    List<int> palaceOrder,
    int shift,
  ) {
    final rotated = _rotate(items, shift);
    final result = <int, String>{};
    for (var index = 0; index < palaceOrder.length; index++) {
      result[palaceOrder[index]] = rotated[index];
    }
    return result;
  }

  static int _setupMethodShift(QimenSetupMethod setupMethod) {
    switch (setupMethod) {
      case QimenSetupMethod.chaibu:
        return 0;
      case QimenSetupMethod.angan:
        return 2;
      case QimenSetupMethod.zhishimen:
        return 4;
    }
  }

  static _SolarTermMoment _resolveSolarTerm(DateTime dateTime) {
    final currentYearTerms = _buildSolarTerms(dateTime.year);
    for (var index = currentYearTerms.length - 1; index >= 0; index--) {
      if (!dateTime.isBefore(currentYearTerms[index].time)) {
        return currentYearTerms[index];
      }
    }
    return _buildSolarTerms(dateTime.year - 1).last;
  }

  static QimenDunType _resolveDunTypeFromSolarTerm(String solarTerm) {
    const yangTerms = {
      '冬至',
      '小寒',
      '大寒',
      '立春',
      '雨水',
      '惊蛰',
      '春分',
      '清明',
      '谷雨',
      '立夏',
      '小满',
      '芒种',
    };
    return yangTerms.contains(solarTerm) ? QimenDunType.yang : QimenDunType.yin;
  }

  static String _resolveYearGanzhi(DateTime dateTime) {
    final lichun = _buildSolarTerms(
      dateTime.year,
    ).firstWhere((term) => term.name == '立春').time;
    final effectiveYear = dateTime.isBefore(lichun)
        ? dateTime.year - 1
        : dateTime.year;
    return _ganzhiForYear(effectiveYear);
  }

  static String _resolveMonthGanzhi(DateTime dateTime, String yearGanzhi) {
    final monthIndex = _monthOrderFromDate(dateTime);
    final yearStem = yearGanzhi.substring(0, 1);
    final firstMonthStemIndex = switch (yearStem) {
      '甲' || '己' => 2,
      '乙' || '庚' => 4,
      '丙' || '辛' => 6,
      '丁' || '壬' => 8,
      _ => 0,
    };
    final stem = _tiangan[(firstMonthStemIndex + monthIndex) % 10];
    final branch = _dizhi[(2 + monthIndex) % 12];
    return '$stem$branch';
  }

  static String _resolveDayGanzhi(DateTime dateTime) {
    final jdn = _julianDayNumber(dateTime.year, dateTime.month, dateTime.day);
    final stem = _tiangan[(jdn + 9) % 10];
    final branch = _dizhi[(jdn + 1) % 12];
    return '$stem$branch';
  }

  static String _resolveHourGanzhi(DateTime dateTime, String dayGanzhi) {
    final dayStem = dayGanzhi.substring(0, 1);
    final hourBranchIndex = ((dateTime.hour + 1) ~/ 2) % 12;
    final hourStemStart = switch (dayStem) {
      '甲' || '己' => 0,
      '乙' || '庚' => 2,
      '丙' || '辛' => 4,
      '丁' || '壬' => 6,
      _ => 8,
    };
    final stem = _tiangan[(hourStemStart + hourBranchIndex) % 10];
    final branch = _dizhi[hourBranchIndex];
    return '$stem$branch';
  }

  static int _monthOrderFromDate(DateTime dateTime) {
    final sectionTerms = <_SolarTermMoment>[];
    final previousYearTerms = _buildSolarTerms(dateTime.year - 1);
    final currentYearTerms = _buildSolarTerms(dateTime.year);
    for (var index = 0; index < _solarTermNames.length; index += 2) {
      final sourceYearTerms = _solarTermMonths[index] == 1
          ? previousYearTerms
          : currentYearTerms;
      sectionTerms.add(sourceYearTerms[index]);
    }

    for (var index = sectionTerms.length - 1; index >= 0; index--) {
      if (!dateTime.isBefore(sectionTerms[index].time)) {
        return index;
      }
    }
    return 11;
  }

  static String _ganzhiForYear(int year) {
    final offset = year - 1984;
    final stem = _tiangan[(offset % 10 + 10) % 10];
    final branch = _dizhi[(offset % 12 + 12) % 12];
    return '$stem$branch';
  }

  static List<_SolarTermMoment> _buildSolarTerms(int year) {
    final y = year % 100;
    return List<_SolarTermMoment>.generate(_solarTermNames.length, (index) {
      final month = _solarTermMonths[index];
      final c = _solarTermCenturyValue21[index];
      final leapOffset = month <= 2 ? ((y - 1) ~/ 4) : (y ~/ 4);
      final day = (y * 0.2422 + c).floor() - leapOffset;
      return _SolarTermMoment(
        name: _solarTermNames[index],
        time: DateTime(year, month, day, 12),
      );
    });
  }

  static int _julianDayNumber(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  static List<String> _rotate(List<String> items, int shift) {
    final length = items.length;
    final normalized = ((shift % length) + length) % length;
    return <String>[
      ...items.sublist(normalized),
      ...items.sublist(0, normalized),
    ];
  }
}

class _SolarTermMoment {
  const _SolarTermMoment({required this.name, required this.time});

  final String name;
  final DateTime time;
}
