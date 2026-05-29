import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/home_owner_dashboard_providers.dart';
import 'stock_today_feed.dart';

/// **Today** tab on [StockPage]: day-scoped stock audit feed.
class StockTodayTab extends ConsumerStatefulWidget {
  const StockTodayTab({super.key});

  @override
  ConsumerState<StockTodayTab> createState() => _StockTodayTabState();
}

class _StockTodayTabState extends ConsumerState<StockTodayTab> {
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  bool get _isToday {
    final now = DateTime.now();
    final t = DateTime(now.year, now.month, now.day);
    return _day == t;
  }

  @override
  Widget build(BuildContext context) {
    final audits = ref.watch(stockAuditDayProvider(_day));
    final label = DateFormat('d MMM yyyy').format(_day);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stockAuditDayProvider(_day));
        await ref.read(stockAuditDayProvider(_day).future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous day',
                onPressed: () => setState(() {
                  _day = _day.subtract(const Duration(days: 1));
                }),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Next day',
                onPressed: _isToday
                    ? null
                    : () => setState(() {
                          _day = _day.add(const Duration(days: 1));
                        }),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          audits.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const Center(
              child: Text('Could not load stock activity'),
            ),
            data: (rows) => StockTodayFeed(
              rows: rows,
              emptyMessage: 'No stock changes on this day',
            ),
          ),
        ],
      ),
    );
  }
}
