import '../lib/qimen/qimen_engine.dart';
import '../lib/qimen/qimen_models.dart';

void main() {
  final cases = <DateTime>[
    DateTime(2026, 4, 3, 14, 7),
    DateTime(2027, 4, 22, 18, 50),
  ];

  for (final dateTime in cases) {
    for (final setupMethod in QimenSetupMethod.values) {
      final pan = QimenEngine.generate(
        dateTime: dateTime,
        manualDunType: null,
        useAutoDunType: true,
        panMode: QimenPanMode.zhuan,
        setupMethod: setupMethod,
        manualBureau: null,
        useAutoBureau: true,
      );

      print(
        '--- ${QimenEngine.formatDateTime(dateTime)} ${setupMethod.label} ---',
      );
      print(
        'solarTerm=${pan.solarTerm} year=${pan.yearGanzhi} month=${pan.monthGanzhi} day=${pan.dayGanzhi} hour=${pan.hourGanzhi}',
      );
      print(
        'yuan=${pan.yuan} dun=${pan.dunType.label}${pan.bureau}局 xunShou=${pan.xunShou}${pan.xunYi}',
      );
      print(
        'valueStar=${pan.valueStar} valueGate=${pan.valueGate} horse=${pan.horseStar}',
      );
      for (final cell in pan.cells) {
        final starText = cell.hasTianQinStar
            ? '${cell.tianQinStem}${cell.star}禽'
            : cell.star;
        print(
          '${cell.palaceNumber}: deity=${cell.deity}, star=$starText, gate=${cell.gate}, heaven=${cell.heavenStem}, earth=${cell.earthStem}',
        );
      }
      print('');
    }
  }
}
