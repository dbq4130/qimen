import 'package:dart_iztro/crape_myrtle/translations/types/mutagen.dart';
import 'package:dart_iztro/dart_iztro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ziwei_engine.dart';
import 'ziwei_models.dart';

class ZiweiPage extends StatefulWidget {
  const ZiweiPage({super.key});

  @override
  State<ZiweiPage> createState() => _ZiweiPageState();
}

class _ZiweiPageState extends State<ZiweiPage> {
  static const double _optionTileExtent = 56;

  late ZiweiBirthInput _input;
  late FunctionalAstrolabe _chart;
  late int _selectedPalaceIndex;
  ZiweiAnalysisMode _analysisMode = ZiweiAnalysisMode.sanhe;

  @override
  void initState() {
    super.initState();
    ZiweiEngine.ensureInitialized();
    _input = ZiweiEngine.defaultInput();
    _chart = ZiweiEngine.buildChart(_input);
    _selectedPalaceIndex = _chart.palace(PalaceName.soulPalace)?.index ?? 0;
  }

  IFunctionalPalace get _selectedPalace => _chart.palace(_selectedPalaceIndex)!;

  void _updateInput(ZiweiBirthInput nextInput) {
    final normalized = ZiweiEngine.normalizeInput(nextInput);
    setState(() {
      _input = normalized;
      _chart = ZiweiEngine.buildChart(normalized);
      _selectedPalaceIndex =
          _chart.palace(_selectedPalaceIndex)?.index ??
          _chart.palace(PalaceName.soulPalace)?.index ??
          0;
    });
  }

  Future<void> _pickYear() async {
    final selected = await _showOptionSheet<int>(
      title: '选择农历年份',
      values: ZiweiEngine.yearOptions(),
      currentValue: _input.lunarYear,
      initialVisibleValue: ZiweiEngine.defaultVisibleYear,
      labelBuilder: (value) => '$value年',
    );
    if (selected == null) {
      return;
    }
    _updateInput(_input.copyWith(lunarYear: selected));
  }

  Future<void> _pickMonth() async {
    final values = List<int>.generate(12, (index) => index + 1);
    final selected = await _showOptionSheet<int>(
      title: '选择农历月份',
      values: values,
      currentValue: _input.lunarMonth,
      labelBuilder: (value) => '$value月',
    );
    if (selected == null) {
      return;
    }
    _updateInput(
      _input.copyWith(
        lunarMonth: selected,
        isLeapMonth: ZiweiEngine.canUseLeapMonth(_input.lunarYear, selected)
            ? _input.isLeapMonth
            : false,
      ),
    );
  }

  Future<void> _pickDay() async {
    final dayCount = ZiweiEngine.daysInMonth(
      lunarYear: _input.lunarYear,
      lunarMonth: _input.lunarMonth,
      isLeapMonth: _input.isLeapMonth,
    );
    final values = List<int>.generate(dayCount, (index) => index + 1);
    final selected = await _showOptionSheet<int>(
      title: '选择农历日期',
      values: values,
      currentValue: _input.lunarDay,
      labelBuilder: (value) => '$value日',
    );
    if (selected == null) {
      return;
    }
    _updateInput(_input.copyWith(lunarDay: selected));
  }

  Future<void> _pickTime() async {
    final selected = await _showOptionSheet<ZiweiTimeOption>(
      title: '选择出生时辰',
      values: ZiweiEngine.timeOptions,
      currentValue: ZiweiEngine.timeOptions.firstWhere(
        (item) => item.index == _input.timeIndex,
      ),
      labelBuilder: (value) => '${value.label}  ${value.range}',
    );
    if (selected == null) {
      return;
    }
    _updateInput(_input.copyWith(timeIndex: selected.index));
  }

