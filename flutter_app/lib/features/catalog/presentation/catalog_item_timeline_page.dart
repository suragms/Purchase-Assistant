import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/json_coerce.dart';
import '../../../core/router/navigation_ext.dart';
import '../../../core/providers/catalog_providers.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../shared/widgets/hexa_empty_state.dart';
import '../../purchase/state/purchase_providers.dart';

import '../../../core/theme/hexa_colors.dart';
/// Full chronological timeline for one catalog item (purchases + stock audit).
class CatalogItemTimelinePage extends ConsumerWidget {
  const CatalogItemTimelinePage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(catalogItemDetailProvider(itemId));
    final auditsAsync = ref.watch(stockItemAuditProvider(itemId));
    final historyState = ref.watch(itemHistoryLinesProvider(itemId));

    final itemName = itemAsync.valueOrNull?['name']?.toString() ?? 'Item';

    if (itemAsync.isLoading ||
        auditsAsync.isLoading ||
        historyState.loadingInitial) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.popOrGo('/catalog/item/$itemId'),
          ),
          title: Text(
            '$itemName · Timeline',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (itemAsync.hasError ||
        auditsAsync.hasError ||
        historyState.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => context.popOrGo('/catalog/item/$itemId'),
          ),
          title: const Text('Timeline'),
        ),
        body: CatalogItemTimelineLoadError(
          onRetry: () {
            ref.invalidate(catalogItemDetailProvider(itemId));
            ref.invalidate(stockItemAuditProvider(itemId));
            ref.invalidate(itemHistoryLinesProvider(itemId));
          },
        ),
      );
    }

    final events = <_TimelineEvent>[];
    for (final row in historyState.rows) {
      events.add(_TimelineEvent(
        at: row.purchaseDate,
        kind: _TimelineKind.purchase,
        title: 'Purchased ${row.qty} ${row.unit}',
        subtitle: '${row.humanId} · ${row.supplierName}',
      ));
    }
    for (final a in auditsAsync.valueOrNull ?? const []) {
      final rawAt = a['created_at']?.toString() ??
          a['updated_at']?.toString() ??
          a['audited_at']?.toString();
      final at = DateTime.tryParse(rawAt ?? '');
      if (at == null) continue;
      final oldQ = coerceToDouble(a['old_qty']);
      final newQ = coerceToDouble(a['new_qty']);
      final diff = newQ - oldQ;
      final diffStr = (diff - diff.roundToDouble()).abs() < 0.001
          ? diff.round().toString()
          : diff.toStringAsFixed(1);
      events.add(_TimelineEvent(
        at: at,
        kind: _TimelineKind.stock,
        title: 'Stock ${diff >= 0 ? '+' : ''}$diffStr',
        subtitle: a['reason']?.toString() ??
            a['adjustment_type']?.toString() ??
            'Stock update',
      ));
    }
    events.sort((a, b) => b.at.compareTo(a.at));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.popOrGo('/catalog/item/$itemId'),
        ),
        title: Text(
          '$itemName · Timeline',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: events.isEmpty
          ? CatalogItemTimelineEmpty(
              onBackToItem: () =>
                  context.popOrGo('/catalog/item/$itemId'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = events[i];
                final color = switch (e.kind) {
                  _TimelineKind.purchase => HexaColors.materialGreen,
                  _TimelineKind.stock when e.title.contains('-') =>
                    HexaColors.materialRed,
                  _TimelineKind.stock => HexaColors.materialBlue,
                };
                final icon = switch (e.kind) {
                  _TimelineKind.purchase => Icons.shopping_cart_rounded,
                  _TimelineKind.stock => Icons.inventory_2_rounded,
                };
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d MMM · h:mm a').format(e.at),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (e.subtitle.isNotEmpty)
                            Text(
                              e.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

/// Empty chrome for [CatalogItemTimelinePage] — extracted for widget tests.
class CatalogItemTimelineEmpty extends StatelessWidget {
  const CatalogItemTimelineEmpty({super.key, required this.onBackToItem});

  final VoidCallback onBackToItem;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.timeline_outlined,
      title: 'No events recorded yet',
      subtitle:
          'Purchases and stock updates for this item will appear here.',
      primaryActionLabel: 'Back to item',
      onPrimaryAction: onBackToItem,
    );
  }
}

/// Catalog item timeline load failure (UX-143).
@visibleForTesting
class CatalogItemTimelineLoadError extends StatelessWidget {
  const CatalogItemTimelineLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.timeline_outlined,
      title: 'Could not load timeline',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}

enum _TimelineKind { purchase, stock }

class _TimelineEvent {
  const _TimelineEvent({
    required this.at,
    required this.kind,
    required this.title,
    required this.subtitle,
  });

  final DateTime at;
  final _TimelineKind kind;
  final String title;
  final String subtitle;
}
