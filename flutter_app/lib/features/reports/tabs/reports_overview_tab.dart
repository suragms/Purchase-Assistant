import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/desktop_detail_chrome.dart';
import '../../../core/design_system/hexa_desktop_layout.dart';
import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/design_system/hexa_responsive.dart';
import '../../../core/models/trade_purchase_models.dart';
import '../../../core/reporting/trade_report_aggregate.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../../shared/widgets/hexa_empty_state.dart';
import '../presentation/reports_overview_chart_section.dart';
import '../shell/reports_layout.dart';
import '../widgets/reports_overview_kpi_grid.dart';

/// Overview tab: KPI grid first, charts below.
/// Desktop (≥1024): master column + insights detail pane (height-bound, never blank).
class ReportsOverviewTab extends ConsumerWidget {
  const ReportsOverviewTab({
    super.key,
    required this.agg,
    required this.merged,
    required this.showSkeleton,
    required this.hasFetchError,
    required this.showEmpty,
    required this.purchasesError,
    required this.onRetry,
    required this.onMatchHome,
    required this.onPickRange,
  });

  final TradeReportAgg agg;
  final List<TradePurchase> merged;
  final bool showSkeleton;
  final bool hasFetchError;
  final bool showEmpty;
  final Object? purchasesError;
  final VoidCallback onRetry;
  final VoidCallback onMatchHome;
  final VoidCallback onPickRange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void goTab(String tab) => context.replace('/reports?tab=$tab');

    final chartH = MediaQuery.sizeOf(context).height.clamp(400.0, 900.0) * 0.38;
    final viewport = chartH.clamp(kReportsChartMinHeight, 420.0);
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final scroll = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportsOverviewKpiGrid(
            agg: agg,
            onTapStock: () => goTab('stock'),
            onTapPurchases: () => goTab('purchase'),
            onTapItems: () => goTab('items'),
          ),
          const SizedBox(height: 8),
          ReportsOverviewChartSection(
            agg: agg,
            viewportHeight: viewport,
            isLoadingInitial: showSkeleton,
            loadFailed: hasFetchError && merged.isEmpty,
            loadError: purchasesError,
            isEmpty: showEmpty,
            canRetry: true,
            hideTopStatRow: true,
            onRetry: onRetry,
            onMatchHome: onMatchHome,
            onPickRange: onPickRange,
          ),
        ],
      ),
    );

    if (!context.isDesktopLayout) return scroll;

    // When the shell shows the filter drawer (≥1366), skip insights pane (no 4th column).
    final showInsights = MediaQuery.sizeOf(context).width < 1366;
    if (!showInsights) return scroll;

    final t = agg.totals;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 5, child: scroll),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          flex: 3,
          child: DesktopDetailPaneScaffold(
            header: const Text(
              'Period insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            stats: HexaDenseKpiGrid(
              phoneColumns: 2,
              desktopColumns: 2,
              mainAxisExtent: 72,
              spacing: 8,
              children: [
                _insightTile('Spend', money.format(t.inr)),
                _insightTile('Bills', '${t.deals}'),
                _insightTile('Items', '${agg.itemsAll.length}'),
                _insightTile('Suppliers', '${agg.suppliers.length}'),
              ],
            ),
            bodyTitle: 'Drill',
            body: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                ListTile(
                  dense: true,
                  title: const Text('Purchases'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => goTab('purchase'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Items'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => goTab('items'),
                ),
                ListTile(
                  dense: true,
                  title: const Text('Stock'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => goTab('stock'),
                ),
                if (showEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
                    child: HexaEmptyState(
                      icon: Icons.analytics_outlined,
                      title: 'No purchases in this period',
                      subtitle: 'Change the date range to see period insights.',
                      primaryActionLabel: 'Change period',
                      onPrimaryAction: onPickRange,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _insightTile(String label, String value) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HexaColors.slate700.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: HexaDsType.label(11)),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
