import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/hexa_operational_tokens.dart';
import '../../../core/auth/session_notifier.dart';
import '../../../core/json_coerce.dart';
import '../../../core/providers/home_dashboard_provider.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/router/post_auth_route.dart';
import '../../../core/utils/unit_utils.dart';
import '../../../core/widgets/hexa_error_card.dart';
import 'stock_compact_update_sheet.dart';
import 'widgets/stock_period_dropdown.dart';
import 'widgets/stock_status_badge.dart';

enum StockChangesPageMode { auto, staff, owner }

/// Separate route: recent stock audit activity log.
class StockChangesPage extends ConsumerWidget {
  const StockChangesPage({super.key, this.mode = StockChangesPageMode.auto});

  final StockChangesPageMode mode;

  bool _isStaff(WidgetRef ref) {
    if (mode == StockChangesPageMode.staff) return true;
    if (mode == StockChangesPageMode.owner) return false;
    final session = ref.watch(sessionProvider);
    return session != null && sessionIsStaff(session);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStaff = _isStaff(ref);
    final period = ref.watch(stockPagePeriodProvider);
    final feed = ref.watch(stockChangesFeedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F3EE),
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        toolbarHeight: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Stock changes',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          StockPeriodDropdown(showYear: !isStaff, iconSize: 22),
        ],
      ),
      body: feed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => HexaErrorCard.fromError(
          error: e,
          title: 'Could not load stock changes',
          onRetry: () => ref.invalidate(stockChangesFeedProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Text(
                'No stock changes for ${period.label.toLowerCase()}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(stockChangesFeedProvider);
              await ref.read(stockChangesFeedProvider.future);
            },
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                HexaOp.pageGutter,
                8,
                HexaOp.pageGutter,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final r = rows[i];
                return _ChangeRow(
                  row: r,
                  isStaffMode: isStaff,
                  ref: ref,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({
    required this.row,
    required this.isStaffMode,
    required this.ref,
  });

  final Map<String, dynamic> row;
  final bool isStaffMode;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final name = row['item_name']?.toString() ??
        row['catalog_item_name']?.toString() ??
        'Item';
    final before = coerceToDoubleNullable(row['qty_before'] ?? row['before_qty']);
    final after = coerceToDoubleNullable(row['qty_after'] ?? row['after_qty']);
    final delta = coerceToDouble(row['qty_delta'] ?? row['delta']);
    final unit = row['unit']?.toString() ?? '';
    final unitUp = unit.isNotEmpty ? unit.toUpperCase() : '';
    final by = row['user_name']?.toString() ?? row['updated_by']?.toString() ?? '';
    final atIso = row['created_at']?.toString() ?? row['audited_at']?.toString();
    final relative = formatStockRelativeTime(atIso);
    final itemId = row['item_id']?.toString() ?? row['catalog_item_id']?.toString();

    String qtyLine;
    if (before != null && after != null && before.isFinite && after.isFinite) {
      qtyLine =
          '${formatStockQtyNumber(before)} → ${formatStockQtyNumber(after)} $unitUp';
    } else {
      final sign = delta >= 0 ? '+' : '';
      qtyLine = '$sign${formatStockQtyNumber(delta)} $unitUp'.trim();
    }

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: itemId == null || itemId.isEmpty
            ? null
            : () async {
                if (isStaffMode) {
                  final stock =
                      await ref.read(stockItemDetailProvider(itemId).future);
                  if (!context.mounted) return;
                  if (stock.isEmpty) {
                    context.push('/catalog/item/$itemId');
                    return;
                  }
                  await showStockCompactUpdateSheet(
                    context: context,
                    ref: ref,
                    item: stock,
                  );
                } else {
                  context.push('/catalog/item/$itemId');
                }
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                qtyLine,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (by.isNotEmpty || relative.isNotEmpty)
                Text(
                  [
                    if (by.isNotEmpty) 'By $by',
                    if (relative.isNotEmpty) relative,
                  ].join(' • '),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
