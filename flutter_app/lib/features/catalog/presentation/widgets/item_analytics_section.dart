import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/json_coerce.dart';
import '../../../../core/providers/stock_providers.dart';
import '../../../../core/utils/unit_utils.dart';

class ItemAnalyticsSection extends ConsumerWidget {
  const ItemAnalyticsSection({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(stockItemDetailProvider(itemId)).valueOrNull ?? const <String, dynamic>{};
    final intel = ref.watch(stockItemIntelligenceProvider(itemId)).valueOrNull ?? const <String, dynamic>{};

    final unit = (stock['stock_unit'] ?? stock['unit'] ?? '').toString().trim().toUpperCase();
    final unitLabel = unit.isEmpty ? 'UNIT' : unit;

    final current = coerceToDouble(stock['current_stock']);
    final purchased = coerceToDouble(intel['period_purchased_qty'] ?? stock['period_purchased_qty']);
    final usage = coerceToDouble(intel['period_usage_qty']);
    final needsVerify = intel['needs_verification'] == true || stock['needs_verification'] == true;

    // We do not know the exact period days from this endpoint; use a safe, explainable default:
    // treat the intelligence window as 30 days for a first-pass reorder hint.
    const assumedDays = 30.0;
    final daily = usage > 0 ? usage / assumedDays : 0.0;
    final daysRemaining = (daily > 0.0001) ? (current / daily) : null;

    String reorderHint() {
      if (daysRemaining == null) return 'Not enough movement data to predict reorder.';
      final d = daysRemaining.clamp(0, 9999);
      if (d <= 3) return 'Reorder immediately (≈${d.toStringAsFixed(0)} days remaining).';
      if (d <= 7) return 'Reorder soon (≈${d.toStringAsFixed(0)} days remaining).';
      if (d <= 15) return 'Plan reorder (≈${d.toStringAsFixed(0)} days remaining).';
      return 'Stock looks healthy (≈${d.toStringAsFixed(0)} days remaining).';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(HexaOp.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Item analytics', style: HexaOp.cardTitle(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _pill('Current ${formatStockQtyNumber(current)} $unitLabel'),
                if (purchased > 0) _pill('Purchased (period) ${formatStockQtyNumber(purchased)}'),
                if (usage > 0) _pill('Moved/used (period) ${formatStockQtyNumber(usage)}'),
                if (daily > 0) _pill('Avg/day ${formatStockQtyNumber(daily)}'),
                if (needsVerify) _pill('Verification needed'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF1565C0).withValues(alpha: 0.25)),
              ),
              child: Text(
                reorderHint(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Reorder hint uses the last 30 days movement as a baseline. It is advisory only.',
              style: HexaOp.caption(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pill(String t) => Chip(
        label: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
}

