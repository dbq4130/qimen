import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'qimen_engine.dart';
import 'qimen_models.dart';

class QimenPage extends StatefulWidget {
  const QimenPage({super.key});

  @override
  State<QimenPage> createState() => _QimenPageState();
}

class _QimenPageState extends State<QimenPage> {
  DateTime _selectedDateTime = DateTime.now();
  bool _useAutoDunType = true;
  bool _useAutoBureau = true;
  QimenDunType _manualDunType = QimenDunType.yang;
  QimenPanMode _panMode = QimenPanMode.zhuan;
  QimenSetupMethod _setupMethod = QimenSetupMethod.chaibu;
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
      setupMethod: _setupMethod,
      manualBureau: _manualBureau,
      useAutoBureau: _useAutoBureau,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }

    print('选择日期: ${picked.year}-${picked.month}-${picked.day}');
    setState(() {
      _selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
      _pan = _buildPan();
      print('日期更新后盘: ${_pan.generatedAt}, 四柱: ${_pan.yearGanzhi} ${_pan.monthGanzhi} ${_pan.dayGanzhi} ${_pan.hourGanzhi}');
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        picked.hour,
        picked.minute,
      );
      _pan = _buildPan();
    });
  }

  void _recalculate() {
    print('重新排盘: $_selectedDateTime');
    setState(() {
      _pan = _buildPan();
      print('新盘生成: ${_pan.generatedAt}, 四柱: ${_pan.yearGanzhi} ${_pan.monthGanzhi} ${_pan.dayGanzhi} ${_pan.hourGanzhi}');
    });
  }

  String _generateCopyText() {
    final buffer = StringBuffer();
    // 基本信息
    buffer.writeln('【奇门遁甲排盘】');
    buffer.writeln('时间：${QimenEngine.formatDateTime(_pan.generatedAt)}');
    buffer.writeln('四柱：${_pan.yearGanzhi} ${_pan.monthGanzhi} ${_pan.dayGanzhi} ${_pan.hourGanzhi}');
    buffer.writeln('${_pan.yuan} ${_pan.dunType.label}${_pan.bureau}局');
    buffer.writeln('旬首：${_pan.xunShou}${_pan.xunYi} 空亡：${_pan.kongWang}');
    buffer.writeln('值符：${_pan.valueStar} 值使：${_pan.valueGate} 马星：${_pan.horseStar}');
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
        buffer.writeln('${cell.palaceName} ${cell.deity} $starText ${cell.gate} 天盘$heavenText 地盘$earthText$kongWangText');
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
                label:
                    '日期 ${QimenEngine.formatDateTime(_selectedDateTime).split(' ').first}',
                onTap: _pickDate,
                icon: Icons.calendar_today_outlined,
              ),
              _ActionChipButton(
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
          const SizedBox(height: 16),
          Text(
            '起局方式',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A4522),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: QimenSetupMethod.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.label),
                    selected: _setupMethod == item,
                    onSelected: (_) {
                      setState(() {
                        _setupMethod = item;
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
              _SummaryBadge(title: '局数', value: '${_pan.dunType.label}${_pan.bureau}局'),
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
        children.add(_PanCellWidget(
          key: ValueKey('cell_${cell.palaceNumber}_${_pan.generatedAt.millisecondsSinceEpoch}'),
          cell: cell,
        ));
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
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4483B), width: 1.5),
                  ),
                  child: const Center(
                    child: Text('空', style: TextStyle(fontSize: 8, color: Color(0xFFD4483B))),
                  ),
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
              cell.hasTianQinStar ? '${cell.tianQinStem}${cell.star}禽' : cell.star,
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

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
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
