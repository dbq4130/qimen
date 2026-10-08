const String zeriCautionMark = '！';

enum SittingBureau {
  fire('火局', ['申'], true, '忌用申年月日时（切记）。用了有凶灾车祸，虽然正体属金，因为天星有参水猿。'),
  water('水局', ['丁'], true, '忌用丁年月日时（切记）。'),
  wood('木局', ['戊', '丑'], false, '忌用戊、丑年月日时。没有写切记，时辰标感叹号，仍可选。'),
  earth('土局', ['辰', '未'], false, '忌用辰、未年月日时。没有写切记，时辰标感叹号，仍可选。'),
  metal('金局', ['丙'], true, '忌用丙年月日时（切记，怕喝农药）。');

  const SittingBureau(this.label, this.avoid, this.strict, this.note);

  final String label;
  final List<String> avoid;
  final bool strict;
  final String note;
}

enum YongshenMountain {
  jia('甲', '甲', '天干'),
  yi('乙', '乙', '天干'),
  bing('丙', '丙', '天干'),
  ding('丁', '丁', '天干'),
  wu('戊', '戊', '天干'),
  ji('己', '己', '天干'),
  geng('庚', '庚', '天干'),
  xin('辛', '辛', '天干'),
  ren('壬', '壬', '天干'),
  gui('癸', '癸', '天干'),
  zi('子', '子', '地支'),
  chou('丑', '丑', '地支'),
  yin('寅', '寅', '地支'),
  mao('卯', '卯', '地支'),
  chen('辰', '辰', '地支'),
  si('巳', '巳', '地支'),
  wuZhi('午', '午', '地支'),
  wei('未', '未', '地支'),
  shen('申', '申', '地支'),
  you('酉', '酉', '地支'),
  xu('戌', '戌', '地支'),
  hai('亥', '亥', '地支'),
  qian('乾', '甲', '卦'),
  kun('坤', '乙', '卦'),
  gen('艮', '丙', '卦'),
  xun('巽', '辛', '卦'),
  zhen('震', '庚', '卦'),
  dui('兑', '丁', '卦'),
  li('离', '壬', '卦'),
  kan('坎', '癸', '卦');

  const YongshenMountain(this.label, this.stem, this.group);

  final String label;
  final String stem;
  final String group;

  static List<YongshenMountain> get stems =>
      values.where((item) => item.group == '天干').toList(growable: false);

  static List<YongshenMountain> get branches =>
      values.where((item) => item.group == '地支').toList(growable: false);

  static List<YongshenMountain> get trigrams =>
      values.where((item) => item.group == '卦').toList(growable: false);
}

class YongshenMonths {
  const YongshenMonths({
    required this.changsheng,
    required this.chong,
    required this.tong,
    required this.branches,
    required this.namedChangsheng,
  });

  final String changsheng;
  final String chong;
  final String tong;
  final List<String> branches;
  final bool namedChangsheng;

  String get label {
    final names = [
      for (final branch in branches)
        if (namedChangsheng && branch == changsheng)
          '$branch（长生）'
        else if (branch == chong)
          '$branch（冲）'
        else if (branch == tong)
          '$branch（通）'
        else
          branch,
    ];
    return '参考 ${names.join(' ')}';
  }
}

enum DayCourse {
  generate,
  control;

  String get label => switch (this) {
    DayCourse.generate => '上吉 · 月生日',
    DayCourse.control => '穴位 · 日克月',
  };
}

enum HourRelation {
  hourGeneratesDay,
  dayControlsHour;

  String get label => switch (this) {
    HourRelation.hourGeneratesDay => '时生日',
    HourRelation.dayControlsHour => '日克时',
  };
}

class ZeriHit {
  const ZeriHit({
    required this.where,
    required this.character,
    required this.strict,
  });

  final String where;
  final String character;
  final bool strict;

  String get label => '$where柱含$character';
}

class ZeriHour {
  const ZeriHour({
    required this.ganzhi,
    required this.zhi,
    required this.relation,
    required this.relationDetail,
    required this.rangeText,
    required this.startText,
    required this.hourHits,
    required this.selectable,
    required this.showExclamation,
    required this.sealedLabel,
  });

  final String ganzhi;
  final String zhi;
  final HourRelation relation;
  final String relationDetail;
  final String rangeText;
  final String startText;
  final List<ZeriHit> hourHits;
  final bool selectable;
  final bool showExclamation;
  final String? sealedLabel;

  String get relationLabel => relation.label;
}

class ZeriDay {
  const ZeriDay({
    required this.lunarDay,
    required this.lunarDayLabel,
    required this.lunarMark,
    required this.lunarDateText,
    required this.yearAnimal,
    required this.solarDay,
    required this.weekday,
    required this.solarText,
    required this.yearGanzhi,
    required this.monthGanzhi,
    required this.dayGanzhi,
    required this.course,
    required this.courseDetail,
    required this.jianchu,
    required this.jianchuTone,
    required this.blockedReason,
    required this.sharedHits,
    required this.hours,
    required this.favoredMonth,
    required this.yi,
    required this.ji,
    required this.unusableReason,
    required this.hourTabooReason,
    required this.keptMonthReason,
  });

  final int lunarDay;
  final String lunarDayLabel;
  final String lunarMark;
  final String lunarDateText;
  final String yearAnimal;
  final int solarDay;
  final int weekday;
  final String solarText;
  final String yearGanzhi;
  final String monthGanzhi;
  final String dayGanzhi;
  final DayCourse? course;
  final String courseDetail;
  final String jianchu;
  final String jianchuTone;
  final String? blockedReason;
  final List<ZeriHit> sharedHits;
  final List<ZeriHour> hours;
  final bool favoredMonth;
  final List<String> yi;
  final List<String> ji;
  final String? unusableReason;
  final String? hourTabooReason;
  final String? keptMonthReason;

  String get courseLabel => course?.label ?? '';

  bool get selectable => hours.any((hour) => hour.selectable);

  bool get cautioned => hours.any((hour) => hour.showExclamation);
}

class ZeriMonthBoard {
  const ZeriMonthBoard({
    required this.lunarYear,
    required this.lunarMonth,
    required this.title,
    required this.days,
  });

  final int lunarYear;
  final int lunarMonth;
  final String title;
  final List<ZeriDay> days;
}
