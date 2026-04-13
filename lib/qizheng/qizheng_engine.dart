import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:lunar/calendar/Lunar.dart';

import 'qizheng_models.dart';

class QizhengEngine {
  static const double _j2000EpochJulianDay = 2451543.5;
  static const double _stationaryThreshold = 0.03;
  static const double _ziQiBaseLongitude = 188.6849;
  static const double _ziQiCycleDays = 10226.78132;
  static const List<String> _palaceNames = [
    '命宫',
    '财帛',
    '兄弟',
    '田宅',
    '男女',
    '奴仆',
    '夫妻',
    '疾厄',
    '迁移',
    '官禄',
    '福德',
    '相貌',
  ];
  static const List<String> _palaceShortNames = [
    '命',
    '财',
    '兄',
    '田',
    '子',
    '仆',
    '妻',
    '疾',
    '迁',
    '官',
    '福',
    '相',
  ];
  static const List<String> _branchNames = [
    '戌',
    '酉',
    '申',
    '未',
    '午',
    '巳',
    '辰',
    '卯',
    '寅',
    '丑',
    '子',
    '亥',
  ];
  static const List<String> _transformRoles = [
    '天禄',
    '天暗',
    '天福',
    '天耗',
    '天荫',
    '天贵',
    '天刑',
    '天印',
    '天囚',
    '天权',
  ];
  static const List<String> _transformDomains = [
    '官禄',
    '相貌',
    '财福迁移',
    '兄弟',
    '夫妻',
    '男女',
    '奴仆',
    '田宅',
    '疾厄',
    '命宫',
  ];
  static const Map<String, QizhengBody> _stemTransformBodies = {
    '甲': QizhengBody.mars,
    '乙': QizhengBody.yueBei,
    '丙': QizhengBody.jupiter,
    '丁': QizhengBody.venus,
    '戊': QizhengBody.saturn,
    '己': QizhengBody.moon,
    '庚': QizhengBody.mercury,
    '辛': QizhengBody.ziQi,
    '壬': QizhengBody.jiDu,
    '癸': QizhengBody.luoHou,
  };
  static const List<String> _stemOrder = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

  static const List<QizhengLocationPreset> locationPresets = [
    QizhengLocationPreset(
      label: '上海',
      longitude: 121.4737,
      latitude: 31.2304,
      utcOffsetMinutes: 480,
    ),
    QizhengLocationPreset(
      label: '北京',
      longitude: 116.4074,
      latitude: 39.9042,
      utcOffsetMinutes: 480,
    ),
    QizhengLocationPreset(
      label: '广州',
      longitude: 113.2644,
      latitude: 23.1291,
      utcOffsetMinutes: 480,
    ),
    QizhengLocationPreset(
      label: '香港',
      longitude: 114.1694,
      latitude: 22.3193,
      utcOffsetMinutes: 480,
    ),
    QizhengLocationPreset(
      label: '台北',
      longitude: 121.5654,
      latitude: 25.0330,
      utcOffsetMinutes: 480,
    ),
    QizhengLocationPreset(
      label: '东京',
      longitude: 139.6917,
      latitude: 35.6895,
      utcOffsetMinutes: 540,
    ),
    QizhengLocationPreset(
      label: '新加坡',
      longitude: 103.8198,
      latitude: 1.3521,
      utcOffsetMinutes: 480,
    ),
    QizhengLocationPreset(
      label: '伦敦',
      longitude: -0.1276,
      latitude: 51.5072,
      utcOffsetMinutes: 0,
    ),
    QizhengLocationPreset(
      label: '纽约',
      longitude: -74.0060,
      latitude: 40.7128,
      utcOffsetMinutes: -300,
    ),
    QizhengLocationPreset(
      label: '洛杉矶',
      longitude: -118.2437,
      latitude: 34.0522,
      utcOffsetMinutes: -480,
    ),
  ];

  static QizhengInput defaultInput() {
    final preset = locationPresets.first;
    return QizhengInput(
      localDateTime: DateTime.now(),
      locationLabel: preset.label,
      longitude: preset.longitude,
      latitude: preset.latitude,
      utcOffsetMinutes: preset.utcOffsetMinutes,
    );
  }

  static QizhengInput inputFromPreset(
    QizhengLocationPreset preset,
    DateTime localDateTime,
  ) {
    return QizhengInput(
      localDateTime: localDateTime,
      locationLabel: preset.label,
      longitude: preset.longitude,
      latitude: preset.latitude,
      utcOffsetMinutes: preset.utcOffsetMinutes,
    );
  }

  static QizhengChart generate(DateTime sourceDateTime) {
    return generateFromInput(defaultInput().copyWith(localDateTime: sourceDateTime));
  }

