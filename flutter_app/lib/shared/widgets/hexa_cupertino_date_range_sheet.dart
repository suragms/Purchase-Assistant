import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/design_system/hexa_responsive.dart';
import '../../core/theme/hexa_colors.dart';

/// Cupertino wheel date-range picker hosted by [showHexaBottomSheet].
///
/// Replaces Material [showDateRangePicker] multi-month calendar scroll on
/// Reports / Home period custom range.
Future<DateTimeRange?> showHexaCupertinoDateRangeSheet(
  BuildContext context, {
  required DateTime initialStart,
  required DateTime initialEnd,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Select date range',
}) {
  final now = DateTime.now();
  final first = firstDate ?? DateTime(now.year - 5, 1, 1);
  final last = lastDate ?? DateTime(now.year + 1, 12, 31);
  var start = DateTime(initialStart.year, initialStart.month, initialStart.day);
  var end = DateTime(initialEnd.year, initialEnd.month, initialEnd.day);
  if (start.isAfter(end)) {
    final t = start;
    start = end;
    end = t;
  }
  start = _clampDay(start, first, last);
  end = _clampDay(end, first, last);

  return showHexaBottomSheet<DateTimeRange>(
    context: context,
    compact: true,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: _HexaCupertinoDateRangeBody(
      title: title,
      first: first,
      last: last,
      initialStart: start,
      initialEnd: end,
    ),
  );
}

DateTime _clampDay(DateTime d, DateTime first, DateTime last) {
  if (d.isBefore(first)) return first;
  if (d.isAfter(last)) return last;
  return d;
}

class _HexaCupertinoDateRangeBody extends StatefulWidget {
  const _HexaCupertinoDateRangeBody({
    required this.title,
    required this.first,
    required this.last,
    required this.initialStart,
    required this.initialEnd,
  });

  final String title;
  final DateTime first;
  final DateTime last;
  final DateTime initialStart;
  final DateTime initialEnd;

  @override
  State<_HexaCupertinoDateRangeBody> createState() =>
      _HexaCupertinoDateRangeBodyState();
}

class _HexaCupertinoDateRangeBodyState
    extends State<_HexaCupertinoDateRangeBody> {
  late DateTime _start;
  late DateTime _end;
  bool _editingEnd = false;
  final _fmt = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _onWheel(DateTime v) {
    setState(() {
      if (_editingEnd) {
        _end = DateTime(v.year, v.month, v.day);
        if (_end.isBefore(_start)) _start = _end;
      } else {
        _start = DateTime(v.year, v.month, v.day);
        if (_start.isAfter(_end)) _end = _start;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _editingEnd ? _end : _start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RangeChip(
                label: 'From',
                value: _fmt.format(_start),
                selected: !_editingEnd,
                onTap: () => setState(() => _editingEnd = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RangeChip(
                label: 'To',
                value: _fmt.format(_end),
                selected: _editingEnd,
                onTap: () => setState(() => _editingEnd = true),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 180,
          child: CupertinoTheme(
            data: const CupertinoThemeData(
              brightness: Brightness.light,
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            child: CupertinoDatePicker(
              key: ValueKey<String>(_editingEnd ? 'end' : 'start'),
              mode: CupertinoDatePickerMode.date,
              initialDateTime: active,
              minimumDate: widget.first,
              maximumDate: widget.last,
              onDateTimeChanged: _onWheel,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    DateTimeRange(start: _start, end: _end),
                  );
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? HexaColors.primaryLight.withValues(alpha: 0.45)
          : HexaColors.surfaceApp,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: HexaColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
