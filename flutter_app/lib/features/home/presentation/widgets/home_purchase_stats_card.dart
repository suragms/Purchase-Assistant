import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/utils/unit_utils.dart';
import 'home_formatters.dart';

/// Period purchase totals: bags, kg, boxes, tins, and amount.
class HomePurchaseStatsCard extends ConsumerWidget {
  const HomePurchaseStatsCard({super.key});

  static String _qty(double n) =>
      n.abs() < 0.001 ? '—' : formatStockQtyNumber(n);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(homePeriodProvider);
    final dash = ref.watch(homeDashboardDataProvider).snapshot.data;

    Widget cell(String label, String value, Color color) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
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
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(HexaOp.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Purchases (${period.label})',
              style: HexaOp.cardTitle(context),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                cell('Bags', _qty(dash.totalBags), const Color(0xFF3B6D11)),
                cell('KG', _qty(dash.totalKg), const Color(0xFF185FA5)),
                cell('Boxes', _qty(dash.totalBoxes), const Color(0xFF6D4C1B)),
                cell('Tins', _qty(dash.totalTins), const Color(0xFF7C3D3D)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A6B8A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Total amount: ${homeInr(dash.totalPurchase)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            if (dash.purchaseCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${dash.purchaseCount} bills in period',
                  textAlign: TextAlign.center,
                  style: HexaOp.caption(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