  static QizhengChart generateFromInput(QizhengInput input) {
    final utc = _toUtcDateTime(input);
    final d = _daysSinceJ2000(utc);
    final nextDayRaw = _calculateRawPositions(d + 1);
    final raw = _calculateRawPositions(d);
    final jd = _julianDay(utc);
    final localSiderealTime = _localSiderealTime(jd, input.longitude);
    final obliquity = _meanObliquity(jd);
    final ascendantLongitude = _ascendantLongitude(
      localSiderealTime,
      input.latitude,
      obliquity,
    );
    final midheavenLongitude = _midheavenLongitude(
      localSiderealTime,
      obliquity,
    );
    final houses = List<QizhengHouse>.generate(
      12,
      (index) => QizhengHouse(
        index: index + 1,
        cuspLongitude: _normalizeAngle(ascendantLongitude + index * 30),
      ),
      growable: false,
    );
    final lunar = Lunar.fromDate(input.localDateTime);

    final positions = QizhengBody.values.map((body) {
      final current = raw[body]!;
      final next = nextDayRaw[body]!;
      final longitude = _normalizeAngle(current.longitude);
      final motionPerDay = _signedAngleDelta(next.longitude, current.longitude);
      return QizhengPosition(
        body: body,
        longitude: longitude,
        latitude: current.latitude,
        houseIndex: _houseIndexForLongitude(longitude, ascendantLongitude),
        motion: _motionOf(motionPerDay),
        motionPerDay: motionPerDay,
      );
    }).toList(growable: false);

    return QizhengChart(
      input: input,
      sourceDateTime: input.localDateTime,
      utcDateTime: utc,
      localSiderealTime: localSiderealTime,
      obliquity: obliquity,
      ascendantLongitude: ascendantLongitude,
      midheavenLongitude: midheavenLongitude,
      lunarDateText: lunar.toString(),
      ganzhiText:
          '${lunar.getYearInGanZhi()} ${lunar.getMonthInGanZhi()} ${lunar.getDayInGanZhi()} ${lunar.getTimeInGanZhi()}',
      xiuInfo: QizhengXiuInfo(
        name: lunar.getXiu(),
        luck: lunar.getXiuLuck(),
        ruling: lunar.getZheng(),
        animal: lunar.getAnimal(),
        quadrant: lunar.getGong(),
        guardian: lunar.getShou(),
        verse: lunar.getXiuSong(),
      ),
      houses: houses,
      aspects: _collectAspects(positions),
      positions: positions,
    );
  }

  static DateTime _toUtcDateTime(QizhengInput input) {
    return DateTime.utc(
      input.localDateTime.year,
      input.localDateTime.month,
      input.localDateTime.day,
      input.localDateTime.hour,
      input.localDateTime.minute,
      input.localDateTime.second,
      input.localDateTime.millisecond,
      input.localDateTime.microsecond,
    ).subtract(Duration(minutes: input.utcOffsetMinutes));
  }

  static String formatCivilDateTime(
    DateTime dateTime,
    int utcOffsetMinutes,
  ) {
    return '${_formatDateTime(dateTime)} ${formatUtcOffsetMinutes(utcOffsetMinutes)}';
  }

  static String formatUtcDateTime(DateTime dateTime) {
    return '${_formatDateTime(dateTime.toUtc())} UTC';
  }

