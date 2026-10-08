import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'zeri_engine.dart';
import 'zeri_models.dart';

class ZeriPage extends StatefulWidget {
  const ZeriPage({
    super.key,
    this.initialYear,
    this.initialMonth,
    this.initialBureau,
  });

  final int? initialYear;
  final int? initialMonth;
  final SittingBureau? initialBureau;

  @override
  State<ZeriPage> createState() => _ZeriPageState();
}

class _ZeriPageState extends State<ZeriPage> {
  static const _weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

  late int _year;
  late int _month;
  late SittingBureau _bureau;
  YongshenMountain? _mountain;
  late ZeriMonthBoard _board;
  ZeriDay? _focused;
  _ZeriPick? _pick;

  @override
  void initState() {
    super.initState();
    _bureau = widget.initialBureau ?? SittingBureau.fire;
    if (widget.initialYear != null && widget.initialMonth != null) {
      _year = widget.initialYear!;
      _month = widget.initialMonth!;
    } else {
      final current = ZeriEngine.currentSolarMonth();
      _year = current.year;
      _month = current.month;
    }
    _board = _load();
    _focusTodayIfSelectable();
  }

  ZeriMonthBoard _load() {
    return ZeriEngine.buildSolar(
      year: _year,
      month: _month,
      bureau: _bureau,
      mountain: _mountain,
    );
  }

  void _focusTodayIfSelectable() {
    final today = DateTime.now();
    if (today.year != _year || today.month != _month) {
      return;
    }
    for (final day in _board.days) {
      if (day.solarDay == today.day && day.selectable) {
        _focused = day;
        return;
      }
    }
  }

  void _setMountain(YongshenMountain? mountain) {
    setState(() {
      _mountain = mountain;
      _board = _load();
      _restoreFocus();
    });
  }

  void _setBureau(SittingBureau bureau) {
    setState(() {
      _bureau = bureau;
      _board = _load();
      _restoreFocus();
    });
  }

  void _shiftMonth(int delta) {
    var year = _year;
    var month = _month + delta;
    if (month < 1) {
      month = 12;
      year -= 1;
    } else if (month > 12) {
      month = 1;
      year += 1;
    }
    if (year < ZeriEngine.minYear || year > ZeriEngine.maxYear) {
      return;
    }
    setState(() {
      _year = year;
      _month = month;
      _focused = null;
      _pick = null;
      _board = _load();
      _focusTodayIfSelectable();
    });
  }

  void _restoreFocus() {
    final solarText = _focused?.solarText;
    final hourGanzhi = _pick?.hour.ganzhi;
    _focused = null;
    _pick = null;
    if (solarText == null) {
      return;
    }
    for (final day in _board.days) {
      if (day.solarText != solarText) {
        continue;
      }
      _focused = day;
      if (!day.selectable || hourGanzhi == null) {
        return;
      }
      for (final hour in day.hours) {
        if (hour.ganzhi == hourGanzhi && hour.selectable) {
          _pick = _ZeriPick(day, hour);
          return;
        }
      }
      return;
    }
  }

  void _focusDay(ZeriDay day) {
    setState(() {
      if (_focused?.solarText != day.solarText || !day.selectable) {
        _pick = null;
      }
      _focused = day;
    });
  }

  void _selectHour(ZeriDay day, ZeriHour hour) {
    if (!hour.selectable) {
      return;
    }
    setState(() {
      _focused = day;
      _pick = _ZeriPick(day, hour);
    });
  }

  String _copyText(_ZeriPick pick) {
    final day = pick.day;
    final hour = pick.hour;
    return [
      '【天星择日】',
      '坐局：${_bureau.label}',
      '${day.yearGanzhi}年 ${day.monthGanzhi}月 ${day.dayGanzhi}日 ${hour.ganzhi}时',
      '阳历：${day.solarText} ${hour.rangeText}',
      '阴历：${day.lunarDateText}',
      '${day.yearGanzhi}${day.yearAnimal}年 ${day.monthGanzhi}月 ${day.dayGanzhi}日',
      '宜：${day.yi.join('、')}',
      '忌：${day.ji.join('、')}',
    ].join('\n');
  }

