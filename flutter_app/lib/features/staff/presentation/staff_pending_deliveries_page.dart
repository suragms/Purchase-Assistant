import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/models/trade_purchase_models.dart';
import '../../../core/providers/business_aggregates_invalidation.dart';
import '../../../core/providers/staff_home_providers.dart';
import '../../../core/providers/trade_purchases_provider.dart'
    show staffTradePurchasesForAlertsProvider;
import '../../../core/theme/hexa_colors.dart';
import '../../../core/utils/unit_utils.dart';
import '../../../core/widgets/list_skeleton.dart';
import '../../../shared/widgets/hexa_empty_state.dart';

class StaffPendingDeliveriesPage extends ConsumerWidget {
  const StaffPendingDeliveriesPage({super.key});

  static String _bagsQtySummary(TradePurchase p) {
    final byUnit = <String, double>{};
    for (final l in p.lines) {
      final u = l.unit.trim().toUpperCase();
      byUnit[u] = (byUnit[u] ?? 0) + l.qty;
    }
    if (byUnit.isEmpty) return '—';
    return byUnit.entries
        .map((e) => '${formatStockQtyNumber(e.value)} ${e.key}')
        .join(' · ');
  }

  static double _totalLineQty(TradePurchase p) {
    var sum = 0.0;
    for (final l in p.lines) {
      sum += l.qty;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(staffDeliverySectionsProvider);
    final fetch = ref.watch(staffTradePurchasesForAlertsProvider);
    final total = sections?.total ?? 0;

    return Scaffold(
      backgroundColor: HexaColors.brandBackground,
      appBar: AppBar(
        title: Text(
          total > 0 ? 'Pending deliveries ($total)' : 'Pending deliveries',
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: HexaColors.brandPrimary,
        actions: [
          IconButton(
            tooltip: 'Scan purchase',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/barcode/scan'),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (sections == null && fetch.isLoading) {
            return const ListSkeleton(rowCount: 6);
          }
          if (fetch.hasError && sections == null) {
            return StaffPendingDeliveriesError(
              onRetry: () => invalidateStaffDeliverySurfaces(ref),
            );
          }
          final data = sections ?? const StaffDeliverySections();
          if (data.total == 0) {
            return HexaEmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'No pending deliveries',
              subtitle: 'When a purchase is dispatched, it shows up here to receive.',
              primaryActionLabel: 'Scan barcode',
              onPrimaryAction: () => context.push('/barcode/scan'),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            children: [
              if (data.dispatched.isNotEmpty) ...[
                _DeliverySection(
                  title: 'Dispatched',
                  purchases: data.dispatched,
                ),
                if (data.arrived.isNotEmpty ||
                    data.pendingVerification.isNotEmpty)
                  const SizedBox(height: 16),
              ],
              if (data.arrived.isNotEmpty) ...[
                _DeliverySection(
                  title: 'Arrived',
                  purchases: data.arrived,
                  highlight: true,
                ),
                if (data.pendingVerification.isNotEmpty)
                  const SizedBox(height: 16),
              ],
              if (data.pendingVerification.isNotEmpty)
                _DeliverySection(
                  title: 'Pending verification',
                  purchases: data.pendingVerification,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DeliverySection extends StatelessWidget {
  const _DeliverySection({
    required this.title,
    required this.purchases,
    this.highlight = false,
  });

  final String title;
  final List<TradePurchase> purchases;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final count = purchases.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '$title ($count)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HexaDsType.heading(14).copyWith(
                  color: highlight
                      ? HexaColors.accentOrange
                      : HexaColors.textOnLightSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < purchases.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          StaffPendingDeliveryTile(
            index: i + 1,
            purchase: purchases[i],
          ),
        ],
      ],
    );
  }
}

/// Pending delivery list row — clear Receive affordance for staff mobile (UX-008).
class StaffPendingDeliveryTile extends StatelessWidget {
  const StaffPendingDeliveryTile({
    super.key,
    required this.index,
    required this.purchase,
  });

  final int index;
  final TradePurchase purchase;

  @override
  Widget build(BuildContext context) {
    final p = purchase;
    final qty = StaffPendingDeliveriesPage._totalLineQty(p);
    final bagsLine = StaffPendingDeliveriesPage._bagsQtySummary(p);
    final days = DateTime.now().difference(p.purchaseDate).inDays;
    final qtyLabel =
        '${qty == qty.roundToDouble() ? qty.round() : qty.toStringAsFixed(1)} qty';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: HexaColors.brandBorder),
      ),
      child: ListTile(
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minVerticalPadding: 10,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: HexaColors.brandPrimary.withValues(alpha: 0.1),
          child: Text(
            '$index',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: HexaColors.brandPrimary,
            ),
          ),
        ),
        title: Text(
          p.supplierName?.trim().isNotEmpty == true
              ? p.supplierName!
              : 'Supplier',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${p.humanId} · ${DateFormat('d MMM').format(p.purchaseDate)}'
              '${days > 0 ? ' · $days d pending' : ''}'
              ' · $qtyLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              bagsLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HexaDsType.label(11, color: HexaDsColors.textMuted),
            ),
          ],
        ),
        trailing: Semantics(
          button: true,
          label: 'Receive shipment',
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Receive',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: HexaColors.brandPrimary,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: HexaColors.brandPrimary,
                ),
              ],
            ),
          ),
        ),
        onTap: () => context.push('/staff/receive/${p.id}'),
      ),
    );
  }
}

/// Staff pending deliveries list load failure (UX-131).
@visibleForTesting
class StaffPendingDeliveriesError extends StatelessWidget {
  const StaffPendingDeliveriesError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.local_shipping_outlined,
      title: 'Could not load pending deliveries',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
