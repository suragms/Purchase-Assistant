import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/dashboard_role.dart';
import '../../../../core/auth/session_notifier.dart';
import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/utils/unit_utils.dart';
import 'home_formatters.dart';

/// Purchase-first hub: summary, units, profit, quick actions.
class HomePurchaseControlCenter extends ConsumerWidget {
  const HomePurchaseControlCenter({super.key});

  static String _qty(double n) =>
      n.abs() < 0.001 ? '' : formatStockQtyNumber(n);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(homePeriodProvider);
    final dash = ref.watch(homeDashboardDataProvider).snapshot.data;
    final session = ref.watch(sessionProvider);
    final showProfit = session != null && sessionHasOwnerDashboard(session);

    final units = <({String label, double qty, Color color})>[];
    if (dash.totalBags > 0.001) {
      units.add((label: 'Bags', qty: dash.totalBags, color: const Color(0xFF3B6D11)));
    }
    if (dash.totalKg > 0.001) {
      units.add((label: 'KG', qty: dash.totalKg, color: const Color(0xFF185FA5)));
    }
    if (dash.totalBoxes > 0.001) {
      units.add((label: 'Boxes', qty: dash.totalBoxes, color: const Color(0xFF6D4C1B)));
    }
    if (dash.totalTins > 0.001) {
      units.add((label: 'Tins', qty: dash.totalTins, color: const Color(0xFF7C3D3D)));
    }

    final received = dash.receivedDeliveryCount;
    final pending = dash.pendingDeliveryCount;
    final suppliers = dash.supplierCount;
    final brokers = dash.brokerCount;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(HexaOp.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Purchase center (${period.label})', style: HexaOp.cardTitle(context)),
            const SizedBox(height: 8),
            Text(
              homeInr(dash.totalPurchase),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _metaChip('${dash.purchaseCount} bills'),
                if (received > 0) _metaChip('$received received'),
                if (pending > 0) _metaChip('$pending pending delivery'),
                if (suppliers > 0) _metaChip('$suppliers suppliers'),
                if (brokers > 0) _metaChip('$brokers brokers'),
              ],
            ),
            if (showProfit && dash.totalProfit.abs() > 0.01) ...[
              const SizedBox(height: 8),
              Text(
                'Profit ${homeInr(dash.totalProfit)}'
                '${dash.profitPercent != null ? ' (${dash.profitPercent!.toStringAsFixed(1)}%)' : ''}',
                style: HexaOp.caption(context).copyWith(fontWeight: FontWeight.w800),
              ),
            ],
            if (units.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final u in units)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _unitCell(u.label, _qty(u.qty), u.color),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _action(context, 'Add purchase', Icons.add_shopping_cart_rounded,
                      () => context.push('/purchase/new')),
                  _action(context, 'Pending', Icons.local_shipping_outlined,
                      () => context.go('/purchase')),
                  _action(context, 'Suppliers', Icons.store_outlined,
                      () => context.push('/contacts?tab=suppliers')),
                  _action(context, 'Brokers', Icons.handshake_outlined,
                      () => context.push('/contacts?tab=brokers')),
                  _action(context, 'History', Icons.receipt_long_outlined,
                      () => context.go('/purchase')),
                  _action(context, 'Reports', Icons.bar_chart_rounded,
                      () => context.go('/reports')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String text) => Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
      );

  Widget _unitCell(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _action(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
