enum ZiweiGender { male, female }

extension ZiweiGenderLabel on ZiweiGender {
  String get label => this == ZiweiGender.male ? '男命' : '女命';
}

enum ZiweiAnalysisMode { sanhe, feixing, sihua }

extension ZiweiAnalysisModeLabel on ZiweiAnalysisMode {
  String get label {
    switch (this) {
      case ZiweiAnalysisMode.sanhe:
        return '三合';
      case ZiweiAnalysisMode.feixing:
        return '飞星';
      case ZiweiAnalysisMode.sihua:
        return '四化';
    }
  }

  String get description {
    switch (this) {
      case ZiweiAnalysisMode.sanhe:
        return '查看本宫与三方四正联动。';
      case ZiweiAnalysisMode.feixing:
        return '查看宫干飞化落宫与自化。';
      case ZiweiAnalysisMode.sihua:
        return '查看生年四化星与所在宫位。';
    }
  }
}

enum ZiweiDisplayScope { origin, decadal, age, yearly, monthly, daily, hourly }

extension ZiweiDisplayScopeLabel on ZiweiDisplayScope {
  String get label {
    switch (this) {
      case ZiweiDisplayScope.origin:
        return '本命';
      case ZiweiDisplayScope.decadal:
        return '大限';
      case ZiweiDisplayScope.age:
        return '小限';
      case ZiweiDisplayScope.yearly:
        return '流年';
      case ZiweiDisplayScope.monthly:
        return '流月';
      case ZiweiDisplayScope.daily:
        return '流日';
      case ZiweiDisplayScope.hourly:
        return '流时';
    }
  }
}

class ZiweiTimeOption {
  const ZiweiTimeOption({
    required this.index,
    required this.label,
    required this.range,
  });

  final int index;
  final String label;
  final String range;
}

class ZiweiBirthInput {
  const ZiweiBirthInput({
    required this.lunarYear,
    required this.lunarMonth,
    required this.lunarDay,
    required this.timeIndex,
    required this.gender,
    this.isLeapMonth = false,
  });

  final int lunarYear;
  final int lunarMonth;
  final int lunarDay;
  final int timeIndex;
  final ZiweiGender gender;
  final bool isLeapMonth;

  ZiweiBirthInput copyWith({
    int? lunarYear,
    int? lunarMonth,
    int? lunarDay,
    int? timeIndex,
    ZiweiGender? gender,
    bool? isLeapMonth,
  }) {
    return ZiweiBirthInput(
      lunarYear: lunarYear ?? this.lunarYear,
      lunarMonth: lunarMonth ?? this.lunarMonth,
      lunarDay: lunarDay ?? this.lunarDay,
      timeIndex: timeIndex ?? this.timeIndex,
      gender: gender ?? this.gender,
      isLeapMonth: isLeapMonth ?? this.isLeapMonth,
    );
  }
}

class ZiweiFlyTarget {
  const ZiweiFlyTarget({
    required this.label,
    required this.targetIndex,
    required this.targetName,
    required this.isSelf,
  });

  final String label;
  final int? targetIndex;
  final String targetName;
  final bool isSelf;
}

class ZiweiMutagenSummary {
  const ZiweiMutagenSummary({
    required this.label,
    required this.starName,
    required this.palaceName,
    required this.palaceIndex,
  });

  final String label;
  final String starName;
  final String palaceName;
  final int palaceIndex;
}
