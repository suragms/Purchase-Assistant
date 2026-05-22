import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/json_coerce.dart';
import '../../../core/providers/operations_providers.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/router/post_auth_route.dart';
import '../../../core/utils/unit_utils.dart';
import '../../../core/widgets/friendly_load_error.dart';
import '../../../core/widgets/list_skeleton.dart';
import '../../../core/widgets/warehouse_compact_card.dart';

/// Per-item warehouse detail: stock, purchases, adjustments.
class StockItemIntelligencePage extends ConsumerWidget {
  const StockItemIntelligencePage({
    super.key,
    required this.itemId,
    this.embedded = false,
    this.hideOwnerAnalytics = false,
  });

  final String itemId;
  final bool embedded;
  final bool hideOwnerAnalytics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stockItemIntelligenceProvider(itemId));
    final snapAsync = ref.watch(itemTodaySnapshotProvider(itemId));
    final session = ref.watch(sessionProvider);
    final staff = session != null && sessionIsStaff(session);
    final hideOwner = hideOwnerAnalytics || staff;
    final hideFinancials = session != null && !sessionCanSeeFinancials(session);
    final showOwnerBlocks = !hideOwner && !hideFinancials;

    final body = async.when(
      loading: () => const ListSkeleton(rowCount: 5, rowHeight: 72),
      error: (_, __) => FriendlyLoadError(
        message: 'Could not load item detail',
        onRetry: () => ref.invalidate(stockItemIntelligenceProvider(itemId)),
      ),
      data: (m) => _DetailBody(
        data: m,
        snapAsync: snapAsync,
        hideFinancials: hideFinancials,
        showOwnerBlocks: showOwnerBlocks,
        hideOwnerAnalytics: hideOwner,
      ),
    );

    if (embedded) {
      return ColoredBox(
        color: const Color(0xFFF5F3EE),
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item detail', style: TextStyle(fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: body,
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.data,
    required this.snapAsync,
    required this.hideFinancials,
    required this.showOwnerBlocks,
    required this.hideOwnerAnalytics,
  });

  final Map<String, dynamic> data;
  final AsyncValue<Map<String, dynamic>?> snapAsync;
  final bool hideFinancials;
  final bool showOwnerBlocks;
  final bool hideOwnerAnalytics;

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? 'Item';
    final code = data['item_code']?.toString();
    final barcode = data['barcode']?.toString();
    final cur = coerceToDouble(data['current_stock']);
    final purchased = coerceToDouble(data['period_purchased_qty']);
    final variance = coerceToDouble(data['period_variance_qty']);
    final reorder = coerceToDouble(data['reorder_level']);
    final unit = data['unit']?.toString() ?? '';
    final status = data['stock_status']?.toString() ?? '';
    final verify = data['needs_verification'] == true;
    final supplier = data['supplier_name']?.toString();
    final kgPerBag = coerceToDoubleNullable(data['default_kg_per_bag']);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        WarehouseCompactCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: HexaDsType.heading(16)),
              if (code != null && code.isNotEmpty)
                Text('Code $code', style: HexaDsType.body(12))
              else
                const Text(
                  'Missing item code',
                  style: TextStyle(fontSize: 12, color: Color(0xFFA32D2D)),
                ),
              if (barcode != null && barcode.isNotEmpty)
                Text('Barcode $barcode', style: HexaDsType.body(12)),
              Text('Status $status', style: HexaDsType.body(12)),
              const SizedBox(height: 8),
              Text(
                'On hand: ${stockDisplayPrimary(cur, unit)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (unit.toLowerCase() == 'bag' && kgPerBag != null && kgPerBag > 0)
                Text('${kgPerBag}kg per bag', style: HexaDsType.body(12)),
              Text(
                'Reorder: ${stockDisplayPrimary(reorder, unit)}',
                style: HexaDsType.body(12),
              ),
              if (supplier != null && supplier.isNotEmpty)
                Text('Supplier: $supplier', style: HexaDsType.body(12)),
              Text(
                'Period purchased: ${stockDisplayPrimary(purchased, unit)}',
                style: HexaDsType.body(13),
              ),
              if (showOwnerBlocks) ...[
                Text(
                  'Variance: ${variance >= 0 ? '+' : ''}${stockDisplayPrimary(variance, unit)}',
                  style: HexaDsType.body(13),
                ),
                if (data['needs_eviction'] == true)
                  const Text(
                    'Eviction recommended',
                    style: TextStyle(
                      color: Color(0xFFA32D2D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
              ],
              if (verify)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Needs verification',
                    style: TextStyle(
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!hideOwnerAnalytics)
          snapAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (snap) {
              if (snap == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: WarehouseCompactCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today snapshot', style: HexaDsType.heading(14)),
                      const SizedBox(height: 6),
                      Text('Opening: ${snap['opening_qty']}', style: HexaDsType.body(13)),
                      Text('Purchased: ${snap['purchased_qty']}', style: HexaDsType.body(13)),
                      Text('Used: ${snap['used_qty']}', style: HexaDsType.body(13)),
                      Text('Closing: ${snap['closing_qty']}', style: HexaDsType.body(13)),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 8),
        Text('Purchase history', style: HexaDsType.heading(14)),
        const SizedBox(height: 6),
        ..._purchaseTiles(data['recent_purchases'], hideFinancials),
        const SizedBox(height: 10),
        Text('Movement log', style: HexaDsType.heading(14)),
        const SizedBox(height: 6),
        ..._adjustmentTiles(data['recent_adjustments']),
      ],
    );
  }

  List<Widget> _purchaseTiles(dynamic raw, bool hideFinancials) {
    if (raw is! List || raw.isEmpty) {
      return [
        const Text('No purchases in this period', style: TextStyle(fontSize: 12)),
      ];
    }
    final df = DateFormat('dd-MMM-yyyy');
    return [
      for (final e in raw)
        if (e is Map) ...[
          Builder(builder: (context) {
            final status = _purchaseStatusLabel(e);
            final eta = e['eta']?.toString() ?? e['expected_delivery']?.toString();
            final date = e['purchase_date']?.toString();
            final dateLabel = date != null
                ? df.format(DateTime.parse(date).toLocal())
                : '';
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      e['supplier_name']?.toString() ?? 'Supplier',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (status != null) _statusChip(status),
                ],
              ),
              subtitle: Text(
                [
                  '${e['qty'] ?? '—'} ${e['unit'] ?? ''}',
                  if (!hideFinancials) e['rate']?.toString(),
                  if (dateLabel.isNotEmpty) dateLabel,
                  if (eta != null && eta.isNotEmpty) 'ETA $eta',
                ].where((s) => s != null && s.toString().isNotEmpty).join(' · '),
                style: const TextStyle(fontSize: 11),
              ),
            );
          }),
        ],
    ];
  }

  String? _purchaseStatusLabel(Map e) {
    final raw = e['delivery_status'] ??
        e['status'] ??
        e['trade_status'] ??
        e['purchase_status'];
    if (raw == null) return null;
    final s = raw.toString().toLowerCase();
    if (s.contains('pending')) return 'Pending';
    if (s.contains('arriv')) return 'Arriving';
    if (s.contains('deliver') || s.contains('received')) return 'Delivered';
    if (s.contains('delay') || s.contains('stuck')) return 'Delayed';
    return null;
  }

  Widget _statusChip(String label) {
    Color bg = const Color(0xFFE8F5E0);
    Color fg = const Color(0xFF3B6D11);
    if (label == 'Pending') {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFBA7517);
    } else if (label == 'Delayed') {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFA32D2D);
    } else if (label == 'Arriving') {
      bg = const Color(0xFFE3F2FD);
      fg = const Color(0xFF1565C0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  List<Widget> _adjustmentTiles(dynamic raw) {
    if (raw is! List || raw.isEmpty) {
      return [const Text('No adjustments', style: TextStyle(fontSize: 12))];
    }
    final df = DateFormat('MMM d, y');
    return [
      for (final e in raw)
        if (e is Map)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${e['old_qty']} → ${e['new_qty']} (${e['adjustment_type']})',
              style: const TextStyle(fontSize: 12),
            ),
            subtitle: Text(
              e['updated_at'] != null
                  ? df.format(DateTime.parse(e['updated_at'].toString()).toLocal())
                  : '',
              style: const TextStyle(fontSize: 11),
            ),
          ),
    ];
  }
}
