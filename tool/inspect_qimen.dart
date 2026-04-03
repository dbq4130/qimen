import '../lib/qimen/qimen_engine.dart';
import '../lib/qimen/qimen_models.dart';

void main() {
  for (final setupMethod in QimenSetupMethod.values) {
    final pan = QimenEngine.generate(
      dateTime: DateTime(2026, 4, 3, 14, 7),
      manualDunType: QimenDunType.yang,
      useAutoDunType: true,
      panMode: QimenPanMode.zhuan,
      setupMethod: setupMethod,
      bureau: 6,
    );

    print('--- ${setupMethod.label} ---');
    print(
      'solarTerm=${pan.solarTerm} year=${pan.yearGanzhi} month=${pan.monthGanzhi} day=${pan.dayGanzhi} hour=${pan.hourGanzhi}',
    );
    print(
      'chief=${pan.chiefDeity} valueStar=${pan.valueStar} valueGate=${pan.valueGate}',
    );
    final cell = pan.cells.firstWhere((item) => item.palaceNumber == 9);
    print(
      '${cell.palaceName}: deity=${cell.deity}, star=${cell.star}, gate=${cell.gate}, heaven=${cell.heavenStem}, earth=${cell.earthStem}',
    );
  }
}
