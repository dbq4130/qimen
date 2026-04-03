enum QimenDunType { yang, yin }

extension QimenDunTypeLabel on QimenDunType {
  String get label => this == QimenDunType.yang ? '阳遁' : '阴遁';
}

enum QimenPanMode { zhuan, fei }

extension QimenPanModeLabel on QimenPanMode {
  String get label => this == QimenPanMode.zhuan ? '转盘' : '飞盘';
}

enum QimenSetupMethod { chaibu, angan, zhishimen }

extension QimenSetupMethodLabel on QimenSetupMethod {
  String get label {
    switch (this) {
      case QimenSetupMethod.chaibu:
        return '拆补';
      case QimenSetupMethod.angan:
        return '暗干起法';
      case QimenSetupMethod.zhishimen:
        return '值使门起';
    }
  }
}

class QimenPanCell {
  const QimenPanCell({
    required this.palaceNumber,
    required this.palaceName,
    required this.deity,
    required this.star,
    required this.gate,
    required this.heavenStem,
    required this.earthStem,
    required this.isCenter,
  });

  final int palaceNumber;
  final String palaceName;
  final String deity;
  final String star;
  final String gate;
  final String heavenStem;
  final String earthStem;
  final bool isCenter;
}

class QimenPan {
  const QimenPan({
    required this.generatedAt,
    required this.solarTerm,
    required this.yearGanzhi,
    required this.monthGanzhi,
    required this.dayGanzhi,
    required this.hourGanzhi,
    required this.dunType,
    required this.panMode,
    required this.setupMethod,
    required this.bureau,
    required this.hourLabel,
    required this.valueStar,
    required this.valueGate,
    required this.chiefDeity,
    required this.note,
    required this.cells,
  });

  final DateTime generatedAt;
  final String solarTerm;
  final String yearGanzhi;
  final String monthGanzhi;
  final String dayGanzhi;
  final String hourGanzhi;
  final QimenDunType dunType;
  final QimenPanMode panMode;
  final QimenSetupMethod setupMethod;
  final int bureau;
  final String hourLabel;
  final String valueStar;
  final String valueGate;
  final String chiefDeity;
  final String note;
  final List<QimenPanCell> cells;
}
