import '../lib/qimen/qimen_engine.dart';
import '../lib/qimen/qimen_models.dart';

void main(List<String> args) {
  final year = args.isNotEmpty ? int.tryParse(args.first) ?? 2027 : 2027;
  final hits = <String>[];
  final errors = <String>[];

  for (var month = 1; month <= 12; month++) {
    for (var day = 1; day <= 31; day++) {
      for (var hour = 0; hour < 24; hour += 2) {
        final dt = DateTime(year, month, day, hour, 0);
        if (dt.month != month || dt.day != day) {
          continue;
        }

        final pan = QimenEngine.generate(
          dateTime: dt,
          manualDunType: null,
          useAutoDunType: true,
          panMode: QimenPanMode.zhuan,
          setupMethod: QimenSetupMethod.chaibu,
          manualBureau: null,
          useAutoBureau: true,
        );

        if (pan.valueStar != '天禽') {
          continue;
        }

        final tianQinCells = pan.cells
            .where((cell) => cell.hasTianQinStar)
            .toList();
        final tianQinStemCells = pan.cells
            .where((cell) => cell.hasTianQinStem)
            .toList();
        final expectedStemPalace = pan.dunType == QimenDunType.yang ? 2 : 8;

        hits.add(
          '${QimenEngine.formatDateTime(dt)} ${pan.solarTerm} '
          '${pan.dunType.label}${pan.bureau}局 '
          '${pan.dayGanzhi}/${pan.hourGanzhi} '
          'starPalace=${tianQinCells.map((c) => c.palaceNumber).join(",")} '
          'stemPalace=${tianQinStemCells.map((c) => c.palaceNumber).join(",")}',
        );

        if (tianQinCells.length != 1) {
          errors.add(
            '${QimenEngine.formatDateTime(dt)} expected 1 tianqin star palace, got ${tianQinCells.length}',
          );
        }
        if (tianQinStemCells.length != 1) {
          errors.add(
            '${QimenEngine.formatDateTime(dt)} expected 1 tianqin stem palace, got ${tianQinStemCells.length}',
          );
        }
        if (tianQinStemCells.length == 1 &&
            tianQinStemCells.single.palaceNumber != expectedStemPalace) {
          errors.add(
            '${QimenEngine.formatDateTime(dt)} expected stem proxy palace $expectedStemPalace, got ${tianQinStemCells.single.palaceNumber}',
          );
        }
      }
    }
  }

  print('year=$year count=${hits.length}');
  for (final hit in hits) {
    print(hit);
  }
  if (errors.isEmpty) {
    print('errors=0');
  } else {
    print('errors=${errors.length}');
    for (final error in errors) {
      print(error);
    }
  }
}
