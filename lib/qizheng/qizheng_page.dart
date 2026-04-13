import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'qizheng_engine.dart';
import 'qizheng_models.dart';

class QizhengPage extends StatefulWidget {
  const QizhengPage({super.key});

  @override
  State<QizhengPage> createState() => _QizhengPageState();
}

class _QizhengPageState extends State<QizhengPage> {
  late QizhengInput _input;
  late QizhengChart _chart;

  @override
  void initState() {
    super.initState();
    _input = QizhengEngine.defaultInput();
    _chart = QizhengEngine.generateFromInput(_input);
  }

  void _updateInput(QizhengInput nextInput) {
    setState(() {
      _input = nextInput;
      _chart = QizhengEngine.generateFromInput(nextInput);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _input.localDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    _updateInput(
      _input.copyWith(
        localDateTime: DateTime(
          picked.year,
          picked.month,
          picked.day,
          _input.localDateTime.hour,
          _input.localDateTime.minute,
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_input.localDateTime),
    );
    if (picked == null) {
      return;
    }
    _updateInput(
      _input.copyWith(
        localDateTime: DateTime(
          _input.localDateTime.year,
          _input.localDateTime.month,
          _input.localDateTime.day,
          picked.hour,
          picked.minute,
        ),
      ),
    );
  }

  Future<void> _pickPresetLocation() async {
    final selected = await showModalBottomSheet<QizhengLocationPreset>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final preset in QizhengEngine.locationPresets)
                ListTile(
                  title: Text(preset.label),
                  subtitle: Text(
                    '${QizhengEngine.formatCoordinate(preset.longitude, isLongitude: true)}  ${QizhengEngine.formatCoordinate(preset.latitude, isLongitude: false)}  ${QizhengEngine.formatUtcOffsetMinutes(preset.utcOffsetMinutes)}',
                  ),
                  trailing: _input.locationLabel == preset.label
                      ? const Icon(Icons.check_circle_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(preset),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null) {
      return;
    }
    _updateInput(QizhengEngine.inputFromPreset(selected, _input.localDateTime));
  }

  Future<void> _editLocation() async {
    final labelController = TextEditingController(text: _input.locationLabel);
    final longitudeController = TextEditingController(
      text: _input.longitude.toStringAsFixed(4),
    );
    final latitudeController = TextEditingController(
      text: _input.latitude.toStringAsFixed(4),
    );
    final offsetController = TextEditingController(
      text: (_input.utcOffsetMinutes / 60).toStringAsFixed(
        _input.utcOffsetMinutes % 60 == 0 ? 0 : 1,
      ),
    );

    QizhengInput? result;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('编辑地点与时区'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(labelText: '地点名称'),
                    ),
                    TextField(
                      controller: longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: '经度',
                        helperText: '东经为正，西经为负',
                      ),
                    ),
                    TextField(
                      controller: latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: '纬度',
                        helperText: '北纬为正，南纬为负',
                      ),
                    ),
                    TextField(
                      controller: offsetController,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'UTC时区偏移',
                        helperText: '例如中国填 8，纽约填 -5',
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Color(0xFFB3261E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    final longitude = double.tryParse(longitudeController.text);
                    final latitude = double.tryParse(latitudeController.text);
                    final offsetHours = double.tryParse(offsetController.text);
                    if (longitude == null ||
                        latitude == null ||
                        offsetHours == null) {
                      setDialogState(() {
                        errorText = '经度、纬度和时区偏移需要是数字。';
                      });
                      return;
                    }
                    if (longitude < -180 || longitude > 180) {
                      setDialogState(() {
                        errorText = '经度需要在 -180 到 180 之间。';
                      });
                      return;
                    }
                    if (latitude < -66 || latitude > 66) {
                      setDialogState(() {
                        errorText = '当前版本先支持 -66 到 66 度纬度。';
                      });
                      return;
                    }
                    final utcOffsetMinutes = (offsetHours * 60).round();
                    result = _input.copyWith(
                      locationLabel: labelController.text.trim().isEmpty
                          ? '自定义地点'
                          : labelController.text.trim(),
                      longitude: longitude,
                      latitude: latitude,
                      utcOffsetMinutes: utcOffsetMinutes,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      _updateInput(result!);
    }
  }

  void _recalculate() {
    _updateInput(_input);
  }

  Future<void> _openControlsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: _buildControlCard(theme),
          ),
        );
      },
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(
      ClipboardData(text: QizhengEngine.generateCopyText(_chart)),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('七政四余校准盘信息已复制'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('七政四余'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0C4151),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _openControlsSheet,
            tooltip: '排盘参数',
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            onPressed: _copyToClipboard,
            tooltip: '复制排盘',
            icon: const Icon(Icons.copy_all_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1EAD7), Color(0xFFE2D4B0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: _buildWheelCard(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildControlCard(ThemeData theme) {
    return _QizhengPaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '排盘参数',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F4B5D),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionChipButton(
                icon: Icons.calendar_month_rounded,
                label:
                    '${_input.localDateTime.year}-${_input.localDateTime.month.toString().padLeft(2, '0')}-${_input.localDateTime.day.toString().padLeft(2, '0')}',
                onTap: _pickDate,
              ),
              _ActionChipButton(
                icon: Icons.schedule_rounded,
                label:
                    '${_input.localDateTime.hour.toString().padLeft(2, '0')}:${_input.localDateTime.minute.toString().padLeft(2, '0')}',
                onTap: _pickTime,
              ),
              _ActionChipButton(
                icon: Icons.location_city_rounded,
                label: _input.locationLabel,
                onTap: _pickPresetLocation,
              ),
              _ActionChipButton(
                icon: Icons.tune_rounded,
                label: '经纬度/时区',
                onTap: _editLocation,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F1F4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9EC6CF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${QizhengEngine.formatCoordinate(_input.longitude, isLongitude: true)}  ${QizhengEngine.formatCoordinate(_input.latitude, isLongitude: false)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF224E59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '时区 ${QizhengEngine.formatUtcOffsetMinutes(_input.utcOffsetMinutes)}，当前页面先按圆盘校准盘呈现，重点保留二十八宿落度、宿度分金与十一曜躔次。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF355E69),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _recalculate,
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('重排七政四余校准盘'),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelCard(ThemeData theme) {
    final legendItems = _chart.positions.toList()
      ..sort((left, right) => left.longitude.compareTo(right.longitude));

    return _QizhengPaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '圆盘总览',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F4B5D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '外圈显示二十八宿落度，中圈保留十二支分野，内圈改按命宫逆布十二人事宫；可从右上角进入参数面板调整时间、地点和时区。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5D6C70),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final dimension = math.min(constraints.maxWidth, 420.0);
              return Center(
                child: SizedBox.square(
                  dimension: dimension,
                  child: CustomPaint(
                    painter: _QizhengWheelPainter(chart: _chart),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: legendItems
                .map((position) {
                  final lodging = QizhengEngine.lodgingOf(position);
                  return _MinorTag(
                    label:
                        '${position.body.shortLabel} ${lodging.mansion}${lodging.degreeText} ${lodging.finenessText}',
                    backgroundColor: _bodyColor(
                      position.body,
                    ).withValues(alpha: 0.16),
                    foregroundColor: _bodyColor(position.body),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Color _bodyColor(QizhengBody body) {
    switch (body) {
      case QizhengBody.sun:
        return const Color(0xFFB66800);
      case QizhengBody.moon:
        return const Color(0xFF4F6889);
      case QizhengBody.mercury:
        return const Color(0xFF2B7A78);
      case QizhengBody.venus:
        return const Color(0xFF7A3E8E);
      case QizhengBody.mars:
        return const Color(0xFFB63A2B);
      case QizhengBody.jupiter:
        return const Color(0xFF7A5D00);
      case QizhengBody.saturn:
        return const Color(0xFF5D6C70);
      case QizhengBody.luoHou:
        return const Color(0xFF0E566A);
      case QizhengBody.jiDu:
        return const Color(0xFF9F3E2F);
      case QizhengBody.yueBei:
        return const Color(0xFF5E4FA2);
      case QizhengBody.ziQi:
        return const Color(0xFF8A2E63);
    }
  }
}

class _QizhengPaperCard extends StatelessWidget {
  const _QizhengPaperCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF9F0),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: child,
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _MinorTag extends StatelessWidget {
  const _MinorTag({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _bodyAccent(QizhengBody body) {
  switch (body) {
    case QizhengBody.sun:
      return const Color(0xFFB66800);
    case QizhengBody.moon:
      return const Color(0xFF4F6889);
    case QizhengBody.mercury:
      return const Color(0xFF2B7A78);
    case QizhengBody.venus:
      return const Color(0xFF7A3E8E);
    case QizhengBody.mars:
      return const Color(0xFFB63A2B);
    case QizhengBody.jupiter:
      return const Color(0xFF7A5D00);
    case QizhengBody.saturn:
      return const Color(0xFF5D6C70);
    case QizhengBody.luoHou:
      return const Color(0xFF0E566A);
    case QizhengBody.jiDu:
      return const Color(0xFF9F3E2F);
    case QizhengBody.yueBei:
      return const Color(0xFF5E4FA2);
    case QizhengBody.ziQi:
      return const Color(0xFF8A2E63);
  }
}

class _QizhengWheelPainter extends CustomPainter {
  _QizhengWheelPainter({required this.chart});

  final QizhengChart chart;

  static const List<Color> _signColors = [
    Color(0xFFEFD3B0),
    Color(0xFFE4DDB5),
    Color(0xFFD3E1BA),
    Color(0xFFC3E4D6),
    Color(0xFFBEDCED),
    Color(0xFFD2D6EF),
    Color(0xFFE3D1EF),
    Color(0xFFEAC6DD),
    Color(0xFFF0D3C4),
    Color(0xFFE8D9C8),
    Color(0xFFD5E0D7),
    Color(0xFFCEE5E8),
  ];
  static const List<Color> _xiuColors = [
    Color(0xFFF0DCC0),
    Color(0xFFE8E0BF),
    Color(0xFFDCE6C3),
    Color(0xFFD6E5DC),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerRadius = size.shortestSide / 2 - 12;
    final xiuInnerRadius = outerRadius * 0.86;
    final signInnerRadius = outerRadius * 0.72;
    final houseInnerRadius = outerRadius * 0.38;
    final markerRadius = outerRadius * 0.58;
    final ascLongitude = chart.ascendantLongitude;
    final lodgingSegments = QizhengEngine.lodgingSegments();

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF8B7D63)
      ..strokeWidth = 1;

    final outerRingRect = Rect.fromCircle(center: center, radius: outerRadius);
    final xiuInnerRect = Rect.fromCircle(
      center: center,
      radius: xiuInnerRadius,
    );
    final signInnerRect = Rect.fromCircle(
      center: center,
      radius: signInnerRadius,
    );

    for (var index = 0; index < lodgingSegments.length; index++) {
      final segment = lodgingSegments[index];
      final span =
          ((segment.endLongitude - segment.startLongitude) % 360 + 360) % 360;
      final startAngle = _toCanvasRadians(segment.startLongitude, ascLongitude);
      final sweep = -(span == 0 ? 360 : span) * math.pi / 180;
      final path = Path()
        ..moveTo(
          center.dx + outerRadius * math.cos(startAngle),
          center.dy + outerRadius * math.sin(startAngle),
        )
        ..arcTo(outerRingRect, startAngle, sweep, false)
        ..arcTo(xiuInnerRect, startAngle + sweep, -sweep, false)
        ..close();
      fillPaint.color = _xiuColors[index % _xiuColors.length];
      canvas.drawPath(path, fillPaint);
    }

    for (var index = 0; index < 12; index++) {
      final startAngle = _toCanvasRadians(index * 30.0, ascLongitude);
      final sweep = -math.pi / 6;
      final path = Path()
        ..moveTo(
          center.dx + xiuInnerRadius * math.cos(startAngle),
          center.dy + xiuInnerRadius * math.sin(startAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: xiuInnerRadius),
          startAngle,
          sweep,
          false,
        )
        ..arcTo(signInnerRect, startAngle + sweep, -sweep, false)
        ..close();
      fillPaint.color = _signColors[index];
      canvas.drawPath(path, fillPaint);
    }

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = const Color(0xFF6B5F47)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(center, xiuInnerRadius, strokePaint);
    canvas.drawCircle(center, signInnerRadius, strokePaint);
    canvas.drawCircle(
      center,
      markerRadius,
      Paint()
        ..color = const Color(0xFFBDAE8A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawCircle(
      center,
      houseInnerRadius,
      Paint()
        ..color = const Color(0xFFB5C7CC)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      houseInnerRadius,
      Paint()
        ..color = const Color(0xFF47626B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (var index = 0; index < 12; index++) {
      final longitude = index * 30.0;
      final angle = _toCanvasRadians(longitude, ascLongitude);
      final start = Offset(
        center.dx + houseInnerRadius * math.cos(angle),
        center.dy + houseInnerRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = const Color(0xFF6C7E83)
          ..strokeWidth = 1,
      );

      final midAngle = _toCanvasRadians(longitude + 15, ascLongitude);
      _paintText(
        canvas,
        center,
        text: QizhengEngine.traditionalPalaceShortNameAtBranchIndex(
          chart,
          index,
        ),
        radius: (houseInnerRadius + signInnerRadius) / 2,
        angle: midAngle,
        style: const TextStyle(
          color: Color(0xFF3E4D52),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    for (final segment in lodgingSegments) {
      final span =
          ((segment.endLongitude - segment.startLongitude) % 360 + 360) % 360;
      final midLongitude = _normalizeAngle(
        segment.startLongitude + (span == 0 ? 180 : span / 2),
      );
      final angle = _toCanvasRadians(midLongitude, ascLongitude);
      _paintText(
        canvas,
        center,
        text: segment.mansion,
        radius: (xiuInnerRadius + outerRadius) / 2,
        angle: angle,
        style: const TextStyle(
          color: Color(0xFF3F453F),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    for (var index = 0; index < 12; index++) {
      final midLongitude = index * 30 + 15;
      final angle = _toCanvasRadians(midLongitude.toDouble(), ascLongitude);
      _paintText(
        canvas,
        center,
        text: QizhengEngine.branchNameOfLongitude(midLongitude.toDouble()),
        radius: (signInnerRadius + xiuInnerRadius) / 2,
        angle: angle,
        style: const TextStyle(
          color: Color(0xFF28424A),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    _paintAngleMarker(
      canvas,
      center: center,
      radius: outerRadius,
      longitude: QizhengEngine.fateDegreeLongitude(chart),
      ascendantLongitude: ascLongitude,
      label: '命',
      color: const Color(0xFF0E566A),
    );
    _paintAngleMarker(
      canvas,
      center: center,
      radius: outerRadius,
      longitude: chart.positionOf(QizhengBody.moon).longitude,
      ascendantLongitude: ascLongitude,
      label: '身',
      color: const Color(0xFF8A5A0B),
    );

    final markers = _layoutBodyMarkers(
      chart.positions,
      ascLongitude,
      markerRadius,
    );
    for (final marker in markers) {
      final color = _bodyColor(marker.position.body);
      final point = Offset(
        center.dx + marker.radius * math.cos(marker.angle),
        center.dy + marker.radius * math.sin(marker.angle),
      );
      canvas.drawCircle(
        point,
        11,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      _paintCenteredText(
        canvas,
        text: marker.position.body.shortLabel,
        center: point,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    _paintCenteredText(
      canvas,
      text: '七政\n四余',
      center: center,
      style: const TextStyle(
        color: Color(0xFF1E4C59),
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
    );
  }

  List<_WheelBodyMarker> _layoutBodyMarkers(
    List<QizhengPosition> positions,
    double ascLongitude,
    double baseRadius,
  ) {
    final sorted =
        positions
            .map(
              (position) => _WheelBodyMarker(
                position: position,
                angle: _toCanvasRadians(position.longitude, ascLongitude),
                radius: baseRadius,
              ),
            )
            .toList()
          ..sort((left, right) => left.angle.compareTo(right.angle));

    var clusterIndex = 0;
    double? lastAngle;
    for (var index = 0; index < sorted.length; index++) {
      final marker = sorted[index];
      if (lastAngle == null || (marker.angle - lastAngle).abs() > 0.18) {
        clusterIndex = 0;
      } else {
        clusterIndex += 1;
      }
      sorted[index] = marker.copyWith(
        radius: baseRadius - (clusterIndex % 3) * 18,
      );
      lastAngle = marker.angle;
    }
    return sorted;
  }

  void _paintAngleMarker(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double longitude,
    required double ascendantLongitude,
    required String label,
    required Color color,
  }) {
    final angle = _toCanvasRadians(longitude, ascendantLongitude);
    final inner = Offset(
      center.dx + (radius * 0.56) * math.cos(angle),
      center.dy + (radius * 0.56) * math.sin(angle),
    );
    final outer = Offset(
      center.dx + (radius + 6) * math.cos(angle),
      center.dy + (radius + 6) * math.sin(angle),
    );
    canvas.drawLine(
      inner,
      outer,
      Paint()
        ..color = color
        ..strokeWidth = 2,
    );
    _paintText(
      canvas,
      center,
      text: label,
      radius: radius + 18,
      angle: angle,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    );
  }

  void _paintText(
    Canvas canvas,
    Offset center, {
    required String text,
    required double radius,
    required double angle,
    required TextStyle style,
  }) {
    final offset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    _paintCenteredText(canvas, text: text, center: offset, style: style);
  }

  void _paintCenteredText(
    Canvas canvas, {
    required String text,
    required Offset center,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  double _toCanvasRadians(double longitude, double ascendantLongitude) {
    final delta = (longitude - ascendantLongitude) % 360;
    final normalized = delta < 0 ? delta + 360 : delta;
    final screenDegrees = 180 - normalized;
    return screenDegrees * math.pi / 180;
  }

  double _normalizeAngle(double degrees) {
    final normalized = degrees % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  Color _bodyColor(QizhengBody body) {
    return _bodyAccent(body);
  }

  @override
  bool shouldRepaint(covariant _QizhengWheelPainter oldDelegate) {
    return oldDelegate.chart != chart;
  }
}

class _WheelBodyMarker {
  const _WheelBodyMarker({
    required this.position,
    required this.angle,
    required this.radius,
  });

  final QizhengPosition position;
  final double angle;
  final double radius;

  _WheelBodyMarker copyWith({double? radius}) {
    return _WheelBodyMarker(
      position: position,
      angle: angle,
      radius: radius ?? this.radius,
    );
  }
}
