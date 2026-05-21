import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../../core/widgets/friendly_load_error.dart';
import '../../../../shared/widgets/operational_ui.dart';
import '../../../stock/presentation/widgets/stock_today_feed.dart';
import 'home_recent_changes_section.dart';

/// Period-filtered stock movement feed.
class HomeStockMovementSection extends ConsumerWidget {
  const HomeStockMovementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(homePeriodProvider);
    final audits = ref.watch(stockAuditPeriodProvider);
    final title = switch (period) {
      HomePeriod.today => "Today's stock movement",
      HomePeriod.week => "Week stock movement",
      HomePeriod.month => "Month stock movement",
      HomePeriod.year => "Year stock movement",
      HomePeriod.custom => 'Stock movement',
    };

    return audits.when(
      loading: () => OperationalSection(
        title: title,
        dense: true,
        child: const HomeSectionSkeleton(rows: 2),
      ),
      error: (_, __) => OperationalSection(
        title: title,
        dense: true,
        child: FriendlyLoadError(
          message: 'Could not load stock movement',
          onRetry: () => ref.invalidate(stockAuditPeriodProvider),
        ),
      ),
      data: (rows) {
        if (rows.isEmpty) return const SizedBox.shrink();
        return OperationalSection(
          title: title,
          dense: true,
          trailing: TextButton(
            onPressed: () => context.push('/stock/today-feed'),
            child: const Text('View all', style: TextStyle(fontSize: 12)),
          ),
          child: StockTodayFeed(rows: rows, maxRows: 6),
        );
      },
    );
  }
}