  void _copyPick() {
    final pick = _pick;
    if (pick == null) {
      return;
    }
    Clipboard.setData(ClipboardData(text: _copyText(pick)));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('择日已复制'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final atStart = _year <= ZeriEngine.minYear && _month == 1;
    final atEnd = _year >= ZeriEngine.maxYear && _month == 12;
    return Scaffold(
      appBar: AppBar(
        title: const Text('天星择日'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3C2A18),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: _pick == null
          ? null
          : _SelectedBar(bureau: _bureau, pick: _pick!, onCopy: _copyPick),
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
            key: const ValueKey('zeri_day_list'),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPickerCard(theme),
                const SizedBox(height: 12),
                _PaperCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            key: const ValueKey('zeri_prev_month'),
                            onPressed: atStart ? null : () => _shiftMonth(-1),
                            icon: const Icon(Icons.chevron_left),
                            tooltip: '上个月',
                          ),
                          Expanded(
                            child: Row(
                              key: const ValueKey('zeri_month_title'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$_month月',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1C1C1C),
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$_year年',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF8A8175),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: const ValueKey('zeri_next_month'),
                            onPressed: atEnd ? null : () => _shiftMonth(1),
                            icon: const Icon(Icons.chevron_right),
                            tooltip: '下个月',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          for (final label in _weekLabels)
                            Expanded(
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: label == '日' || label == '六'
                                      ? const Color(0xFF9C2F2F)
                                      : const Color(0xFF7A5A33),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildGrid(),
                    ],
                  ),
                ),
                if (_focused != null) ...[
                  const SizedBox(height: 12),
                  _buildDayDetail(_focused!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerCard(ThemeData theme) {
    final months = _mountain == null
        ? null
        : ZeriEngine.monthsOfMountain(_mountain!);
    return _PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PickerButton(
                  title: '用神山',
                  value: _mountain?.label ?? '不限',
                  onTap: _pickMountain,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PickerButton(
                  key: const ValueKey('zeri_bureau_button'),
                  title: '坐局',
                  value: _bureau.label,
                  onTap: _pickBureau,
                ),
              ),
            ],
          ),
          if (months != null) ...[
            const SizedBox(height: 8),
            Text(
              months.label,
              style: const TextStyle(
                color: Color(0xFF9C2F2F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickBureau() async {
    final selected = await showModalBottomSheet<SittingBureau>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final bureau in SittingBureau.values)
                ListTile(
                  key: ValueKey('zeri_bureau_${bureau.name}'),
                  title: Text(bureau.label),
                  trailing: _bureau == bureau
                      ? const Icon(Icons.check, color: Color(0xFF8A5A2B))
                      : null,
                  onTap: () => Navigator.of(context).pop(bureau),
                ),
            ],
          ),
        );
      },
    );
    if (selected != null) {
      _setBureau(selected);
    }
  }

  Future<void> _pickMountain() async {
    final selected = await showModalBottomSheet<_MountainChoice>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.62,
            child: ListView(
              children: [
                ListTile(
                  key: const ValueKey('zeri_mountain_none'),
                  title: const Text('不限'),
                  trailing: _mountain == null
                      ? const Icon(Icons.check, color: Color(0xFF8A5A2B))
                      : null,
                  onTap: () => Navigator.of(
                    context,
                  ).pop(const _MountainChoice.cleared()),
                ),
                for (final section in const ['天干', '地支', '卦']) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      section,
                      style: const TextStyle(
                        color: Color(0xFF8A8175),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (final mountain in _mountainsOf(section))
                    ListTile(
                      key: ValueKey('zeri_mountain_${mountain.name}'),
                      title: Text(mountain.label),
                      trailing: _mountain == mountain
                          ? const Icon(Icons.check, color: Color(0xFF8A5A2B))
                          : null,
                      onTap: () =>
                          Navigator.of(context).pop(_MountainChoice(mountain)),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (!context.mounted || selected == null) {
      return;
    }
    _setMountain(selected.mountain);
  }

  Widget _buildGrid() {
    final leading = DateTime(_year, _month, 1).weekday - 1;
    final count = leading + _board.days.length;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 62,
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        if (index < leading) {
          return const SizedBox.shrink();
        }
        final day = _board.days[index - leading];
        final selected = _focused?.solarText == day.solarText;
        return _DayCell(
          day: day,
          selected: selected,
          onTap: () => _focusDay(day),
        );
      },
    );
  }

  Widget _buildDayDetail(ZeriDay day) {
    return _PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.lunarDateText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${day.yearGanzhi}${day.yearAnimal}年  ${day.monthGanzhi}月  ${day.dayGanzhi}日',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF5C6B8A),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (day.unusableReason != null) ...[
            const SizedBox(height: 12),
            Text(
              day.unusableReason!,
              key: const ValueKey('zeri_unusable_reason'),
              style: const TextStyle(
                color: Color(0xFF9C2F2F),
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _ActivityLine(
            title: '宜',
            items: day.yi,
            badgeColor: const Color(0xFF2F6BFF),
          ),
          const SizedBox(height: 8),
          _ActivityLine(
            title: '忌',
            items: day.ji,
            badgeColor: const Color(0xFF8E96A3),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hour in day.hours)
                _HourChip(
                  hour: hour,
                  selected:
                      _pick?.day.solarText == day.solarText &&
                      _pick?.hour.ganzhi == hour.ganzhi,
                  onTap: hour.selectable ? () => _selectHour(day, hour) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MountainChoice {
  const _MountainChoice(this.mountain);
  const _MountainChoice.cleared() : mountain = null;

  final YongshenMountain? mountain;
}

List<YongshenMountain> _mountainsOf(String group) {
  return switch (group) {
    '天干' => YongshenMountain.stems,
    '地支' => YongshenMountain.branches,
    _ => YongshenMountain.trigrams,
  };
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2E1B9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF8A8175),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF3C2A18),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more, color: Color(0xFF8A5A2B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZeriPick {
  const _ZeriPick(this.day, this.hour);

  final ZeriDay day;
  final ZeriHour hour;
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final ZeriDay day;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = day.selectable;
    final weekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    final numberColor = !enabled
        ? const Color(0xFFB7A894)
        : weekend
        ? const Color(0xFF2F6BFF)
        : const Color(0xFF1C1C1C);
    final subColor = !enabled
        ? const Color(0xFFC8BBA8)
        : day.favoredMonth
        ? const Color(0xFF9C2F2F)
        : const Color(0xFF8A8175);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('zeri_day_${day.solarText}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                key: ValueKey('zeri_day_mark_${day.solarText}'),
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: selected
                    ? BoxDecoration(
                        color: enabled
                            ? const Color(0xFF2F6BFF)
                            : const Color(0xFFD6E3F8),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Text(
                  '${day.solarDay}',
                  style: TextStyle(
                    color: selected
                        ? (enabled ? Colors.white : const Color(0xFF7E93B5))
                        : numberColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1,
                  ),
                ),
              ),
              Text(
                day.cautioned
                    ? '${day.lunarMark}$zeriCautionMark'
                    : day.lunarMark,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: subColor, fontSize: 10, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({
    required this.title,
    required this.items,
    required this.badgeColor,
  });

  final String title;
  final List<String> items;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            items.isEmpty ? '无' : items.join('  '),
            style: const TextStyle(
              color: Color(0xFF3A3A3A),
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _HourChip extends StatelessWidget {
  const _HourChip({
    required this.hour,
    required this.selected,
    required this.onTap,
  });

  final ZeriHour hour;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final sealed = !hour.selectable;
    final background = selected
        ? const Color(0xFF3C2A18)
        : sealed
        ? const Color(0xFFE7E0D6)
        : const Color(0xFFFFF7E7);
    final foreground = selected
        ? Colors.white
        : sealed
        ? const Color(0xFFB7A894)
        : const Color(0xFF3C2A18);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF3C2A18)
                  : const Color(0xFFD2A76B),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${hour.ganzhi}时',
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (hour.showExclamation) ...[
                    const SizedBox(width: 4),
                    Text(
                      zeriCautionMark,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFFFFD27A)
                            : const Color(0xFFC4552A),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                hour.startText,
                style: TextStyle(color: foreground, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedBar extends StatelessWidget {
  const _SelectedBar({
    required this.bureau,
    required this.pick,
    required this.onCopy,
  });

  final SittingBureau bureau;
  final _ZeriPick pick;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final day = pick.day;
    final hour = pick.hour;
    final mark = hour.showExclamation ? zeriCautionMark : '';
    return Material(
      color: const Color(0xFF3C2A18),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '已选 ${bureau.label}  ${day.yearGanzhi}年 ${day.monthGanzhi}月 ${day.dayGanzhi}日 ${hour.ganzhi}时$mark',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('zeri_copy_button'),
                onPressed: onCopy,
                tooltip: '复制择日',
                icon: const Icon(Icons.copy, color: Colors.white),
              ),
            ],
          ),
        ),
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
