import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../../core/theme/hexa_colors.dart';
import '../../../../core/widgets/friendly_load_error.dart';
import '../../../../shared/widgets/operational_ui.dart';
import 'home_formatters.dart';
import 'home_recent_changes_section.dart' show HomeSectionSkeleton;

/// Unified warehouse activity (purchases, stock, staff) — max 15 rows.
class HomeWarehouseActivityFeed extends ConsumerWidget {
  const HomeWarehouseActivityFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeRecentActivityFeedProvider);

    return feedAsync.when(
      loading: () => const OperationalSection(
        title: 'Warehouse activity',
        dense: true,
        child: HomeSectionSkeleton(rows: 4),
      ),
      error: (_, __) => OperationalSection(
        title: 'Warehouse activity',
        dense: true,
        child: FriendlyLoadError(
          message: 'Could not load activity',
          onRetry: () => ref.invalidate(homeRecentActivityFeedProvider),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const OperationalSection(
            title: 'Warehouse activity',
            dense: true,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Text(
                'No activity in this period',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          );
        }
        final visible = items.take(15).toList();
        return OperationalSection(
          title: 'Warehouse activity',
          dense: true,
          trailing: TextButton(
            onPressed: () => context.push('/staff/activity'),
            child: const Text('View all', style: TextStyle(fontSize: 12)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                _ActivityRow(item: visible[i]),
                if (i < visible.length - 1)
                  const Divider(height: 1, indent: 12, endIndent: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final HomeActivityItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.kind) {
      'purchase' || 'purchase_added' || 'trade_purchase' =>
        Icons.shopping_cart_rounded,
      'stock_quick_purchase' => Icons.add_shopping_cart_rounded,
      'stock' || 'stock_updated' || 'stock_change' || 'stock_adjustment' =>
        Icons.inventory_2_rounded,
      'low_stock' || 'alert' || 'reorder' => Icons.warning_amber_rounded,
      _ => Icons.circle_outlined,
    };
    final color = switch (item.kind) {
      'purchase' || 'stock_quick_purchase' => HexaColors.brandPrimary,
      'stock' => const Color(0xFF0D9488),
      _ => const Color(0xFF64748B),
    };
    final actor = item.actor?.trim();

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: HexaDsType.listTitle(context).copyWith(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      subtitle: Text(
        [
          if (item.subtitle.isNotEmpty) item.subtitle,
          if (actor != null && actor.isNotEmpty) actor,
          homeTimeAgo(item.at),
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: HexaDsType.bodySm(context).copyWith(fontSize: 11),
      ),
      trailing: item.amountInr != null && item.amountInr! > 0
          ? Text(
              homeInr(item.amountInr!),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: HexaColors.brandPrimary,
              ),
            )
          : (item.qtyChange != null && item.qtyChange!.isNotEmpty
              ? Text(item.qtyChange!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))
              : null),
      onTap: () {
        final id = item.routeId;
        if (id == null || id.isEmpty) return;
        if (item.kind.contains('purchase')) {
          context.push('/purchase/detail/$id');
        } else {
          context.push('/catalog/item/$id');
        }
      },
    );
  }
}