  Future<T?> _showOptionSheet<T>({
    required String title,
    required List<T> values,
    required T currentValue,
    required String Function(T value) labelBuilder,
    T? initialVisibleValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final anchorValue = initialVisibleValue ?? currentValue;
        final initialIndex = values.indexOf(anchorValue);
        return SafeArea(
          child: _OptionSheet<T>(
            title: title,
            values: values,
            currentValue: currentValue,
            initialIndex: initialIndex,
            labelBuilder: labelBuilder,
          ),
        );
      },
    );
  }

  String _generateCopyText() {
    final buffer = StringBuffer();
    buffer.writeln('【紫微斗数排盘】');
    buffer.writeln(
      '农历：${_input.isLeapMonth ? '闰' : ''}${_input.lunarYear}年${_input.lunarMonth}月${_input.lunarDay}日 ${ZiweiEngine.timeLabelOf(_input.timeIndex)}',
    );
    buffer.writeln('阳历：${_chart.solarDate}');
    buffer.writeln('性别：${_input.gender.label}');
    buffer.writeln('阴历：${_chart.lunarDate}');
    buffer.writeln('干支：${_chart.chineseDate}');
    buffer.writeln('命主：${_chart.soul.title} 身主：${_chart.body.title}');
    buffer.writeln('五行局：${_chart.fiveElementClass.title}');
    buffer.writeln();
    for (final palace in _chart.palaces) {
      final mutagenStars = ZiweiEngine.mutagenStars(palace);
      buffer.writeln(
        '${palace.name.title} ${ZiweiEngine.decadalRangeText(palace)}岁 ${ZiweiEngine.stemBranchOf(palace)} ${ZiweiEngine.majorStarsText(palace)}',
      );
      buffer.writeln('辅杂：${ZiweiEngine.supportStarsText(palace)}');
      buffer.writeln('神煞：${ZiweiEngine.palaceShenshaText(palace)}');
      if (mutagenStars.isNotEmpty) {
        buffer.writeln(
          '四化：${mutagenStars.map((star) => '${star.name.title}${_mutagenLabel(star.mutagen)}').join('、')}',
        );
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateCopyText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('紫微斗数排盘信息已复制'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('紫微斗数排盘器'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4C306A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _copyToClipboard,
            tooltip: '复制排盘信息',
            icon: const Icon(Icons.copy_all_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ColoredBox(
          color: const Color(0xFFF3EEE4),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildControlCard(theme),
                const SizedBox(height: 8),
                _buildBoardCard(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlCard(ThemeData theme) {
    final leapMonth = ZiweiEngine.leapMonthOfYear(_input.lunarYear);
    final leapAvailable = ZiweiEngine.canUseLeapMonth(
      _input.lunarYear,
      _input.lunarMonth,
    );
    final leapDescription = leapMonth == 0
        ? '本年无闰月'
        : leapAvailable
        ? '本年闰${leapMonth}月，可切换闰月排盘'
        : '本年闰${leapMonth}月，当前月份不可设为闰月';

    return _ZiweiPaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '排盘参数',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF552C78),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ZiweiActionChip(
                icon: Icons.calendar_month_rounded,
                label: '年 ${_input.lunarYear}',
                onTap: _pickYear,
              ),
              _ZiweiActionChip(
                icon: Icons.calendar_view_month_rounded,
                label: '月 ${_input.isLeapMonth ? '闰' : ''}${_input.lunarMonth}',
                onTap: _pickMonth,
              ),
              _ZiweiActionChip(
                icon: Icons.event_note_rounded,
                label: '日 ${_input.lunarDay}',
                onTap: _pickDay,
              ),
              _ZiweiActionChip(
                icon: Icons.schedule_rounded,
                label: ZiweiEngine.timeLabelOf(_input.timeIndex),
                onTap: _pickTime,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '性别',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF684084),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ZiweiGender.values
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: _input.gender == item,
                      onSelected: (_) {
                        _updateInput(_input.copyWith(gender: item));
                      },
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4E7FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1A8EF)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '闰月',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B2F7B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leapDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A5A93),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: leapAvailable && _input.isLeapMonth,
                  onChanged: leapAvailable
                      ? (value) {
                          _updateInput(_input.copyWith(isLeapMonth: value));
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _updateInput(_input),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('排紫微盘'),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardCard(ThemeData theme) {
    final selectedPalace = _selectedPalace;
    final surroundedIndexes = _analysisMode == ZiweiAnalysisMode.sanhe
        ? ZiweiEngine.surroundedIndexes(_chart, selectedPalace.index).toSet()
        : <int>{};
    final flyLabels = _analysisMode == ZiweiAnalysisMode.feixing
        ? ZiweiEngine.flyTargetLabels(selectedPalace)
        : <int, List<String>>{};
    final globalMutagens = _analysisMode == ZiweiAnalysisMode.sihua
        ? _chart.palaces.fold<Map<int, List<String>>>({}, (result, palace) {
            final labels = ZiweiEngine.mutagenStars(
              palace,
            ).map((star) => _mutagenLabel(star.mutagen)).toList();
            if (labels.isNotEmpty) {
              result[palace.index] = labels;
            }
            return result;
          })
        : <int, List<String>>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '紫微命盘',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF552C78),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SegmentedButton<ZiweiAnalysisMode>(
            segments: ZiweiAnalysisMode.values
                .map(
                  (mode) => ButtonSegment<ZiweiAnalysisMode>(
                    value: mode,
                    label: Text(mode.label),
                  ),
                )
                .toList(growable: false),
            selected: {_analysisMode},
            onSelectionChanged: (selection) {
              setState(() {
                _analysisMode = selection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final cellHeight = compact ? 186.0 : 212.0;
            final cellGap = compact ? 1.5 : 2.0;
            return Container(
              padding: EdgeInsets.all(compact ? 1.5 : 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE6DED0),
                border: Border.all(color: const Color(0xFFB4AA9D), width: 0.9),
              ),
              child: Column(
                children: [
                  _buildHorizontalPalaceRow(
                    indices: const [3, 4, 5, 6],
                    cellHeight: cellHeight,
                    gap: cellGap,
                    surroundedIndexes: surroundedIndexes,
                    flyLabels: flyLabels,
                    mutagenLabels: globalMutagens,
                  ),
                  SizedBox(height: cellGap),
                  SizedBox(
                    height: cellHeight * 2 + cellGap,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildVerticalPalaceColumn(
                            indices: const [2, 1],
                            cellHeight: cellHeight,
                            gap: cellGap,
                            surroundedIndexes: surroundedIndexes,
                            flyLabels: flyLabels,
                            mutagenLabels: globalMutagens,
                          ),
                        ),
                        SizedBox(width: cellGap),
                        Expanded(flex: 2, child: _buildCenterCard(theme)),
                        SizedBox(width: cellGap),
                        Expanded(
                          child: _buildVerticalPalaceColumn(
                            indices: const [7, 8],
                            cellHeight: cellHeight,
                            gap: cellGap,
                            surroundedIndexes: surroundedIndexes,
                            flyLabels: flyLabels,
                            mutagenLabels: globalMutagens,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: cellGap),
                  _buildHorizontalPalaceRow(
                    indices: const [0, 11, 10, 9],
                    cellHeight: cellHeight,
                    gap: cellGap,
                    surroundedIndexes: surroundedIndexes,
                    flyLabels: flyLabels,
                    mutagenLabels: globalMutagens,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalPalaceRow({
    required List<int> indices,
    required double cellHeight,
    required double gap,
    required Set<int> surroundedIndexes,
    required Map<int, List<String>> flyLabels,
    required Map<int, List<String>> mutagenLabels,
  }) {
    return Row(
      children: indices
          .map(
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == indices.last ? 0 : gap,
                ),
                child: SizedBox(
                  height: cellHeight,
                  child: _buildPalaceCell(
                    _chart.palace(index)!,
                    surroundedIndexes: surroundedIndexes,
                    flyLabels: flyLabels[index] ?? const [],
                    mutagenLabels: mutagenLabels[index] ?? const [],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildVerticalPalaceColumn({
    required List<int> indices,
    required double cellHeight,
    required double gap,
    required Set<int> surroundedIndexes,
    required Map<int, List<String>> flyLabels,
    required Map<int, List<String>> mutagenLabels,
  }) {
    return Column(
      children: indices
          .map(
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == indices.last ? 0 : gap),
              child: SizedBox(
                height: cellHeight,
                child: _buildPalaceCell(
                  _chart.palace(index)!,
                  surroundedIndexes: surroundedIndexes,
                  flyLabels: flyLabels[index] ?? const [],
                  mutagenLabels: mutagenLabels[index] ?? const [],
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildCenterCard(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFC),
        border: Border.all(color: const Color(0xFFB7AFA3), width: 0.9),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 150;

          Widget fitLine(
            String text, {
            required TextStyle? style,
            double height = 0,
          }) {
            return Padding(
              padding: EdgeInsets.only(bottom: height),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: style,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  fitLine(
                    '本命盘 · ${_analysisMode.label}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF7B4C98),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                    height: narrow ? 8 : 12,
                  ),
                  fitLine(
                    narrow ? '紫微' : '紫微斗数',
                    style:
                        (narrow
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineSmall)
                            ?.copyWith(
                              color: const Color(0xFF392A25),
                              fontWeight: FontWeight.w800,
                            ),
                    height: narrow ? 8 : 10,
                  ),
                  fitLine(
                    '${_input.gender.label} ${_chart.fiveElementClass.title}',
                    style:
                        (narrow
                                ? theme.textTheme.titleMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(
                              color: const Color(0xFF2E2622),
                              fontWeight: FontWeight.w700,
                            ),
                    height: 4,
                  ),
                  fitLine(
                    '命主 ${_chart.soul.title}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4C4039),
                      fontWeight: FontWeight.w600,
                    ),
                    height: 2,
                  ),
                  fitLine(
                    '身主 ${_chart.body.title}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4C4039),
                      fontWeight: FontWeight.w600,
                    ),
                    height: 4,
                  ),
                  fitLine(
                    narrow
                        ? '命宫 ${_chart.earthlyBranchOfSoulPalace.title}'
                        : '命宫 ${_chart.earthlyBranchOfSoulPalace.title}  身宫 ${_chart.earthlyBranchOfBodyPalace.title}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5C524B),
                      fontWeight: FontWeight.w600,
                    ),
                    height: narrow ? 2 : 6,
                  ),
                  if (narrow)
                    fitLine(
                      '身宫 ${_chart.earthlyBranchOfBodyPalace.title}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5C524B),
                        fontWeight: FontWeight.w600,
                      ),
                      height: 6,
                    ),
                  fitLine(
                    _selectedPalace.name.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6C5B53),
                      fontWeight: FontWeight.w700,
                    ),
                    height: 4,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPalaceCell(
    IFunctionalPalace palace, {
    required Set<int> surroundedIndexes,
    required List<String> flyLabels,
    required List<String> mutagenLabels,
  }) {
    final selected = palace.index == _selectedPalaceIndex;
    final linkedInSanhe = surroundedIndexes.contains(palace.index) && !selected;
    final accentColor = selected
        ? const Color(0xFF8A5A2B)
        : linkedInSanhe
        ? const Color(0xFF4971A7)
        : const Color(0xFFBFB6AA);
    final analysisText = flyLabels.isNotEmpty
        ? '飞 ${flyLabels.join(' ')}'
        : mutagenLabels.isNotEmpty
        ? mutagenLabels.join(' ')
        : '';
    final analysisColor = flyLabels.isNotEmpty
        ? const Color(0xFF2A9E95)
        : const Color(0xFFB14646);

    return _ZiweiPalaceCell(
      palaceName: palace.name.title,
      stem: palace.heavenlySten.title,
      branch: palace.earthlyBranch.title,
      decadalRange: ZiweiEngine.decadalRangeText(palace),
      longLifeText: palace.changShen12.title,
      majorStars: ZiweiEngine.inlineMajorStarsText(palace),
      majorBrightness: ZiweiEngine.inlineMajorBrightnessText(palace),
      supportStars: ZiweiEngine.inlineSupportStarsText(palace),
      shenshaText: ZiweiEngine.inlineShenshaText(palace),
      analysisText: analysisText,
      analysisColor: analysisColor,
      isSelected: selected,
      isSanheLinked: linkedInSanhe,
      isBodyPalace: palace.isBodyPalace,
      isOriginalPalace: palace.isOriginalPalace,
      accentColor: accentColor,
      onTap: () {
        setState(() {
          _selectedPalaceIndex = palace.index;
        });
      },
    );
  }

  String _mutagenLabel(Mutagen? mutagen) {
    switch (mutagen) {
      case Mutagen.siHuaLu:
        return '化禄';
      case Mutagen.siHuaQuan:
        return '化权';
      case Mutagen.siHuaKe:
        return '化科';
      case Mutagen.siHuaJi:
        return '化忌';
      case null:
        return '';
    }
  }
}

class _OptionSheet<T> extends StatefulWidget {
  const _OptionSheet({
    required this.title,
    required this.values,
    required this.currentValue,
    required this.initialIndex,
    required this.labelBuilder,
  });

  final String title;
  final List<T> values;
  final T currentValue;
  final int initialIndex;
  final String Function(T value) labelBuilder;

  @override
  State<_OptionSheet<T>> createState() => _OptionSheetState<T>();
}

class _OptionSheetState<T> extends State<_OptionSheet<T>> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialIndex < 0 ? 0 : widget.initialIndex;
    _controller = ScrollController(
      initialScrollOffset: safeIndex * _ZiweiPageState._optionTileExtent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4F2D6B),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemExtent: _ZiweiPageState._optionTileExtent,
            itemCount: widget.values.length,
            itemBuilder: (context, index) {
              final value = widget.values[index];
              final selected = value == widget.currentValue;
              return ListTile(
                title: Text(widget.labelBuilder(value)),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: Color(0xFF8A42B6))
                    : null,
                onTap: () => Navigator.of(context).pop(value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ZiweiPalaceCell extends StatelessWidget {
  const _ZiweiPalaceCell({
    required this.palaceName,
    required this.stem,
    required this.branch,
    required this.decadalRange,
    required this.longLifeText,
    required this.majorStars,
    required this.majorBrightness,
    required this.supportStars,
    required this.shenshaText,
    required this.analysisText,
    required this.analysisColor,
    required this.isSelected,
    required this.isSanheLinked,
    required this.isBodyPalace,
    required this.isOriginalPalace,
    required this.accentColor,
    required this.onTap,
  });

  final String palaceName;
  final String stem;
  final String branch;
  final String decadalRange;
  final String longLifeText;
  final String majorStars;
  final String majorBrightness;
  final String supportStars;
  final String shenshaText;
  final String analysisText;
  final Color analysisColor;
  final bool isSelected;
  final bool isSanheLinked;
  final bool isBodyPalace;
  final bool isOriginalPalace;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(2),
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 190;
            final majorFontSize = compact ? 9.6 : 10.8;
            final bodyFontSize = compact ? 7.9 : 8.8;
            final tinyFontSize = compact ? 6.9 : 7.6;
            final branchFontSize = compact ? 11.8 : 13.2;
            final edgeWidth = compact ? 40.0 : 46.0;
            final markerText = [
              palaceName,
              if (isBodyPalace) '身',
              if (isOriginalPalace) '来',
            ].join(' ');

            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.fromLTRB(
                compact ? 4 : 6,
                compact ? 4 : 5,
                compact ? 4 : 5,
                compact ? 3 : 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFF7EA)
                    : isSanheLinked
                    ? const Color(0xFFF5F8FD)
                    : const Color(0xFFFFFDFC),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: accentColor,
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    markerText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: tinyFontSize + 0.1,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B6158),
                    ),
                  ),
                  SizedBox(height: compact ? 3 : 4),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRect(
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (analysisText.isNotEmpty) ...[
                                    Text(
                                      analysisText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: tinyFontSize,
                                        color: analysisColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: compact ? 2 : 3),
                                  _PalaceStarWrap(
                                    labels: majorStars.split(' '),
                                    brightnessLabels: majorBrightness.split(
                                      ' ',
                                    ),
                                    mode: _PalaceTokenMode.major,
                                    fontSize: majorFontSize,
                                    tinyFontSize: tinyFontSize,
                                    maxRows: compact ? 2 : 3,
                                  ),
                                  SizedBox(height: compact ? 2 : 3),
                                  _PalaceStarWrap(
                                    labels: supportStars.split(' '),
                                    mode: _PalaceTokenMode.support,
                                    fontSize: bodyFontSize,
                                    tinyFontSize: tinyFontSize,
                                    maxRows: compact ? 5 : 6,
                                  ),
                                  if (shenshaText.isNotEmpty) ...[
                                    SizedBox(height: compact ? 1.5 : 2),
                                    _PalaceStarWrap(
                                      labels: shenshaText.split(' '),
                                      mode: _PalaceTokenMode.shensha,
                                      fontSize: bodyFontSize - 0.3,
                                      tinyFontSize: tinyFontSize,
                                      maxRows: compact ? 3 : 4,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: compact ? 4 : 6),
                        SizedBox(
                          width: edgeWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  decadalRange,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: tinyFontSize + 0.15,
                                    color: const Color(0xFF2E2622),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: compact ? 1.5 : 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  longLifeText,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: tinyFontSize + 0.1,
                                    color: const Color(0xFF5E5852),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: compact ? 2 : 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$stem$branch',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: branchFontSize,
                                    color: const Color(0xFF1F1B18),
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _PalaceTokenMode { major, support, shensha }

class _PalaceStarWrap extends StatelessWidget {
  const _PalaceStarWrap({
    required this.labels,
    required this.mode,
    required this.fontSize,
    required this.tinyFontSize,
    required this.maxRows,
    this.brightnessLabels = const [],
  });

  final Iterable<String> labels;
  final Iterable<String> brightnessLabels;
  final _PalaceTokenMode mode;
  final double fontSize;
  final double tinyFontSize;
  final int maxRows;

  @override
  Widget build(BuildContext context) {
    final items = labels
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final brightItems = brightnessLabels
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final tokenWidgets = <Widget>[];
    for (var index = 0; index < items.length; index++) {
      final label = items[index];
      final brightness = index < brightItems.length ? brightItems[index] : '';
      tokenWidgets.add(
        _PalaceStarToken(
          label: label,
          brightness: brightness,
          mode: mode,
          fontSize: fontSize,
          tinyFontSize: tinyFontSize,
        ),
      );
    }

    return ClipRect(
      child: SizedBox(
        height: _estimatedHeight(),
        child: Wrap(spacing: 1, runSpacing: 0.5, children: tokenWidgets),
      ),
    );
  }

  double _estimatedHeight() {
    final lineHeight = mode == _PalaceTokenMode.major
        ? fontSize + tinyFontSize + 6
        : fontSize + 5;
    return (lineHeight * maxRows).toDouble();
  }
}

class _PalaceStarToken extends StatelessWidget {
  const _PalaceStarToken({
    required this.label,
    required this.brightness,
    required this.mode,
    required this.fontSize,
    required this.tinyFontSize,
  });

  final String label;
  final String brightness;
  final _PalaceTokenMode mode;
  final double fontSize;
  final double tinyFontSize;

  @override
  Widget build(BuildContext context) {
    final color = _tokenColor(label, mode);
    final weight = mode == _PalaceTokenMode.major
        ? FontWeight.w700
        : FontWeight.w600;

    if (mode == _PalaceTokenMode.major) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              height: 1,
              fontSize: fontSize,
              color: color,
              fontWeight: weight,
            ),
          ),
          if (brightness.isNotEmpty)
            Text(
              brightness,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                height: 1,
                fontSize: tinyFontSize,
                color: const Color(0xFF5E5852),
              ),
            ),
        ],
      );
    }

    return Text(
      label,
      maxLines: 1,
      softWrap: false,
      style: TextStyle(
        height: 1,
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
      ),
    );
  }
}

Color _tokenColor(String label, _PalaceTokenMode mode) {
  if (mode == _PalaceTokenMode.shensha) {
    if (_tealTokens.contains(label)) {
      return const Color(0xFF2C8E85);
    }
    if (_warmTokens.contains(label)) {
      return const Color(0xFF8A2C2A);
    }
    return const Color(0xFF4F6F7F);
  }

  if (_purpleTokens.contains(label)) {
    return const Color(0xFF7A2DA6);
  }
  if (_warmTokens.contains(label)) {
    return const Color(0xFF8A2C2A);
  }
  if (_tealTokens.contains(label)) {
    return const Color(0xFF2C8E85);
  }
  if (_blueTokens.contains(label)) {
    return const Color(0xFF235E8A);
  }

  return mode == _PalaceTokenMode.major
      ? const Color(0xFF8A2C2A)
      : const Color(0xFF235E8A);
}

const Set<String> _purpleTokens = {
  '紫微',
  '天府',
  '天相',
  '天梁',
  '左辅',
  '右弼',
  '文昌',
  '文曲',
};

const Set<String> _warmTokens = {
  '太阳',
  '武曲',
  '廉贞',
  '贪狼',
  '七杀',
  '破军',
  '禄存',
  '擎羊',
  '陀罗',
  '火星',
  '铃星',
  '化禄',
  '化权',
  '化科',
  '化忌',
};

const Set<String> _tealTokens = {
  '天同',
  '天机',
  '太阴',
  '天马',
  '龙池',
  '凤阁',
  '解神',
  '天喜',
  '天福',
  '喜神',
  '病符',
  '大耗',
  '小耗',
  '青龙',
  '力士',
  '奏书',
  '伏兵',
  '博士',
};

const Set<String> _blueTokens = {
  '巨门',
  '地空',
  '地劫',
  '天姚',
  '天哭',
  '天虚',
  '天刑',
  '天空',
  '截空',
  '旬空',
  '天巫',
  '阴煞',
  '孤辰',
  '寡宿',
  '八座',
  '三台',
  '恩光',
  '天贵',
  '天官',
  '天厨',
  '天月',
  '红鸾',
  '咸池',
};

class _ZiweiPaperCard extends StatelessWidget {
  const _ZiweiPaperCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8C8E4), width: 0.8),
      ),
      child: child,
    );
  }
}

class _ZiweiActionChip extends StatelessWidget {
  const _ZiweiActionChip({
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