  static String formatUtcOffsetMinutes(int utcOffsetMinutes) {
    final sign = utcOffsetMinutes >= 0 ? '+' : '-';
    final absoluteMinutes = utcOffsetMinutes.abs();
    final hours = (absoluteMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (absoluteMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  static String formatLongitude(double angle) {
    return _formatDegreeMinute(_normalizeAngle(angle), padDegrees: 3);
  }

  static String formatLatitude(double angle) {
    final sign = angle >= 0 ? '+' : '-';
    return '$sign${_formatDegreeMinute(angle.abs())}';
  }

  static String formatCoordinate(double value, {required bool isLongitude}) {
    final positiveLabel = isLongitude ? '东经' : '北纬';
    final negativeLabel = isLongitude ? '西经' : '南纬';
    final label = value >= 0 ? positiveLabel : negativeLabel;
    return '$label${value.abs().toStringAsFixed(2)}°';
  }

  static String formatLocalSiderealTime(double degrees) {
    final hoursValue = _normalizeAngle(degrees) / 15;
    final hours = hoursValue.floor();
    final minutesValue = (hoursValue - hours) * 60;
    final minutes = minutesValue.floor();
    final seconds = ((minutesValue - minutes) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String signTextOf(QizhengPosition position) {
    return signTextOfLongitude(position.longitude);
  }

  static String signTextOfLongitude(double longitude) {
    final signIndex = (_normalizeAngle(longitude) ~/ 30) % 12;
    final sign = QizhengZodiacSign.values[signIndex];
    final degreeInSign = _normalizeAngle(longitude) - signIndex * 30;
    return '${sign.label} ${_formatDegreeMinute(degreeInSign)}';
  }

  static String branchNameOfLongitude(double longitude) {
    final signIndex = (_normalizeAngle(longitude) ~/ 30) % 12;
    return _branchNames[signIndex];
  }

  static String branchTextOfLongitude(double longitude) {
    final signIndex = (_normalizeAngle(longitude) ~/ 30) % 12;
    final degreeInBranch = _normalizeAngle(longitude) - signIndex * 30;
    return '${_branchNames[signIndex]}宫 ${_formatDegreeMinute(degreeInBranch)}';
  }

  static String branchTextOf(QizhengPosition position) {
    return branchTextOfLongitude(position.longitude);
  }

  static String motionTextOf(QizhengPosition position) {
    return '${position.motion.label} ${position.motionPerDay.abs().toStringAsFixed(2)}°/日';
  }

  static String houseLabel(int houseIndex) => '$houseIndex宫';

  static String palaceName(int houseIndex) => _palaceNames[houseIndex - 1];

  static String palaceShortName(int houseIndex) =>
      _palaceShortNames[houseIndex - 1];

  static String palaceHouseLabel(int houseIndex) {
    return '${palaceName(houseIndex)} ${houseLabel(houseIndex)}';
  }

  static String xiuSummaryText(QizhengChart chart) {
    final xiu = chart.xiuInfo;
    return '${_quadrantText(xiu.quadrant)}${xiu.guardian} · ${xiu.fullName} · ${xiu.luck}';
  }

  static String xiuDetailText(QizhengChart chart) {
    final xiu = chart.xiuInfo;
    return '${xiu.fullName}，${_quadrantText(xiu.quadrant)}${xiu.guardian}之宿，值宿${xiu.luck}。';
  }

  static String fateDegreeText(QizhengChart chart) {
    final sun = chart.positionOf(QizhengBody.sun);
    final fateBranch = branchNameOfLongitude(chart.ascendantLongitude);
    return '$fateBranch宫 ${_formatDegreeMinute(sun.degreeInSign)}';
  }

  static String bodyPalaceText(QizhengChart chart) {
    final moon = chart.positionOf(QizhengBody.moon);
    return palaceHouseLabel(moon.houseIndex);
  }

  static String bodyDegreeText(QizhengChart chart) {
    final moon = chart.positionOf(QizhengBody.moon);
    return branchTextOf(moon);
  }

  static String lodgingDegreeText(QizhengChart chart) {
    final xiu = chart.xiuInfo;
    return '${xiu.fullName} · ${xiu.luck}';
  }

  static List<QizhengPillar> pillarsOf(QizhengChart chart) {
    final parts = chart.ganzhiText.split(RegExp(r'\s+'));
    final labels = ['年柱', '月柱', '日柱', '时柱'];
    return List<QizhengPillar>.generate(labels.length, (index) {
      final ganzhi = index < parts.length ? parts[index] : '--';
      final stem = ganzhi.isNotEmpty ? ganzhi.characters.first : '-';
      final branch = ganzhi.length > 1 ? ganzhi.substring(1) : '-';
      return QizhengPillar(
        label: labels[index],
        ganzhi: ganzhi,
        stem: stem,
        branch: branch,
      );
    }, growable: false);
  }

  static List<QizhengTransformation> transformationsOf(QizhengChart chart) {
    return pillarsOf(chart).map((pillar) {
      final body = _stemTransformBodies[pillar.stem];
      if (body == null) {
        return QizhengTransformation(
          pillarLabel: pillar.label,
          stem: pillar.stem,
          body: QizhengBody.sun,
          role: '未定',
          domain: '待补',
        );
      }
      final roleIndex = _stemOrder.indexOf(pillar.stem);
      final normalizedRoleIndex = roleIndex >= 0 ? roleIndex : 0;
      return QizhengTransformation(
        pillarLabel: pillar.label,
        stem: pillar.stem,
        body: body,
        role: _transformRoles[normalizedRoleIndex],
        domain: _transformDomains[normalizedRoleIndex],
      );
    }).toList(growable: false);
  }

  static List<String> patternTexts(QizhengChart chart) {
    final items = <String>[];
    final groupedByHouse = <int, List<QizhengPosition>>{};
    for (final position in chart.positions) {
      groupedByHouse.putIfAbsent(position.houseIndex, () => []).add(position);
    }
    for (final entry in groupedByHouse.entries) {
      if (entry.value.length >= 2) {
        items.add(
          '${palaceName(entry.key)}聚曜',
        );
      }
    }

    final sun = chart.positionOf(QizhengBody.sun);
    final moon = chart.positionOf(QizhengBody.moon);
    if (sun.houseIndex == moon.houseIndex) {
      items.add('日月同临${palaceName(sun.houseIndex)}');
    } else if (_hasAspect(chart, QizhengBody.sun, QizhengBody.moon)) {
      items.add('日月照拱');
    }

    final ascHouseBodies = groupedByHouse[1] ?? const [];
    if (ascHouseBodies.any(
      (position) =>
          position.body == QizhengBody.jupiter ||
          position.body == QizhengBody.venus,
    )) {
      items.add('吉曜入命');
    }
    if ((groupedByHouse[10] ?? const []).any(
      (position) =>
          position.body == QizhengBody.sun ||
          position.body == QizhengBody.jupiter ||
          position.body == QizhengBody.saturn,
    )) {
      items.add('官禄得曜');
    }
    if ((groupedByHouse[7] ?? const []).isNotEmpty) {
      items.add('夫妻见曜');
    }

    for (final aspect in chart.aspects.take(4)) {
      if (aspect.type == QizhengAspectType.conjunction) {
        items.add('${aspect.leftBody.shortLabel}${aspect.rightBody.shortLabel}同宫');
      } else if (aspect.type == QizhengAspectType.trine) {
        items.add('${aspect.leftBody.shortLabel}${aspect.rightBody.shortLabel}成拱');
      } else if (aspect.type == QizhengAspectType.opposition) {
        items.add('${aspect.leftBody.shortLabel}${aspect.rightBody.shortLabel}对冲');
      }
    }

    return items.toSet().take(12).toList(growable: false);
  }

  static List<String> noteTexts(QizhengChart chart) {
    final items = <String>[];
    final ascSign = QizhengZodiacSign.values[
        (_normalizeAngle(chart.ascendantLongitude) ~/ 30) % 12];
    items.add('命宫起于${ascSign.label}，行事风格偏${ascSign.element}。');

    final dominant = dominantSignsText(chart);
    items.add('群曜重心落在$dominant，可先从这些宫位与星座组合入手。');

    final retrogrades = chart.positions.where((item) => item.isRetrograde).toList();
    if (retrogrades.isNotEmpty) {
      items.add(
        '逆行曜为${retrogrades.map((item) => item.body.label).join('、')}，相关宫位应多看回旋、迟滞与反复。',
      );
    }

    final topAspects = chart.aspects.take(3).toList();
    if (topAspects.isNotEmpty) {
      items.add(
        '盘内最紧的相位是${topAspects.map((item) => aspectTextOf(item)).join('；')}。',
      );
    }

    final grouped = <int, int>{};
    for (final position in chart.positions) {
      grouped[position.houseIndex] = (grouped[position.houseIndex] ?? 0) + 1;
    }
    final busiest = grouped.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    if (busiest.isNotEmpty) {
      items.add(
        '${palaceName(busiest.first.key)}最聚曜，说明该宫主题在本命中更容易被放大。',
      );
    }

    return items;
  }

  static bool _hasAspect(
    QizhengChart chart,
    QizhengBody left,
    QizhengBody right,
  ) {
    return chart.aspects.any(
      (aspect) =>
          (aspect.leftBody == left && aspect.rightBody == right) ||
          (aspect.leftBody == right && aspect.rightBody == left),
    );
  }

  static String anglePointText(String label, double longitude) {
    return '$label ${signTextOfLongitude(longitude)}';
  }

  static String dominantSignsText(QizhengChart chart) {
    final counts = <QizhengZodiacSign, int>{};
    for (final sign in QizhengZodiacSign.values) {
      final count = chart.positionsInSign(sign).length;
      if (count > 0) {
        counts[sign] = count;
      }
    }
    final entries = counts.entries.toList()
      ..sort((left, right) {
        final countCompare = right.value.compareTo(left.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return left.key.index.compareTo(right.key.index);
      });
    if (entries.isEmpty) {
      return '无';
    }
    return entries
        .take(3)
        .map((entry) => '${entry.key.label}${entry.value}曜')
        .join(' · ');
  }

  static String retrogradeText(QizhengChart chart) {
    final retrogrades = chart.positions.where((item) => item.isRetrograde);
    if (retrogrades.isEmpty) {
      return '当前无逆行';
    }
    return retrogrades.map((item) => item.body.label).join('、');
  }

  static String aspectTextOf(QizhengAspect aspect) {
    return '${aspect.leftBody.label}${aspect.type.label}${aspect.rightBody.label} 容许${aspect.orb.toStringAsFixed(2)}°';
  }

  static String generateCopyText(QizhengChart chart) {
    final buffer = StringBuffer();
    buffer.writeln('【七政四余校准盘】');
    buffer.writeln(
      '地点：${chart.input.locationLabel} ${formatCoordinate(chart.input.longitude, isLongitude: true)} ${formatCoordinate(chart.input.latitude, isLongitude: false)}',
    );
    buffer.writeln(
      '本地时间：${formatCivilDateTime(chart.sourceDateTime, chart.input.utcOffsetMinutes)}',
    );
    buffer.writeln('UTC时间：${formatUtcDateTime(chart.utcDateTime)}');
    buffer.writeln('农历：${chart.lunarDateText}');
    buffer.writeln('干支：${chart.ganzhiText}');
    buffer.writeln('命宫起度：${branchTextOfLongitude(chart.ascendantLongitude)}');
    buffer.writeln('身宫：${bodyPalaceText(chart)}');
    buffer.writeln('命度：${fateDegreeText(chart)}');
    buffer.writeln('身度：${bodyDegreeText(chart)}');
    buffer.writeln('宿度：${lodgingDegreeText(chart)}');
    buffer.writeln('值日宿：${xiuSummaryText(chart)}');
    buffer.writeln('恒星时：${formatLocalSiderealTime(chart.localSiderealTime)}');
    buffer.writeln();
    buffer.writeln('十一曜躔次：');
    for (final position in chart.positions) {
      buffer.writeln(
        '${position.body.label} 躔${branchTextOf(position)} 入${palaceName(position.houseIndex)} 黄经${formatLongitude(position.longitude)} 黄纬${formatLatitude(position.latitude)} ${motionTextOf(position)}',
      );
    }
    buffer.writeln();
    buffer.writeln('值宿宿辞：${chart.xiuInfo.verse}');
    buffer.writeln();
    buffer.writeln('说明：当前版本先收口为圆盘校准盘，展示命度、身度、宿度与十一曜躔次，后续可继续补宿度分金、宫度主论与古法推限。');
    return buffer.toString();
  }

  static String _quadrantText(String quadrant) {
    switch (quadrant) {
      case '东':
        return '东方';
      case '南':
        return '南方';
      case '西':
        return '西方';
      case '北':
        return '北方';
      default:
        return quadrant;
    }
  }

  static Map<QizhengBody, _PositionState> _calculateRawPositions(double d) {
    final sun = _calculateSun(d);
    final moon = _calculateMoon(d);
    final mercury = _calculatePlanet(d, _PlanetKey.mercury, sun);
    final venus = _calculatePlanet(d, _PlanetKey.venus, sun);
    final mars = _calculatePlanet(d, _PlanetKey.mars, sun);
    final jupiter = _calculatePlanet(d, _PlanetKey.jupiter, sun);
    final saturn = _calculatePlanet(d, _PlanetKey.saturn, sun);
    final ziQiLongitude = _ziQiBaseLongitude + 360 / _ziQiCycleDays * d;

    return <QizhengBody, _PositionState>{
      QizhengBody.sun: _PositionState(longitude: sun.longitude, latitude: 0),
      QizhengBody.moon: _PositionState(
        longitude: moon.longitude,
        latitude: moon.latitude,
      ),
      QizhengBody.mercury: mercury,
      QizhengBody.venus: venus,
      QizhengBody.mars: mars,
      QizhengBody.jupiter: jupiter,
      QizhengBody.saturn: saturn,
      QizhengBody.luoHou: _PositionState(
        longitude: moon.descendingNodeLongitude,
        latitude: 0,
      ),
      QizhengBody.jiDu: _PositionState(
        longitude: moon.ascendingNodeLongitude,
        latitude: 0,
      ),
      QizhengBody.yueBei: _PositionState(
        longitude: moon.apogeeLongitude,
        latitude: 0,
      ),
      QizhengBody.ziQi: _PositionState(
        longitude: ziQiLongitude,
        latitude: 0,
      ),
    };
  }

  static _SunState _calculateSun(double d) {
    final w = 282.9404 + 4.70935e-5 * d;
    final e = 0.016709 - 1.151e-9 * d;
    final m = _normalizeAngle(356.0470 + 0.9856002585 * d);
    final eccentricAnomaly = _solveKepler(m, e);
    final xv = math.cos(_degToRad(eccentricAnomaly)) - e;
    final yv = math.sqrt(1 - e * e) * math.sin(_degToRad(eccentricAnomaly));
    final trueAnomaly = _radToDeg(math.atan2(yv, xv));
    final radius = math.sqrt(xv * xv + yv * yv);
    final longitude = _normalizeAngle(trueAnomaly + w);
    final x = radius * math.cos(_degToRad(longitude));
    final y = radius * math.sin(_degToRad(longitude));
    return _SunState(
      longitude: longitude,
      latitude: 0,
      radius: radius,
      x: x,
      y: y,
      m: m,
    );
  }

  static _MoonState _calculateMoon(double d) {
    final elements = _OrbitalElements(
      n: 125.1228 - 0.0529538083 * d,
      i: 5.1454,
      w: 318.0634 + 0.1643573223 * d,
      a: 60.2666,
      e: 0.054900,
      m: _normalizeAngle(115.3654 + 13.0649929509 * d),
    );

    final base = _orbitalPosition(elements);
    var longitude = base.longitude;
    var latitude = base.latitude;
    var radius = base.radius;

    final sun = _calculateSun(d);
    final meanSunLongitude = _normalizeAngle(sun.m + 282.9404 + 4.70935e-5 * d);
    final meanMoonLongitude = _normalizeAngle(
      elements.m + elements.w + elements.n,
    );
    final dAngle = _normalizeAngle(meanMoonLongitude - meanSunLongitude);
    final fAngle = _normalizeAngle(meanMoonLongitude - elements.n);

    longitude +=
        -1.274 * _sinDeg(elements.m - 2 * dAngle) +
        0.658 * _sinDeg(2 * dAngle) -
        0.186 * _sinDeg(sun.m) -
        0.059 * _sinDeg(2 * elements.m - 2 * dAngle) -
        0.057 * _sinDeg(elements.m - 2 * dAngle + sun.m) +
        0.053 * _sinDeg(elements.m + 2 * dAngle) +
        0.046 * _sinDeg(2 * dAngle - sun.m) +
        0.041 * _sinDeg(elements.m - sun.m) -
        0.035 * _sinDeg(dAngle) -
        0.031 * _sinDeg(elements.m + sun.m) -
        0.015 * _sinDeg(2 * fAngle - 2 * dAngle) +
        0.011 * _sinDeg(elements.m - 4 * dAngle);

    latitude +=
        -0.173 * _sinDeg(fAngle - 2 * dAngle) -
        0.055 * _sinDeg(elements.m - fAngle - 2 * dAngle) -
        0.046 * _sinDeg(elements.m + fAngle - 2 * dAngle) +
        0.033 * _sinDeg(fAngle + 2 * dAngle) +
        0.017 * _sinDeg(2 * elements.m + fAngle);

    radius +=
        -0.58 * _cosDeg(elements.m - 2 * dAngle) -
        0.46 * _cosDeg(2 * dAngle);

    return _MoonState(
      longitude: _normalizeAngle(longitude),
      latitude: latitude,
      radius: radius,
      ascendingNodeLongitude: _normalizeAngle(elements.n),
      descendingNodeLongitude: _normalizeAngle(elements.n + 180),
      apogeeLongitude: _normalizeAngle(elements.n + elements.w + 180),
    );
  }

  static _PositionState _calculatePlanet(
    double d,
    _PlanetKey planet,
    _SunState sun,
  ) {
    final elements = _elementsForPlanet(d, planet);
    final base = _orbitalPosition(elements);
    var heliocentricLongitude = base.longitude;

    if (planet == _PlanetKey.jupiter || planet == _PlanetKey.saturn) {
      final jupiterM = _elementsForPlanet(d, _PlanetKey.jupiter).m;
      final saturnM = _elementsForPlanet(d, _PlanetKey.saturn).m;
      heliocentricLongitude += _outerPlanetPerturbation(
        planet,
        jupiterMeanAnomaly: jupiterM,
        saturnMeanAnomaly: saturnM,
      );
    }

    final adjustedLongitude = _normalizeAngle(heliocentricLongitude);
    final xh = base.radius * _cosDeg(adjustedLongitude) * _cosDeg(base.latitude);
    final yh = base.radius * _sinDeg(adjustedLongitude) * _cosDeg(base.latitude);
    final zh = base.radius * _sinDeg(base.latitude);

    final xg = xh + sun.x;
    final yg = yh + sun.y;
    final zg = zh;

    return _PositionState(
      longitude: _normalizeAngle(_radToDeg(math.atan2(yg, xg))),
      latitude: _radToDeg(math.atan2(zg, math.sqrt(xg * xg + yg * yg))),
    );
  }

  static _OrbitalElements _elementsForPlanet(double d, _PlanetKey planet) {
    switch (planet) {
      case _PlanetKey.mercury:
        return _OrbitalElements(
          n: 48.3313 + 3.24587e-5 * d,
          i: 7.0047 + 5.00e-8 * d,
          w: 29.1241 + 1.01444e-5 * d,
          a: 0.387098,
          e: 0.205635 + 5.59e-10 * d,
          m: _normalizeAngle(168.6562 + 4.0923344368 * d),
        );
      case _PlanetKey.venus:
        return _OrbitalElements(
          n: 76.6799 + 2.46590e-5 * d,
          i: 3.3946 + 2.75e-8 * d,
          w: 54.8910 + 1.38374e-5 * d,
          a: 0.723330,
          e: 0.006773 - 1.302e-9 * d,
          m: _normalizeAngle(48.0052 + 1.6021302244 * d),
        );
      case _PlanetKey.mars:
        return _OrbitalElements(
          n: 49.5574 + 2.11081e-5 * d,
          i: 1.8497 - 1.78e-8 * d,
          w: 286.5016 + 2.92961e-5 * d,
          a: 1.523688,
          e: 0.093405 + 2.516e-9 * d,
          m: _normalizeAngle(18.6021 + 0.5240207766 * d),
        );
      case _PlanetKey.jupiter:
        return _OrbitalElements(
          n: 100.4542 + 2.76854e-5 * d,
          i: 1.3030 - 1.557e-7 * d,
          w: 273.8777 + 1.64505e-5 * d,
          a: 5.20256,
          e: 0.048498 + 4.469e-9 * d,
          m: _normalizeAngle(19.8950 + 0.0830853001 * d),
        );
      case _PlanetKey.saturn:
        return _OrbitalElements(
          n: 113.6634 + 2.38980e-5 * d,
          i: 2.4886 - 1.081e-7 * d,
          w: 339.3939 + 2.97661e-5 * d,
          a: 9.55475,
          e: 0.055546 - 9.499e-9 * d,
          m: _normalizeAngle(316.9670 + 0.0334442282 * d),
        );
    }
  }

  static _HeliocentricState _orbitalPosition(_OrbitalElements elements) {
    final eccentricAnomaly = _solveKepler(elements.m, elements.e);
    final xv = elements.a * (math.cos(_degToRad(eccentricAnomaly)) - elements.e);
    final yv =
        elements.a *
        (math.sqrt(1 - elements.e * elements.e) *
            math.sin(_degToRad(eccentricAnomaly)));
    final trueAnomaly = _radToDeg(math.atan2(yv, xv));
    final radius = math.sqrt(xv * xv + yv * yv);
    final argument = _normalizeAngle(trueAnomaly + elements.w);
    final x =
        radius *
        (_cosDeg(elements.n) * _cosDeg(argument) -
            _sinDeg(elements.n) * _sinDeg(argument) * _cosDeg(elements.i));
    final y =
        radius *
        (_sinDeg(elements.n) * _cosDeg(argument) +
            _cosDeg(elements.n) * _sinDeg(argument) * _cosDeg(elements.i));
    final z = radius * (_sinDeg(argument) * _sinDeg(elements.i));
    final eclipticLongitude = _normalizeAngle(_radToDeg(math.atan2(y, x)));
    final eclipticLatitude =
        _radToDeg(math.atan2(z, math.sqrt(x * x + y * y)));
    return _HeliocentricState(
      longitude: eclipticLongitude,
      latitude: eclipticLatitude,
      radius: radius,
      x: x,
      y: y,
      z: z,
    );
  }

  static List<QizhengAspect> _collectAspects(List<QizhengPosition> positions) {
    final result = <QizhengAspect>[];
    for (var leftIndex = 0; leftIndex < positions.length; leftIndex++) {
      for (var rightIndex = leftIndex + 1; rightIndex < positions.length; rightIndex++) {
        final left = positions[leftIndex];
        final right = positions[rightIndex];
        final separation = _angularDistance(left.longitude, right.longitude);
        QizhengAspect? bestMatch;
        for (final type in QizhengAspectType.values) {
          final orb = (separation - type.exactAngle).abs();
          if (orb > type.orbAllowance) {
            continue;
          }
          final candidate = QizhengAspect(
            leftBody: left.body,
            rightBody: right.body,
            type: type,
            separation: separation,
            orb: orb,
          );
          if (bestMatch == null || candidate.orb < bestMatch.orb) {
            bestMatch = candidate;
          }
        }
        if (bestMatch != null) {
          result.add(bestMatch);
        }
      }
    }
    result.sort((left, right) {
      final orbCompare = left.orb.compareTo(right.orb);
      if (orbCompare != 0) {
        return orbCompare;
      }
      return left.type.exactAngle.compareTo(right.type.exactAngle);
    });
    return result;
  }

  static double _outerPlanetPerturbation(
    _PlanetKey planet, {
    required double jupiterMeanAnomaly,
    required double saturnMeanAnomaly,
  }) {
    switch (planet) {
      case _PlanetKey.jupiter:
        return -0.332 *
                _sinDeg(2 * jupiterMeanAnomaly - 5 * saturnMeanAnomaly - 67.6) -
            0.056 *
                _sinDeg(2 * jupiterMeanAnomaly - 2 * saturnMeanAnomaly + 21) +
            0.042 *
                _sinDeg(3 * jupiterMeanAnomaly - 5 * saturnMeanAnomaly + 21) -
            0.036 * _sinDeg(jupiterMeanAnomaly - 2 * saturnMeanAnomaly) +
            0.022 * _cosDeg(jupiterMeanAnomaly - saturnMeanAnomaly) +
            0.023 *
                _sinDeg(2 * jupiterMeanAnomaly - 3 * saturnMeanAnomaly + 52) -
            0.016 * _sinDeg(jupiterMeanAnomaly - 5 * saturnMeanAnomaly - 69);
      case _PlanetKey.saturn:
        return 0.812 *
                _sinDeg(2 * jupiterMeanAnomaly - 5 * saturnMeanAnomaly - 67.6) -
            0.229 *
                _cosDeg(2 * jupiterMeanAnomaly - 4 * saturnMeanAnomaly - 2) +
            0.119 * _sinDeg(jupiterMeanAnomaly - 2 * saturnMeanAnomaly - 3) +
            0.046 *
                _sinDeg(2 * jupiterMeanAnomaly - 6 * saturnMeanAnomaly - 69) +
            0.014 * _sinDeg(jupiterMeanAnomaly - 3 * saturnMeanAnomaly + 32);
      default:
        return 0;
    }
  }

  static QizhengBodyMotion _motionOf(double motionPerDay) {
    if (motionPerDay.abs() < _stationaryThreshold) {
      return QizhengBodyMotion.stationary;
    }
    return motionPerDay.isNegative
        ? QizhengBodyMotion.retrograde
        : QizhengBodyMotion.direct;
  }

  static int _houseIndexForLongitude(double longitude, double ascendantLongitude) {
    final delta = _normalizeAngle(longitude - ascendantLongitude);
    return (delta ~/ 30) + 1;
  }

  static double _localSiderealTime(double julianDay, double longitude) {
    final t = (julianDay - 2451545.0) / 36525;
    final gmst =
        280.46061837 +
        360.98564736629 * (julianDay - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000;
    return _normalizeAngle(gmst + longitude);
  }

  static double _meanObliquity(double julianDay) {
    final t = (julianDay - 2451545.0) / 36525;
    final seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
    return 23 + 26 / 60 + seconds / 3600;
  }

  static double _midheavenLongitude(
    double localSiderealTime,
    double obliquity,
  ) {
    return _normalizeAngle(
      _radToDeg(
        math.atan2(
          _sinDeg(localSiderealTime),
          _cosDeg(localSiderealTime) * _cosDeg(obliquity),
        ),
      ),
    );
  }

  static double _ascendantLongitude(
    double localSiderealTime,
    double latitude,
    double obliquity,
  ) {
    final raw = _normalizeAngle(
      _radToDeg(
        math.atan2(
          -_cosDeg(localSiderealTime),
          _sinDeg(localSiderealTime) * _cosDeg(obliquity) +
              _tanDeg(latitude) * _sinDeg(obliquity),
        ),
      ),
    );
    return raw < 180 ? raw + 180 : raw - 180;
  }

  static double _solveKepler(double meanAnomalyDegrees, double eccentricity) {
    final meanAnomaly = _degToRad(meanAnomalyDegrees);
    var eccentricAnomaly = meanAnomaly;
    for (var index = 0; index < 6; index++) {
      eccentricAnomaly -=
          (eccentricAnomaly -
                  eccentricity * math.sin(eccentricAnomaly) -
                  meanAnomaly) /
              (1 - eccentricity * math.cos(eccentricAnomaly));
    }
    return _radToDeg(eccentricAnomaly);
  }

  static double _daysSinceJ2000(DateTime utcDateTime) {
    return _julianDay(utcDateTime) - _j2000EpochJulianDay;
  }

  static double _julianDay(DateTime utcDateTime) {
    final utc = utcDateTime.toUtc();
    var year = utc.year;
    var month = utc.month;
    final secondFraction =
        utc.second + utc.millisecond / 1000 + utc.microsecond / 1000000;
    final day = utc.day + (utc.hour + utc.minute / 60 + secondFraction / 3600) / 24;

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final a = year ~/ 100;
    final b = 2 - a + a ~/ 4;

    return (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day +
        b -
        1524.5;
  }

  static double _angularDistance(double left, double right) {
    final normalized = (_normalizeAngle(left) - _normalizeAngle(right)).abs();
    return normalized > 180 ? 360 - normalized : normalized;
  }

  static double _signedAngleDelta(double end, double start) {
    var delta = _normalizeAngle(end) - _normalizeAngle(start);
    if (delta > 180) {
      delta -= 360;
    } else if (delta < -180) {
      delta += 360;
    }
    return delta;
  }

  static double _normalizeAngle(double angle) {
    final normalized = angle % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  static String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  static String _formatDegreeMinute(double value, {int padDegrees = 2}) {
    var degrees = value.floor();
    var minutes = ((value - degrees) * 60).round();
    if (minutes == 60) {
      degrees += 1;
      minutes = 0;
    }
    final degreeText = degrees.toString().padLeft(padDegrees, '0');
    final minuteText = minutes.toString().padLeft(2, '0');
    return '$degreeText°$minuteText′';
  }

  static double _degToRad(double degrees) => degrees * math.pi / 180;

  static double _radToDeg(double radians) => radians * 180 / math.pi;

  static double _sinDeg(double degrees) => math.sin(_degToRad(degrees));

  static double _cosDeg(double degrees) => math.cos(_degToRad(degrees));

  static double _tanDeg(double degrees) => math.tan(_degToRad(degrees));
}

enum _PlanetKey { mercury, venus, mars, jupiter, saturn }

class _PositionState {
  const _PositionState({required this.longitude, required this.latitude});

  final double longitude;
  final double latitude;
}

class _SunState extends _PositionState {
  const _SunState({
    required super.longitude,
    required super.latitude,
    required this.radius,
    required this.x,
    required this.y,
    required this.m,
  });

  final double radius;
  final double x;
  final double y;
  final double m;
}

class _MoonState extends _PositionState {
  const _MoonState({
    required super.longitude,
    required super.latitude,
    required this.radius,
    required this.ascendingNodeLongitude,
    required this.descendingNodeLongitude,
    required this.apogeeLongitude,
  });

  final double radius;
  final double ascendingNodeLongitude;
  final double descendingNodeLongitude;
  final double apogeeLongitude;
}

class _HeliocentricState extends _PositionState {
  const _HeliocentricState({
    required super.longitude,
    required super.latitude,
    required this.radius,
    required this.x,
    required this.y,
    required this.z,
  });

  final double radius;
  final double x;
  final double y;
  final double z;
}

class _OrbitalElements {
  const _OrbitalElements({
    required this.n,
    required this.i,
    required this.w,
    required this.a,
    required this.e,
    required this.m,
  });

  final double n;
  final double i;
  final double w;
  final double a;
  final double e;
  final double m;
}
