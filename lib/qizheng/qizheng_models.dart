enum QizhengBodyGroup { sevenGovernors, fourRemainders }

extension QizhengBodyGroupLabel on QizhengBodyGroup {
  String get label {
    switch (this) {
      case QizhengBodyGroup.sevenGovernors:
        return '七政';
      case QizhengBodyGroup.fourRemainders:
        return '四余';
    }
  }
}

enum QizhengBodyMotion { direct, retrograde, stationary }

extension QizhengBodyMotionLabel on QizhengBodyMotion {
  String get label {
    switch (this) {
      case QizhengBodyMotion.direct:
        return '顺行';
      case QizhengBodyMotion.retrograde:
        return '逆行';
      case QizhengBodyMotion.stationary:
        return '留';
    }
  }
}

enum QizhengDetailFilter { all, sevenGovernors, fourRemainders }

extension QizhengDetailFilterLabel on QizhengDetailFilter {
  String get label {
    switch (this) {
      case QizhengDetailFilter.all:
        return '全部';
      case QizhengDetailFilter.sevenGovernors:
        return '七政';
      case QizhengDetailFilter.fourRemainders:
        return '四余';
    }
  }
}

class QizhengLocationPreset {
  const QizhengLocationPreset({
    required this.label,
    required this.longitude,
    required this.latitude,
    required this.utcOffsetMinutes,
  });

  final String label;
  final double longitude;
  final double latitude;
  final int utcOffsetMinutes;
}

class QizhengInput {
  const QizhengInput({
    required this.localDateTime,
    required this.locationLabel,
    required this.longitude,
    required this.latitude,
    required this.utcOffsetMinutes,
  });

  final DateTime localDateTime;
  final String locationLabel;
  final double longitude;
  final double latitude;
  final int utcOffsetMinutes;

  QizhengInput copyWith({
    DateTime? localDateTime,
    String? locationLabel,
    double? longitude,
    double? latitude,
    int? utcOffsetMinutes,
  }) {
    return QizhengInput(
      localDateTime: localDateTime ?? this.localDateTime,
      locationLabel: locationLabel ?? this.locationLabel,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
    );
  }
}

enum QizhengZodiacSign {
  aries,
  taurus,
  gemini,
  cancer,
  leo,
  virgo,
  libra,
  scorpio,
  sagittarius,
  capricorn,
  aquarius,
  pisces,
}

extension QizhengZodiacSignLabel on QizhengZodiacSign {
  String get label {
    switch (this) {
      case QizhengZodiacSign.aries:
        return '白羊';
      case QizhengZodiacSign.taurus:
        return '金牛';
      case QizhengZodiacSign.gemini:
        return '双子';
      case QizhengZodiacSign.cancer:
        return '巨蟹';
      case QizhengZodiacSign.leo:
        return '狮子';
      case QizhengZodiacSign.virgo:
        return '处女';
      case QizhengZodiacSign.libra:
        return '天秤';
      case QizhengZodiacSign.scorpio:
        return '天蝎';
      case QizhengZodiacSign.sagittarius:
        return '射手';
      case QizhengZodiacSign.capricorn:
        return '摩羯';
      case QizhengZodiacSign.aquarius:
        return '水瓶';
      case QizhengZodiacSign.pisces:
        return '双鱼';
    }
  }

  String get element {
    switch (this) {
      case QizhengZodiacSign.aries:
      case QizhengZodiacSign.leo:
      case QizhengZodiacSign.sagittarius:
        return '火象';
      case QizhengZodiacSign.taurus:
      case QizhengZodiacSign.virgo:
      case QizhengZodiacSign.capricorn:
        return '土象';
      case QizhengZodiacSign.gemini:
      case QizhengZodiacSign.libra:
      case QizhengZodiacSign.aquarius:
        return '风象';
      case QizhengZodiacSign.cancer:
      case QizhengZodiacSign.scorpio:
      case QizhengZodiacSign.pisces:
        return '水象';
    }
  }
}

enum QizhengBody {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  luoHou,
  jiDu,
  yueBei,
  ziQi,
}

extension QizhengBodyMeta on QizhengBody {
  String get label {
    switch (this) {
      case QizhengBody.sun:
        return '太阳';
      case QizhengBody.moon:
        return '太阴';
      case QizhengBody.mercury:
        return '水星';
      case QizhengBody.venus:
        return '金星';
      case QizhengBody.mars:
        return '火星';
      case QizhengBody.jupiter:
        return '木星';
      case QizhengBody.saturn:
        return '土星';
      case QizhengBody.luoHou:
        return '罗喉';
      case QizhengBody.jiDu:
        return '计都';
      case QizhengBody.yueBei:
        return '月孛';
      case QizhengBody.ziQi:
        return '紫炁';
    }
  }

