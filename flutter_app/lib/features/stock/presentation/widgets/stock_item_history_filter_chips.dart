import 'package:flutter/material.dart';

enum StockItemHistoryFilter { all, today, week, month, physical }

/// Time/kind filters for stock item history (Wrap — no horizontal scroll).
class StockItemHistoryFilterChips extends StatelessWidget {
  const StockItemHistoryFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  final StockItemHistoryFilter selected;
  final ValueChanged<StockItemHistoryFilter> onSelected;
  final bool compact;

  static String labelFor(StockItemHistoryFilter f) => switch (f) {
        StockItemHistoryFilter.all => 'All time',
        StockItemHistoryFilter.today => 'Today',
        StockItemHistoryFilter.week => 'This week',
        StockItemHistoryFilter.month => 'This month',
        StockItemHistoryFilter.physical => 'Physical',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 0 : 12,
        compact ? 0 : 8,
        compact ? 0 : 12,
        4,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final f in StockItemHistoryFilter.values)
            FilterChip(
              label: Text(labelFor(f)),
              selected: selected == f,
              onSelected: (_) => onSelected(f),
            ),
        ],
      ),
    );
  }
}
