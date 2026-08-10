import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_period_provider.dart'
    show syncReportsRangeFromHomePeriod;
import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../shared/widgets/operational_ui.dart';
import '../../../../shared/widgets/hexa_cupertino_date_range_sheet.dart';

/// Global period chips (synced with Reports via [homePeriodProvider]).
class HomePeriodFilterRow extends ConsumerStatefulWidget {
  const HomePeriodFilterRow({super.key});

  @override
  ConsumerState<HomePeriodFilterRow> createState() =>
      _HomePeriodFilterRowState();
}

class _HomePeriodFilterRowState extends ConsumerState<HomePeriodFilterRow> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _setPeriod(HomePeriod p) {
    ref.read(homePeriodProvider.notifier).state = p;
    syncReportsRangeFromHomePeriod(ref, p);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      bustHomeDashboardVolatileCaches();
      ref.invalidate(homeDashboardDataProvider);
    });
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final existing = ref.read(homeCustomDateRangeProvider);
    final initialStart = existing?.start ?? now.subtract(const Duration(days: 29));
    final initialEnd = existing?.endInclusive ?? now;
    final picked = await showHexaCupertinoDateRangeSheet(
      context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialStart: initialStart,
      initialEnd: initialEnd,
    );
    if (picked == null || !mounted) return;
    ref.read(homeCustomDateRangeProvider.notifier).state = (
      start: picked.start,
      endInclusive: picked.end,
    );
    _setPeriod(HomePeriod.custom);
  }

  void _onSelected(String label) {
    final match = HomePeriod.values.where((p) => p.label == label);
    if (match.isEmpty) return;
    final p = match.first;
    if (p == HomePeriod.custom) {
      _pickCustom();
    } else {
      _setPeriod(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(homePeriodProvider);
    final labels = HomePeriod.values.map((p) => p.label).toList();
    final selected = period.label;
    // Six period chips — always Wrap (AGENTS: never horizontal scroll for 5+).
    return OperationalPillWrap(
      labels: labels,
      selected: selected,
      onSelected: _onSelected,
    );
  }
}