  String get shortLabel {
    switch (this) {
      case QizhengBody.sun:
        return '日';
      case QizhengBody.moon:
        return '月';
      case QizhengBody.mercury:
        return '水';
      case QizhengBody.venus:
        return '金';
      case QizhengBody.mars:
        return '火';
      case QizhengBody.jupiter:
        return '木';
      case QizhengBody.saturn:
        return '土';
      case QizhengBody.luoHou:
        return '罗';
      case QizhengBody.jiDu:
        return '计';
      case QizhengBody.yueBei:
        return '孛';
      case QizhengBody.ziQi:
        return '炁';
    }
  }

  String get description {
    switch (this) {
      case QizhengBody.sun:
        return '日政主气';
      case QizhengBody.moon:
        return '月政主情';
      case QizhengBody.mercury:
        return '辰星近阳';
      case QizhengBody.venus:
        return '太白明锐';
      case QizhengBody.mars:
        return '荧惑刚烈';
      case QizhengBody.jupiter:
        return '岁星舒展';
      case QizhengBody.saturn:
        return '镇星持重';
      case QizhengBody.luoHou:
        return '白道降交点';
      case QizhengBody.jiDu:
        return '白道升交点';
      case QizhengBody.yueBei:
        return '月轮远地点';
      case QizhengBody.ziQi:
        return '古法四余之一';
    }
  }

  QizhengBodyGroup get group {
    switch (this) {
      case QizhengBody.sun:
      case QizhengBody.moon:
      case QizhengBody.mercury:
      case QizhengBody.venus:
      case QizhengBody.mars:
      case QizhengBody.jupiter:
      case QizhengBody.saturn:
        return QizhengBodyGroup.sevenGovernors;
      case QizhengBody.luoHou:
      case QizhengBody.jiDu:
      case QizhengBody.yueBei:
      case QizhengBody.ziQi:
        return QizhengBodyGroup.fourRemainders;
    }
  }
}

enum QizhengAspectType { conjunction, sextile, square, trine, opposition }

extension QizhengAspectTypeMeta on QizhengAspectType {
  String get label {
    switch (this) {
      case QizhengAspectType.conjunction:
        return '合';
      case QizhengAspectType.sextile:
        return '六合';
      case QizhengAspectType.square:
        return '刑';
      case QizhengAspectType.trine:
        return '拱';
      case QizhengAspectType.opposition:
        return '冲';
    }
  }

  double get exactAngle {
    switch (this) {
      case QizhengAspectType.conjunction:
        return 0;
      case QizhengAspectType.sextile:
        return 60;
      case QizhengAspectType.square:
        return 90;
      case QizhengAspectType.trine:
        return 120;
      case QizhengAspectType.opposition:
        return 180;
    }
  }

  double get orbAllowance {
    switch (this) {
      case QizhengAspectType.conjunction:
      case QizhengAspectType.opposition:
        return 8;
      case QizhengAspectType.square:
      case QizhengAspectType.trine:
        return 6;
      case QizhengAspectType.sextile:
        return 4;
    }
  }
}

enum QizhengInsightTab { pillars, transformedStars, aspects, patterns, notes }

extension QizhengInsightTabLabel on QizhengInsightTab {
  String get label {
    switch (this) {
      case QizhengInsightTab.pillars:
        return '四柱';
      case QizhengInsightTab.transformedStars:
        return '化曜';
      case QizhengInsightTab.aspects:
        return '相位';
      case QizhengInsightTab.patterns:
        return '星格';
      case QizhengInsightTab.notes:
        return '批注';
    }
  }
}

class QizhengPillar {
  const QizhengPillar({
    required this.label,
    required this.ganzhi,
    required this.stem,
    required this.branch,
  });

  final String label;
  final String ganzhi;
  final String stem;
  final String branch;
}

class QizhengTransformation {
  const QizhengTransformation({
    required this.pillarLabel,
    required this.stem,
    required this.body,
    required this.role,
    required this.domain,
  });

  final String pillarLabel;
  final String stem;
  final QizhengBody body;
  final String role;
  final String domain;
}

