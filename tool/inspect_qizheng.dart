import 'package:qimen/qizheng/qizheng_engine.dart';
import 'package:qimen/qizheng/qizheng_models.dart';

void main() {
  final chart = QizhengEngine.generate(DateTime.utc(2000, 1, 1, 12));
  print(QizhengEngine.generateCopyText(chart));
  for (final body in QizhengBody.values) {
    final position = chart.positionOf(body);
    print(
      '${body.label} ${QizhengEngine.branchTextOf(position)} '
      '${QizhengEngine.formatLongitude(position.longitude)} '
      '${QizhengEngine.motionTextOf(position)}',
    );
  }
}
