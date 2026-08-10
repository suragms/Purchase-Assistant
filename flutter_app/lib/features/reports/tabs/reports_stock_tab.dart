import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_error_messages.dart';
import '../../../core/providers/operations_providers.dart';
import '../../../shared/widgets/hexa_empty_state.dart';
import '../stock/reports_stock_providers.dart';
import '../stock/reports_stock_status.dart';
import '../widgets/reports_stock_filter_sort_bar.dart';
import '../widgets/reports_stock_intel_card.dart';

/// Reports → Stock — card-based warehouse intel (ERP rebuild).
class ReportsStockTab extends ConsumerStatefulWidget {
  const ReportsStockTab({super.key, this.highlightSection});

  final String? highlightSection;

  @override
  ConsumerState<ReportsStockTab> createState() => _ReportsStockTabState();
}

class _ReportsStockTabState extends ConsumerState<ReportsStockTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final chip =
          ReportsStockChipFilterX.fromHighlight(widget.highlightSection);
      if (chip != null) {
        ref.read(reportsStockChipFilterProvider.notifier).state = chip;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ops = ref.watch(operationalReportsProvider);

    return ops.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final dio = e is DioException ? e : null;
        final offline = dio != null && dioIsNetworkError(dio);
        return Center(
          child: ReportsStockTabLoadError(
            title: offline
                ? 'Could not load stock intel — check connection'
                : 'Could not load stock intel. Server error — tap to retry.',
            onRetry: () => ref.invalidate(operationalReportsProvider),
          ),
        );
      },
      data: (_) {
        final items = ref.watch(filteredReportsStockItemsProvider);
        final chip = ref.watch(reportsStockChipFilterProvider);

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: ReportsStockFilterSortBar()),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: ReportsStockEmpty(filter: chip),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) =>
                      ReportsStockIntelCard(item: items[index]),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Reports stock tab operational intel load failure (UX-149).
@visibleForTesting
class ReportsStockTabLoadError extends StatelessWidget {
  const ReportsStockTabLoadError({
    super.key,
    required this.title,
    required this.onRetry,
    this.subtitle = 'Check your connection, then retry.',
  });

  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.inventory_2_outlined,
      title: title,
      subtitle: subtitle,
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}

/// Empty stock intel list for the active chip / search filters.
class ReportsStockEmpty extends ConsumerWidget {
  const ReportsStockEmpty({super.key, required this.filter});

  final ReportsStockChipFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = filter != ReportsStockChipFilter.all;
    final title = switch (filter) {
      ReportsStockChipFilter.dead => 'No dead stock found',
      ReportsStockChipFilter.slow => 'No slow-moving items found',
      ReportsStockChipFilter.fast => 'No fast-moving items in this window',
      ReportsStockChipFilter.active => 'No active items with on-hand stock',
      ReportsStockChipFilter.all => 'No stock items match',
    };

    return HexaEmptyState(
      icon: Icons.inventory_2_outlined,
      title: title,
      subtitle: filtered
          ? 'Clear the movement filter to see more items.'
          : 'Try another search, or open stock to manage inventory.',
      primaryActionLabel: filtered ? 'Clear filter' : 'Open stock',
      onPrimaryAction: filtered
          ? () => ref.read(reportsStockChipFilterProvider.notifier).state =
              ReportsStockChipFilter.all
          : () => context.push('/stock'),
    );
  }
}