class QizhengXiuInfo {
  const QizhengXiuInfo({
    required this.name,
    required this.luck,
    required this.ruling,
    required this.animal,
    required this.quadrant,
    required this.guardian,
    required this.verse,
  });

  final String name;
  final String luck;
  final String ruling;
  final String animal;
  final String quadrant;
  final String guardian;
  final String verse;

  String get fullName => '$name$ruling$animal';
}

class QizhengLodgingResult {
  const QizhengLodgingResult({
    required this.mansion,
    required this.host,
    required this.animal,
    required this.degreeValue,
    required this.degree,
    required this.fraction,
    required this.finenessElement,
  });

  final String mansion;
  final String host;
  final String animal;
  final double degreeValue;
  final int degree;
  final int fraction;
  final String finenessElement;

  String get fullName => '$mansion$host$animal';

  String get degreeText {
    final fractionText = fraction.toString().padLeft(2, '0');
    if (degree <= 0) {
      return '初度$fractionText分';
    }
    return '$degree度$fractionText分';
  }

  String get conciseText => '$fullName $degreeText';

  String get finenessText => '$finenessElement分金';
}

class QizhengLodgingSegment {
  const QizhengLodgingSegment({
    required this.mansion,
    required this.fullName,
    required this.startLongitude,
    required this.endLongitude,
  });

  final String mansion;
  final String fullName;
  final double startLongitude;
  final double endLongitude;
}

class QizhengHouse {
  const QizhengHouse({required this.index, required this.cuspLongitude});

  final int index;
  final double cuspLongitude;
}

class QizhengAspect {
  const QizhengAspect({
    required this.leftBody,
    required this.rightBody,
    required this.type,
    required this.separation,
    required this.orb,
  });

  final QizhengBody leftBody;
  final QizhengBody rightBody;
  final QizhengAspectType type;
  final double separation;
  final double orb;
}

class QizhengPosition {
  const QizhengPosition({
    required this.body,
    required this.longitude,
    required this.latitude,
    required this.houseIndex,
    required this.motion,
    required this.motionPerDay,
  });

  final QizhengBody body;
  final double longitude;
  final double latitude;
  final int houseIndex;
  final QizhengBodyMotion motion;
  final double motionPerDay;

  QizhengZodiacSign get sign => QizhengZodiacSign.values[signIndex];

  int get signIndex => (longitude ~/ 30) % 12;

  double get degreeInSign => longitude - signIndex * 30;

  bool get isRetrograde => motion == QizhengBodyMotion.retrograde;
}

class QizhengChart {
  const QizhengChart({
    required this.input,
    required this.sourceDateTime,
    required this.utcDateTime,
    required this.localSiderealTime,
    required this.obliquity,
    required this.ascendantLongitude,
    required this.midheavenLongitude,
    required this.lunarDateText,
    required this.ganzhiText,
    required this.xiuInfo,
    required this.houses,
    required this.aspects,
    required this.positions,
  });

  final QizhengInput input;
  final DateTime sourceDateTime;
  final DateTime utcDateTime;
  final double localSiderealTime;
  final double obliquity;
  final double ascendantLongitude;
  final double midheavenLongitude;
  final String lunarDateText;
  final String ganzhiText;
  final QizhengXiuInfo xiuInfo;
  final List<QizhengHouse> houses;
  final List<QizhengAspect> aspects;
  final List<QizhengPosition> positions;

  QizhengPosition positionOf(QizhengBody body) {
    return positions.firstWhere((item) => item.body == body);
  }

  QizhengHouse houseOf(int index) {
    return houses.firstWhere((item) => item.index == index);
  }

  List<QizhengPosition> positionsInSign(QizhengZodiacSign sign) {
    final items = positions.where((item) => item.sign == sign).toList();
    items.sort((left, right) => left.degreeInSign.compareTo(right.degreeInSign));
    return items;
  }

  List<QizhengPosition> positionsForFilter(QizhengDetailFilter filter) {
    switch (filter) {
      case QizhengDetailFilter.all:
        return positions;
      case QizhengDetailFilter.sevenGovernors:
        return positions
            .where(
              (item) => item.body.group == QizhengBodyGroup.sevenGovernors,
            )
            .toList(growable: false);
      case QizhengDetailFilter.fourRemainders:
        return positions
            .where(
              (item) => item.body.group == QizhengBodyGroup.fourRemainders,
            )
            .toList(growable: false);
    }
  }
}
