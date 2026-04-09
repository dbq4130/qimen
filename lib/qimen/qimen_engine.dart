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

  // 六甲旬首对应的六仪
  static const Map<String, String> _xunShouToYi = {
    '甲子': '戊',
    '甲戌': '己',
    '甲申': '庚',
    '甲午': '辛',
    '甲辰': '壬',
    '甲寅': '癸',
  };

  // 九宫对应的原始星（宫位1-9）
  static const Map<int, String> _palaceToStar = {
    1: '天蓬', // 坎1宫
    2: '天芮', // 坤2宫
    3: '天冲', // 震3宫
    4: '天辅', // 巽4宫
    5: '天禽', // 中5宫
    6: '天心', // 乾6宫
    7: '天柱', // 兑7宫
    8: '天任', // 艮8宫
    9: '天英', // 离9宫
  };

  // 八宫对应的原始门（中5宫无门，寄坤2宫）
  static const Map<int, String> _palaceToGate = {
    1: '休门', // 坎1宫
    2: '死门', // 坤2宫
    3: '伤门', // 震3宫
    4: '杜门', // 巽4宫
    5: '死门', // 中5宫寄坤2
    6: '开门', // 乾6宫
    7: '惊门', // 兑7宫
    8: '生门', // 艮8宫
    9: '景门', // 离9宫
  };

  // 六仪三奇排列顺序
  static const List<String> _yiQiOrder = [
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

  // 节气用局表：每个节气的[上元, 中元, 下元]局数
  // 阳遁节气（冬至到芒种）
  static const Map<String, List<int>> _yangJuTable = {
    '冬至': [1, 7, 4],
    '小寒': [2, 8, 5],
    '大寒': [3, 9, 6],
    '立春': [8, 5, 2],
    '雨水': [9, 6, 3],
    '惊蛰': [1, 7, 4],
    '春分': [3, 9, 6],
    '清明': [4, 1, 7],
    '谷雨': [5, 2, 8],
    '立夏': [4, 1, 7],
    '小满': [5, 2, 8],
    '芒种': [6, 3, 9],
  };

  // 阴遁节气（夏至到大雪）
  static const Map<String, List<int>> _yinJuTable = {
    '夏至': [9, 3, 6],
    '小暑': [8, 2, 5],
    '大暑': [7, 1, 4],
    '立秋': [2, 5, 8],
    '处暑': [1, 4, 7],
    '白露': [9, 3, 6],
    '秋分': [7, 1, 4],
    '寒露': [6, 9, 3],
    '霜降': [5, 8, 2],
    '立冬': [6, 9, 3],
    '小雪': [5, 8, 2],
    '大雪': [4, 7, 1],
  };

  // 六甲旬空亡表：每旬空亡的两个地支
  static const Map<String, List<String>> _xunKongWang = {
    '甲子': ['戌', '亥'],
    '甲戌': ['申', '酉'],
    '甲申': ['午', '未'],
    '甲午': ['辰', '巳'],
    '甲辰': ['寅', '卯'],
    '甲寅': ['子', '丑'],
  };

  // 地支对应的宫位
  static const Map<String, int> _branchToPalace = {
    '子': 1,
    '丑': 8,
    '寅': 8,
    '卯': 3,
    '辰': 4,
    '巳': 4,
    '午': 9,
    '未': 2,
    '申': 2,
    '酉': 7,
    '戌': 6,
    '亥': 6,
  };

  // 马星计算：根据时支三合局
  static const Map<String, String> _horseStar = {
    '寅': '申', '午': '申', '戌': '申', // 寅午戌马在申
    '巳': '亥', '酉': '亥', '丑': '亥', // 巳酉丑马在亥
    '申': '寅', '子': '寅', '辰': '寅', // 申子辰马在寅
    '亥': '巳', '卯': '巳', '未': '巳', // 亥卯未马在巳
  };

  static QimenPan generate({
    required DateTime dateTime,
    required QimenDunType? manualDunType,
    required bool useAutoDunType,
    required QimenPanMode panMode,
    required QimenSetupMethod setupMethod,
    required int? manualBureau,
    required bool useAutoBureau,
  }) {
    final solarTerm = _resolveSolarTerm(dateTime);
    final autoDunType = _resolveDunTypeFromSolarTerm(solarTerm.name);
    final dunType = useAutoDunType
        ? autoDunType
        : (manualDunType ?? autoDunType);

    // 先计算四柱
    final yearGanzhi = _resolveYearGanzhi(dateTime);
    final monthGanzhi = _resolveMonthGanzhi(dateTime, yearGanzhi);
    final dayGanzhi = _resolveDayGanzhi(dateTime);
    final hourGanzhi = _resolveHourGanzhi(dateTime, dayGanzhi);

    // 三元基于日干支判定（用于确定局数）
    final yuanInfo = _resolveYuan(dayGanzhi);
    final autoBureau = _resolveBureau(solarTerm.name, yuanInfo.yuan, dunType);
    final bureau = useAutoBureau ? autoBureau : (manualBureau ?? autoBureau);
    final hourIndex = ((dateTime.hour + 1) ~/ 2) % 12;
    final direction = dunType == QimenDunType.yang ? 1 : -1;

    // 计算旬首和六仪（基于时干支）
    final xunShou = _resolveXunShou(hourGanzhi);
    final xunYi = _xunShouToYi[xunShou] ?? '戊';

    // 计算马星
    final hourBranch = hourGanzhi.substring(1);
    final horseStar = _horseStar[hourBranch] ?? '';
    final horseStarPalace = _branchToPalace[horseStar] ?? 0;

    // 根据局数计算六仪在地盘的宫位（值符原始落宫）
    final yiPalace = _findYiPalace(xunYi, bureau, dunType);
    final valueStar = _palaceToStar[yiPalace] ?? '天蓬';
    final valueGate = _palaceToGate[yiPalace] ?? '休门';

    // 地盘：根据局数排布六仪三奇
    final earthByPalace = _buildEarthPlate(bureau, dunType);

    // 计算时干在地盘的落宫（值符随时干转动）
    final hourStem = hourGanzhi.substring(0, 1);
    final hourStemPalace = _findStemPalace(hourStem, earthByPalace, dunType);

    // 天盘：以时干落宫为基准转动
    final heavenByPalace = _buildHeavenPlate(
      earthByPalace,
      yiPalace,
      hourStemPalace,
      dunType,
    );

    // 九星：值符星转到时干落宫，其他星跟着转
    final starsByPalace = _buildStarsPlate(yiPalace, hourStemPalace, dunType);

    // 八门：值使门落宫后，从该宫顺时针排布八门
    final gatesByPalace = _buildGatesPlate(
      yiPalace,
      hourStemPalace,
      dunType,
      hourStem,
    );

    // 八神：值符神转到时干落宫，其他神跟着转
    final deitiesByPalace = _buildDeitiesPlate(
      yiPalace,
      hourStemPalace,
      dunType,
    );
    final chiefDeity = _rotate(
      dunType == QimenDunType.yang ? _yangDeities : _yinDeities,
      direction *
          (hourIndex +
              (panMode == QimenPanMode.fei ? 1 : 0) +
              (setupMethod == QimenSetupMethod.angan ? 1 : 0)),
    ).first;

    // 计算空亡宫位（根据地支对应的宫位）
    final kongWangBranches = _xunKongWang[xunShou] ?? [];
    final kongWangPalaces = kongWangBranches
        .map((branch) => _branchToPalace[branch] ?? 0)
        .toSet();

    // 找到天芮所在宫位（天禽随天芮走）
    int tianRuiPalace = 2; // 默认坤2宫
    for (final entry in starsByPalace.entries) {
      if (entry.value == '天芮') {
        tianRuiPalace = entry.key;
        break;
      }
    }
    // 中宫天盘干（天禽带的天干）
    final tianQinStem = heavenByPalace[5] ?? '';
    // 天禽寄宫随阴阳遁变化：阳遁寄坤2，阴遁寄艮8
    final tianQinJiPalace = _centerProxyPalace(dunType);

    final cells = displayOrder
        .map((palace) {
          // 天禽相关：天芮宫显示天禽星，坤2宫显示天禽天干
          final hasTianQinStar = palace == tianRuiPalace && palace != 5;
          final hasTianQinStem = palace == tianQinJiPalace && palace != 5;
          return QimenPanCell(
            palaceNumber: palace,
            palaceName: _palaceNames[palace] ?? '$palace宫',
            // 中宫没有神、星、门，只有天干地盘干
            deity: palace == 5 ? '' : (deitiesByPalace[palace] ?? ''),
            star: palace == 5 ? '' : (starsByPalace[palace] ?? ''),
            gate: palace == 5 ? '' : (gatesByPalace[palace] ?? ''),
            heavenStem: heavenByPalace[palace] ?? '',
            earthStem: earthByPalace[palace] ?? '',
            isCenter: palace == 5,
            isKongWang: kongWangPalaces.contains(palace),
            isHorseStar: palace == horseStarPalace,
            hasTianQinStar: hasTianQinStar,
            hasTianQinStem: hasTianQinStem,
            tianQinStem: tianQinStem,
          );
        })
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
      xunShou: xunShou,
      xunYi: xunYi,
      horseStar: horseStar,
      yuan: yuanInfo.yuan,
      kongWang: _getKongWang(xunShou),
      note: '${yuanInfo.yuan} ${dunType.label}${bureau}局，旬首$xunShou$xunYi',
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
    // 年上起月：甲己之年丙作首，乙庚之岁戊为头...
    // firstMonthStemIndex是寅月的天干索引
    final firstMonthStemIndex = switch (yearStem) {
      '甲' || '己' => 2, // 丙寅月
      '乙' || '庚' => 4, // 戊寅月
      '丙' || '辛' => 6, // 庚寅月
      '丁' || '壬' => 8, // 壬寅月
      _ => 0, // 甲寅月
    };
    // monthIndex: 0=小寒后(子月), 1=立春后(寅月), 2=惊蛰后(卯月)...
    // 月支：dizhi[(monthIndex + 1) % 12]，月干从寅月起算需要减1
    final stem = _tiangan[(firstMonthStemIndex + monthIndex - 1 + 10) % 10];
    final branch = _dizhi[(monthIndex + 1) % 12];
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

  /// 根据日干支判定三元（上元/中元/下元）
  /// 六十甲子分12组，每组5天，按上中下元循环
  static _YuanInfo _resolveYuan(String dayGanzhi) {
    final xunShou = _resolveXunShou(dayGanzhi);

    // 计算日干支在六十甲子中的位置（0-59）
    final stem = dayGanzhi.substring(0, 1);
    final branch = dayGanzhi.substring(1);
    final stemIndex = _tiangan.indexOf(stem);
    final branchIndex = _dizhi.indexOf(branch);
    // 六十甲子位置公式：(天干索引 - 地支索引 + 60) % 10 * 6 + 地支索引
    final gzIndex = (stemIndex - branchIndex + 60) % 10 * 6 + branchIndex;

    // 每5天一组，60天分12组，按上中下元循环
    // 组号 = gzIndex / 5
    // 0,3,6,9 组 → 上元
    // 1,4,7,10 组 → 中元
    // 2,5,8,11 组 → 下元
    final groupIndex = gzIndex ~/ 5;
    final yuanIndex = groupIndex % 3;

    String yuan;
    switch (yuanIndex) {
      case 0:
        yuan = '上元';
        break;
      case 1:
        yuan = '中元';
        break;
      default:
        yuan = '下元';
    }

    return _YuanInfo(yuan: yuan, fuTou: xunShou);
  }

  /// 根据节气、三元、遁法确定局数
  static int _resolveBureau(
    String solarTerm,
    String yuan,
    QimenDunType dunType,
  ) {
    final juTable = dunType == QimenDunType.yang ? _yangJuTable : _yinJuTable;
    final juList = juTable[solarTerm];

    if (juList == null) return 1;

    switch (yuan) {
      case '上元':
        return juList[0];
      case '中元':
        return juList[1];
      case '下元':
        return juList[2];
      default:
        return juList[0];
    }
  }

  /// 根据局数和遁法找到六仪在地盘的宫位
  static int _findYiPalace(String yi, int bureau, QimenDunType dunType) {
    final yiIndex = _yiQiOrder.indexOf(yi);
    if (yiIndex < 0) return 1;

    if (dunType == QimenDunType.yang) {
      final palaceOrder = [1, 2, 3, 4, 5, 6, 7, 8, 9];
      final startIndex = bureau - 1;
      final palaceIndex = (startIndex + yiIndex) % 9;
      return palaceOrder[palaceIndex];
    } else {
      final palaceOrder = [1, 9, 8, 7, 6, 5, 4, 3, 2];
      final startIndex = palaceOrder.indexOf(bureau);
      final palaceIndex = (startIndex + yiIndex) % 9;
      return palaceOrder[palaceIndex];
    }
  }

  /// 构建地盘：根据局数排布六仪三奇
  static Map<int, String> _buildEarthPlate(int bureau, QimenDunType dunType) {
    final result = <int, String>{};
    for (var i = 0; i < _yiQiOrder.length; i++) {
      final palace = _findYiPalace(_yiQiOrder[i], bureau, dunType);
      result[palace] = _yiQiOrder[i];
    }
    return result;
  }

  /// 查找天干在地盘的落宫（中宫按阴阳遁寄宫）
  static int _findStemPalace(
    String stem,
    Map<int, String> earthPlate,
    QimenDunType dunType,
  ) {
    for (final entry in earthPlate.entries) {
      if (entry.value == stem) {
        if (entry.key == 5) return _centerProxyPalace(dunType);
        return entry.key;
      }
    }
    // 如果是甲，找到对应六仪的位置
    if (stem == '甲') return 1;
    return 1;
  }

  /// 中五宫参与八宫轮转时的寄宫：阳遁寄坤2，阴遁寄艮8。
  static int _centerProxyPalace(QimenDunType dunType) {
    return dunType == QimenDunType.yang ? 2 : 8;
  }

  /// 构建天盘：六仪随值符转到时干落宫
  static Map<int, String> _buildHeavenPlate(
    Map<int, String> earthPlate,
    int yiPalace,
    int hourStemPalace,
    QimenDunType dunType,
  ) {
    final ringOrder = [1, 8, 3, 4, 9, 2, 7, 6]; // 八宫顺序
    final result = <int, String>{};

    // 计算转动量：使用ringOrder索引
    final yiPalaceIndex = ringOrder.indexOf(
      _proxyRingPalace(yiPalace, dunType),
    );
    final hourStemPalaceIndex = ringOrder.indexOf(
      _proxyRingPalace(hourStemPalace, dunType),
    );
    final shift = (hourStemPalaceIndex - yiPalaceIndex + 8) % 8;

    for (final palace in ringOrder) {
      final earthStem = earthPlate[palace] ?? '';
      // 计算这个天干应该转到哪个宫
      var targetPalaceIndex = ringOrder.indexOf(palace) + shift;
      targetPalaceIndex = targetPalaceIndex % 8;
      final targetPalace = ringOrder[targetPalaceIndex];
      result[targetPalace] = earthStem;
    }
    // 中宫天盘干跟随地盘
    result[5] = earthPlate[5] ?? '';
    return result;
  }

  /// 构建九星盘：值符星转到时干落宫
  static Map<int, String> _buildStarsPlate(
    int yiPalace,
    int hourStemPalace,
    QimenDunType dunType,
  ) {
    final ringOrder = [1, 8, 3, 4, 9, 2, 7, 6];
    final result = <int, String>{};

    // 九星按宫位原始排列
    final starAtPalace = <int, String>{
      1: '天蓬',
      2: '天芮',
      3: '天冲',
      4: '天辅',
      5: '天禽',
      6: '天心',
      7: '天柱',
      8: '天任',
      9: '天英',
    };

    // 计算转动量
    final yiPalaceIndex = ringOrder.indexOf(
      _proxyRingPalace(yiPalace, dunType),
    );
    final hourStemPalaceIndex = ringOrder.indexOf(
      _proxyRingPalace(hourStemPalace, dunType),
    );
    final shift = (hourStemPalaceIndex - yiPalaceIndex + 8) % 8;

    for (final palace in ringOrder) {
      final star = starAtPalace[palace] ?? '';
      final palaceIndex = ringOrder.indexOf(palace);
      final targetPalaceIndex = (palaceIndex + shift) % 8;
      final targetPalace = ringOrder[targetPalaceIndex];
      result[targetPalace] = star;
    }
    // 中宫天禽寄坤2或艮8
    result[5] = '天禽';
    return result;
  }

  /// 构建八门盘：值使门落宫在飛星序(9宫含中宫)中循环，从落宫开始顺时针排布八门
  static Map<int, String> _buildGatesPlate(
    int yiPalace,
    int hourStemPalace,
    QimenDunType dunType,
    String hourStem,
  ) {
    final ringOrder = [1, 8, 3, 4, 9, 2, 7, 6];
    final result = <int, String>{};

    // 八门顺序（按轉盤序）
    final gateOrder = ['休门', '生门', '伤门', '杜门', '景门', '死门', '惊门', '开门'];

    // 值使门：遁干原宫在轉盤序中的门
    int zhiShiGateIndex;
    int yiPalaceFeixingIndex; // 遁干宫在飛星序中的索引(0-8)

    if (yiPalace == 5) {
      // 遁干在中宫，寄坤2，值使门=死门
      zhiShiGateIndex = 5; // 死门
      yiPalaceFeixingIndex = 4; // 中5宫飛星索引
    } else {
      zhiShiGateIndex = ringOrder.indexOf(yiPalace);
      yiPalaceFeixingIndex = yiPalace - 1; // 飛星序=[1,2,3,4,5,6,7,8,9]
    }

    // 时干偏移（阳遁顺数，阴遁逆数）
    final tianganOrder = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    final hourStemOffset = tianganOrder.indexOf(hourStem);
    final direction = dunType == QimenDunType.yang ? 1 : -1;
    final offset = hourStemOffset * direction;

    // 值使门落宫：在飛星序(9宫含中宫)中循环
    final luoGongFeixingIndex = ((yiPalaceFeixingIndex + offset) % 9 + 9) % 9;
    var luoGongPalace = luoGongFeixingIndex + 1; // 飛星索引转宫号

    // 中宫寄坤2
    if (luoGongPalace == 5) luoGongPalace = 2;

    // 从值使门落宫开始，以值使门为起点，顺时针排布八门
    final luoGongRingIndex = ringOrder.indexOf(luoGongPalace);
    for (var i = 0; i < 8; i++) {
      final palaceIndex = (luoGongRingIndex + i) % 8;
      final palace = ringOrder[palaceIndex];
      final gateIndex = (zhiShiGateIndex + i) % 8;
      result[palace] = gateOrder[gateIndex];
    }
    return result;
  }

  /// 构建八神盘：值符神转到时干落宫
  static Map<int, String> _buildDeitiesPlate(
    int yiPalace,
    int hourStemPalace,
    QimenDunType dunType,
  ) {
    final ringOrder = [1, 8, 3, 4, 9, 2, 7, 6];
    final result = <int, String>{};

    // 八神按宫位排列（阳遁从值符宫开始顺排）
    final deities = dunType == QimenDunType.yang ? _yangDeities : _yinDeities;

    // 计算转动量
    final yiPalaceIndex = ringOrder.indexOf(
      _proxyRingPalace(yiPalace, dunType),
    );
    final hourStemPalaceIndex = ringOrder.indexOf(
      _proxyRingPalace(hourStemPalace, dunType),
    );
    final shift = (hourStemPalaceIndex - yiPalaceIndex + 8) % 8;

    // 值符神在值符原始落宫，其他神顺排
    for (var i = 0; i < 8; i++) {
      final palaceIndex = (yiPalaceIndex + i) % 8;
      final targetPalaceIndex = (palaceIndex + shift) % 8;
      final targetPalace = ringOrder[targetPalaceIndex];
      result[targetPalace] = deities[i];
    }
    return result;
  }

  static int _proxyRingPalace(int palace, QimenDunType dunType) {
    return palace == 5 ? _centerProxyPalace(dunType) : palace;
  }

  /// 获取旬首对应的空亡
  static String _getKongWang(String xunShou) {
    final kongWang = _xunKongWang[xunShou];
    if (kongWang == null) return '';
    return kongWang.join('');
  }

  /// 根据日干支计算旬首
  static String _resolveXunShou(String dayGanzhi) {
    final stem = dayGanzhi.substring(0, 1);
    final branch = dayGanzhi.substring(1);
    final stemIndex = _tiangan.indexOf(stem);
    final branchIndex = _dizhi.indexOf(branch);
    if (stemIndex < 0 || branchIndex < 0) return '甲子';

    // 计算距离旬首的偏移量
    // 旬首的天干一定是甲(index=0)，所以偏移量等于当前天干的index
    final offset = stemIndex;

    // 旬首的地支 = 当前地支 - 偏移量 (mod 12)
    final xunBranchIndex = (branchIndex - offset + 12) % 12;
    final xunBranch = _dizhi[xunBranchIndex];

    return '甲$xunBranch';
  }
}

class _SolarTermMoment {
  const _SolarTermMoment({required this.name, required this.time});

  final String name;
  final DateTime time;
}

class _YuanInfo {
  const _YuanInfo({required this.yuan, required this.fuTou});

  final String yuan;
  final String fuTou;
}
