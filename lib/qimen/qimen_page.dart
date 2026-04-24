import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../qizheng/qizheng_page.dart';
import '../ziwei/ziwei_page.dart';
import 'qimen_engine.dart';
import 'qimen_models.dart';

class QimenPage extends StatefulWidget {
  const QimenPage({super.key});

  @override
  State<QimenPage> createState() => _QimenPageState();
}

class _QimenPageState extends State<QimenPage> {
  static const int _minSupportedYear = 1980;
  static const int _maxSupportedYear = 2100;
  static const double _optionTileExtent = 56;

  DateTime _selectedDateTime = DateTime.now();
  bool _useAutoDunType = true;
  bool _useAutoBureau = true;
  QimenDunType _manualDunType = QimenDunType.yang;
  QimenPanMode _panMode = QimenPanMode.zhuan;
  int _manualBureau = 1;
  late QimenPan _pan;

  @override
  void initState() {
    super.initState();
    _pan = _buildPan();
  }

  QimenPan _buildPan() {
    print('>>> _buildPan called with: $_selectedDateTime');
    return QimenEngine.generate(
      dateTime: _selectedDateTime,
      manualDunType: _manualDunType,
      useAutoDunType: _useAutoDunType,
      panMode: _panMode,
      setupMethod: QimenSetupMethod.chaibu,
      manualBureau: _manualBureau,
      useAutoBureau: _useAutoBureau,
    );
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  DateTime _normalizedDateTime({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
  }) {
    final nextYear = year ?? _selectedDateTime.year;
    final nextMonth = month ?? _selectedDateTime.month;
    final maxDay = _daysInMonth(nextYear, nextMonth);
    final requestedDay = day ?? _selectedDateTime.day;
    final nextDay = requestedDay > maxDay ? maxDay : requestedDay;

    return DateTime(
      nextYear,
      nextMonth,
      nextDay,
      hour ?? _selectedDateTime.hour,
      minute ?? _selectedDateTime.minute,
    );
  }

  void _updateSelectedDateTime(
    DateTime nextDateTime, {
    required String reason,
  }) {
    print('$reason更新: $nextDateTime');
    setState(() {
      _selectedDateTime = nextDateTime;
      _pan = _buildPan();
      print(
        '$reason更新后盘: ${_pan.generatedAt}, 四柱: ${_pan.yearGanzhi} ${_pan.monthGanzhi} ${_pan.dayGanzhi} ${_pan.hourGanzhi}',
      );
    });
  }

  Future<void> _pickYear() async {
    final values = List<int>.generate(
      _maxSupportedYear - _minSupportedYear + 1,
      (index) => _minSupportedYear + index,
    );
    final selected = await _showOptionSheet<int>(
      title: '选择年份',
      values: values,
      currentValue: _selectedDateTime.year,
      labelBuilder: (value) => '$value年',
    );
    if (selected == null) {
      return;
    }

    _updateSelectedDateTime(_normalizedDateTime(year: selected), reason: '年份');
  }

  Future<void> _pickMonth() async {
    final values = List<int>.generate(12, (index) => index + 1);
    final selected = await _showOptionSheet<int>(
      title: '选择月份',
      values: values,
      currentValue: _selectedDateTime.month,
      labelBuilder: (value) => '$value月',
    );
    if (selected == null) {
      return;
    }

    _updateSelectedDateTime(_normalizedDateTime(month: selected), reason: '月份');
  }

  Future<void> _pickDay() async {
    final dayCount = _daysInMonth(
      _selectedDateTime.year,
      _selectedDateTime.month,
    );
    final values = List<int>.generate(dayCount, (index) => index + 1);
    final selected = await _showOptionSheet<int>(
      title: '选择日期',
      values: values,
      currentValue: _selectedDateTime.day,
      labelBuilder: (value) => '$value日',
    );
    if (selected == null) {
      return;
    }

    _updateSelectedDateTime(_normalizedDateTime(day: selected), reason: '日期');
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked == null) {
      return;
    }

    _updateSelectedDateTime(
      _normalizedDateTime(hour: picked.hour, minute: picked.minute),
      reason: '时间',
    );
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

  void _recalculate() {
    print('重新排盘: $_selectedDateTime');
    setState(() {
      _pan = _buildPan();
      print(
        '新盘生成: ${_pan.generatedAt}, 四柱: ${_pan.yearGanzhi} ${_pan.monthGanzhi} ${_pan.dayGanzhi} ${_pan.hourGanzhi}',
      );
    });
  }

  String _generateCopyText() {
    final buffer = StringBuffer();
    // 基本信息
    buffer.writeln('【奇门遁甲排盘】');
    buffer.writeln('时间：${QimenEngine.formatDateTime(_pan.generatedAt)}');
    buffer.writeln(
      '四柱：${_pan.yearGanzhi} ${_pan.monthGanzhi} ${_pan.dayGanzhi} ${_pan.hourGanzhi}',
    );
    buffer.writeln('${_pan.yuan} ${_pan.dunType.label}${_pan.bureau}局');
    buffer.writeln('旬首：${_pan.xunShou}${_pan.xunYi} 空亡：${_pan.kongWang}');
    buffer.writeln(
      '值符：${_pan.valueStar} 值使：${_pan.valueGate} 马星：${_pan.horseStar}',
    );
    buffer.writeln();
    // 九宫信息
    for (final cell in _pan.cells) {
      if (cell.isCenter) {
        buffer.writeln('中宫 天盘${cell.heavenStem}');
      } else {
        final starText = cell.hasTianQinStar
            ? '${cell.tianQinStem}${cell.star}禽'
            : cell.star;
        final heavenText = cell.hasTianQinStar
            ? '${cell.tianQinStem}${cell.heavenStem}'
            : cell.heavenStem;
        final earthText = cell.hasTianQinStem
            ? '${cell.tianQinStem}${cell.earthStem}'
            : cell.earthStem;
        final kongWangText = cell.isKongWang ? ' 空亡' : '';
        final horseText = cell.isHorseStar ? ' 马星' : '';
        buffer.writeln(
          '${cell.palaceName} ${cell.deity} $starText ${cell.gate} 天盘$heavenText 地盘$earthText$kongWangText$horseText',
        );
      }
    }
    return buffer.toString();
  }

  void _copyToClipboard() {
    final text = _generateCopyText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('排盘信息已复制'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('奇门遁甲排盘器'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3C2A18),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const QizhengPage()),
              );
            },
            icon: const Icon(Icons.public_rounded, color: Color(0xFFBEE7F4)),
            tooltip: '打开七政四余',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ZiweiPage()),
              );
            },
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFE8C2FF)),
            tooltip: '打开紫微斗数',
          ),
          IconButton(
            onPressed: _copyToClipboard,
            icon: const Icon(Icons.copy),
            tooltip: '复制排盘信息',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5E8CB), Color(0xFFEBD8B2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildControlCard(theme),
                const SizedBox(height: 16),
                _buildSummaryCard(theme),
                const SizedBox(height: 16),
                _buildCompassHint(theme),
                const SizedBox(height: 12),
                _buildPanGrid(theme),
                const SizedBox(height: 16),
                _buildNoteCard(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlCard(ThemeData theme) {
    return _PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '起局参数',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF51351C),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionChipButton(
                key: const ValueKey('qimen_year_button'),
                label: '年 ${_selectedDateTime.year}',
                onTap: _pickYear,
                icon: Icons.calendar_month_outlined,
              ),
              _ActionChipButton(
                key: const ValueKey('qimen_month_button'),
                label:
                    '月 ${_selectedDateTime.month.toString().padLeft(2, '0')}',
                onTap: _pickMonth,
                icon: Icons.calendar_view_month_outlined,
              ),
              _ActionChipButton(
                key: const ValueKey('qimen_day_button'),
                label: '日 ${_selectedDateTime.day.toString().padLeft(2, '0')}',
                onTap: _pickDay,
                icon: Icons.event_outlined,
              ),
              _ActionChipButton(
                key: const ValueKey('qimen_time_button'),
                label:
                    '时间 ${QimenEngine.formatDateTime(_selectedDateTime).split(' ').last}',
                onTap: _pickTime,
                icon: Icons.schedule_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '遁法',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A4522),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2E1B9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD2A76B)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '按节气自动判断阴遁 / 阳遁',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B381A),
                    ),
                  ),
                ),
                Switch(
                  value: _useAutoDunType,
                  onChanged: (value) {
                    setState(() {
                      _useAutoDunType = value;
                      _pan = _buildPan();
                    });
                  },
                ),
              ],
            ),
          ),
          if (!_useAutoDunType) ...[
            const SizedBox(height: 10),
            Row(
              children: QimenDunType.values
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(item.label),
                        selected: _manualDunType == item,
                        onSelected: (_) {
                          setState(() {
                            _manualDunType = item;
                            _pan = _buildPan();
                          });
                        },
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '排盘方式',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A4522),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: QimenPanMode.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.label),
                    selected: _panMode == item,
                    onSelected: (_) {
                      setState(() {
                        _panMode = item;
                        _pan = _buildPan();
                      });
                    },
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _recalculate,
            icon: const Icon(Icons.auto_fix_high_outlined),
            label: const Text('重新排盘'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    return _PaperCard(
      key: ValueKey(_pan.generatedAt),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '盘面概览',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF51351C),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryBadge(
                title: '时间',
                value: QimenEngine.formatDateTime(_pan.generatedAt),
              ),
              _SummaryBadge(title: '节气', value: _pan.solarTerm),
              _SummaryBadge(title: '三元', value: _pan.yuan),
              _SummaryBadge(
                title: '局数',
                value: '${_pan.dunType.label}${_pan.bureau}局',
              ),
              _SummaryBadge(title: '年柱', value: _pan.yearGanzhi),
              _SummaryBadge(title: '月柱', value: _pan.monthGanzhi),
              _SummaryBadge(title: '日柱', value: _pan.dayGanzhi),
              _SummaryBadge(title: '时柱', value: _pan.hourGanzhi),
              _SummaryBadge(title: '时辰', value: _pan.hourLabel),
              _SummaryBadge(title: '旬首', value: '${_pan.xunShou}${_pan.xunYi}'),
              _SummaryBadge(title: '空亡', value: _pan.kongWang),
              _SummaryBadge(title: '值符', value: _pan.valueStar),
              _SummaryBadge(title: '值使', value: _pan.valueGate),
              _SummaryBadge(title: '马星', value: _pan.horseStar),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassHint(ThemeData theme) {
    return Column(
      children: [
        Text(
          '南',
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF7C4A1D),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '东',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7C4A1D),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '西',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF7C4A1D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPanGrid(ThemeData theme) {
    final rows = <TableRow>[];
    final key = ValueKey('pan_${_pan.generatedAt.millisecondsSinceEpoch}');
    for (var row = 0; row < 3; row++) {
      final children = <Widget>[];
      for (var column = 0; column < 3; column++) {
        final cell = _pan.cells[row * 3 + column];
        children.add(
          _PanCellWidget(
            key: ValueKey(
              'cell_${cell.palaceNumber}_${_pan.generatedAt.millisecondsSinceEpoch}',
            ),
            cell: cell,
          ),
        );
      }
      rows.add(TableRow(children: children));
    }

    return Table(
      key: key,
      border: TableBorder.all(
        color: const Color(0xFF7E5730),
        width: 1.2,
        borderRadius: BorderRadius.circular(16),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  Widget _buildNoteCard(ThemeData theme) {
    return _PaperCard(
      child: Text(
        _pan.note,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
          color: const Color(0xFF6C4A28),
        ),
      ),
    );
  }
}

class _PanCellWidget extends StatelessWidget {
  const _PanCellWidget({super.key, required this.cell});

  final QimenPanCell cell;

  @override
  Widget build(BuildContext context) {
    final accent = cell.isCenter
        ? const Color(0xFFD3A85F)
        : const Color(0xFFE7D0A2);

    return Container(
      constraints: const BoxConstraints(minHeight: 176),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.45)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${cell.palaceName} · ${cell.palaceNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF523015),
                ),
              ),
              if (cell.isKongWang) ...[
                const SizedBox(width: 4),
                const _MarkerBadge(
                  text: '空',
                  borderColor: Color(0xFFD4483B),
                  textColor: Color(0xFFD4483B),
                ),
              ],
              if (cell.isHorseStar) ...[
                const SizedBox(width: 4),
                const _MarkerBadge(
                  text: '马',
                  borderColor: Color(0xFF18A999),
                  textColor: Color(0xFF18A999),
                ),
              ],
            ],
          ),
          // 中宫只显示天干，不显示神星门
          if (cell.isCenter) ...[
            const SizedBox(height: 40),
            Center(
              child: Text(
                cell.heavenStem,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5E2B16),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            if (cell.deity.isNotEmpty)
              _InlineTag(
                label: cell.deity,
                backgroundColor: const Color(0xFF3C2A18),
              ),
            const SizedBox(height: 8),
            Text(
              cell.hasTianQinStar
                  ? '${cell.tianQinStem}${cell.star}禽'
                  : cell.star,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5E2B16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cell.gate,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7B401C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              cell.hasTianQinStar
                  ? '天盘 ${cell.tianQinStem}${cell.heavenStem}'
                  : '天盘 ${cell.heavenStem}',
              style: const TextStyle(color: Color(0xFF5E412B)),
            ),
            Text(
              cell.hasTianQinStem
                  ? '地盘 ${cell.tianQinStem}${cell.earthStem}'
                  : '地盘 ${cell.earthStem}',
              style: const TextStyle(color: Color(0xFF5E412B)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFB68A52), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 94),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E1B9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD2A76B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A5A33),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4E3016),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerBadge extends StatelessWidget {
  const _MarkerBadge({
    required this.text,
    required this.borderColor,
    required this.textColor,
  });

  final String text;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        child: Text(text, style: TextStyle(fontSize: 8, color: textColor)),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
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
      initialScrollOffset: safeIndex * _QimenPageState._optionTileExtent,
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
              color: const Color(0xFF51351C),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemExtent: _QimenPageState._optionTileExtent,
            itemCount: widget.values.length,
            itemBuilder: (context, index) {
              final value = widget.values[index];
              final selected = value == widget.currentValue;
              return ListTile(
                title: Text(widget.labelBuilder(value)),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: Color(0xFF8A5A2B))
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

class _InlineTag extends StatelessWidget {
  const _InlineTag({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
