import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../../core/theme/hexa_colors.dart';
import '../../../../shared/widgets/hexa_empty_state.dart';
import '../../../../shared/widgets/operational_ui.dart';
import 'home_recent_changes_section.dart' show HomeSectionSkeleton;
import 'home_warehouse_activity_row.dart';
/// Unified warehouse activity — collapsible on home (max 15 rows).
class HomeWarehouseActivityFeed extends ConsumerStatefulWidget {
  const HomeWarehouseActivityFeed({
    super.key,
    this.maxRows = 5,
  });

  final int maxRows;

  @override
  ConsumerState<HomeWarehouseActivityFeed> createState() =>
      _HomeWarehouseActivityFeedState();
}

class _HomeWarehouseActivityFeedState
    extends ConsumerState<HomeWarehouseActivityFeed> {
  bool _expanded = false;

  void _openFullPage() => context.push('/home/activity');

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(homePeriodProvider);
    final feedAsync = ref.watch(homeRecentActivityFeedProvider);
    final title = switch (period) {
      HomePeriod.today => 'Recent activity (today)',
      HomePeriod.week => 'Recent activity (week)',
      HomePeriod.month => 'Recent activity (month)',
      HomePeriod.year => 'Recent activity (year)',
      HomePeriod.allTime => 'Recent activity (all time)',
      HomePeriod.custom => 'Recent activity (custom range)',
    };

    return feedAsync.when(
      loading: () => OperationalSection(
        title: title,
        dense: true,
        child: const HomeSectionSkeleton(rows: 4),
      ),
      error: (_, __) => OperationalSection(
        title: title,
        dense: true,
        child: HomeWarehouseActivityError(
          onRetry: () => ref.invalidate(homeRecentActivityFeedProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: HexaColors.slateBorder, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20), // Card padding: 20
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, // Section Titles: 18 Bold
                      fontWeight: FontWeight.bold,
                      color: HexaColors.textOnLightSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const HomeWarehouseActivityEmpty(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }
        final cap = widget.maxRows.clamp(1, 15);
        final preview = items.take(cap).toList();
        final visible = _expanded ? items.take(15).toList() : preview;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: HexaColors.slateBorder, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20), // Card padding: 20
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18, // Section Titles: 18 Bold
                              fontWeight: FontWeight.bold,
                              color: HexaColors.textOnLightSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} events in period',
                            style: const TextStyle(
                              fontSize: 12, // Subtitle: 12
                              color: HexaColors.cost,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: _openFullPage,
                          child: const Text(
                            'View all',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (items.length > cap)
                          IconButton(
                            icon: Icon(
                              _expanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                            ),
                            onPressed: () =>
                                setState(() => _expanded = !_expanded),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < visible.length; i++) ...[
                  WarehouseActivityCompactRow(item: visible[i]),
                  if (i < visible.length - 1) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: HexaColors.slate100),
                    const SizedBox(height: 8),
                  ],
                ],
                if (!_expanded && items.length > cap) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _openFullPage,
                    child: Text(
                      'Show ${items.length - cap} more',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Home feed empty when the selected period has no warehouse activity.
@visibleForTesting
class HomeWarehouseActivityEmpty extends StatelessWidget {
  const HomeWarehouseActivityEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const HexaEmptyState(
      icon: Icons.history_rounded,
      title: 'No activity in this period',
      subtitle: 'Stock updates and purchases will appear here.',
    );
  }
}

/// Home feed load failure (UX-114).
@visibleForTesting
class HomeWarehouseActivityError extends StatelessWidget {
  const HomeWarehouseActivityError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Activity unavailable',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
