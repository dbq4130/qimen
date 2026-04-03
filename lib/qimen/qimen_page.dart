import 'package:flutter/material.dart';

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
  QimenDunType _manualDunType = QimenDunType.yang;
  QimenPanMode _panMode = QimenPanMode.zhuan;
  QimenSetupMethod _setupMethod = QimenSetupMethod.chaibu;
  int _bureau = 1;
  late QimenPan _pan;

  @override
  void initState() {
    super.initState();
    _pan = _buildPan();
  }

  QimenPan _buildPan() {
    return QimenEngine.generate(
      dateTime: _selectedDateTime,
      manualDunType: _manualDunType,
      useAutoDunType: _useAutoDunType,
      panMode: _panMode,
      setupMethod: _setupMethod,
      bureau: _bureau,
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

    setState(() {
      _selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
      _pan = _buildPan();
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
    setState(() {
      _pan = _buildPan();
    });
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
          const SizedBox(height: 16),
          Text(
            '局数',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6A4522),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              9,
              (index) => ChoiceChip(
                label: Text('${index + 1}局'),
                selected: _bureau == index + 1,
                onSelected: (_) {
                  setState(() {
                    _bureau = index + 1;
                    _pan = _buildPan();
                  });
                },
              ),
            ),
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
              _SummaryBadge(title: '遁法', value: _pan.dunType.label),
              _SummaryBadge(title: '排盘', value: _pan.panMode.label),
              _SummaryBadge(title: '起局', value: _pan.setupMethod.label),
              _SummaryBadge(title: '局数', value: '${_pan.bureau}局'),
              _SummaryBadge(title: '年柱', value: _pan.yearGanzhi),
              _SummaryBadge(title: '月柱', value: _pan.monthGanzhi),
              _SummaryBadge(title: '日柱', value: _pan.dayGanzhi),
              _SummaryBadge(title: '时柱', value: _pan.hourGanzhi),
              _SummaryBadge(title: '时辰', value: _pan.hourLabel),
              _SummaryBadge(title: '值符', value: _pan.chiefDeity),
              _SummaryBadge(title: '值使', value: _pan.valueGate),
              _SummaryBadge(title: '值星', value: _pan.valueStar),
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
    for (var row = 0; row < 3; row++) {
      final children = <Widget>[];
      for (var column = 0; column < 3; column++) {
        final cell = _pan.cells[row * 3 + column];
        children.add(_PanCellWidget(cell: cell));
      }
      rows.add(TableRow(children: children));
    }

    return Table(
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
  const _PanCellWidget({required this.cell});

  final QimenPanCell cell;

  @override
  Widget build(BuildContext context) {
    final accent = cell.isCenter
        ? const Color(0xFFD3A85F)
        : const Color(0xFFE7D0A2);

    return Container(
      height: 148,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.45)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cell.palaceName} · ${cell.palaceNumber}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF523015),
            ),
          ),
          const SizedBox(height: 8),
          _InlineTag(
            label: cell.deity,
            backgroundColor: const Color(0xFF3C2A18),
          ),
          const SizedBox(height: 8),
          Text(
            cell.star,
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
          const Spacer(),
          Text(
            '天盘 ${cell.heavenStem}',
            style: const TextStyle(color: Color(0xFF5E412B)),
          ),
          Text(
            '地盘 ${cell.earthStem}',
            style: const TextStyle(color: Color(0xFF5E412B)),
          ),
        ],
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({required this.child});

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
