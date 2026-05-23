import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/json_coerce.dart';
import '../../../../core/theme/hexa_colors.dart';
import '../../../../core/utils/unit_utils.dart';

/// Post-scan summary: current stock + last purchase (from barcode lookup).
class ScanItemStockSummaryCard extends StatelessWidget {
  const ScanItemStockSummaryCard({
    super.key,
    required this.item,
    this.showTitle = true,
  });

  final Map<String, dynamic> item;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.toString() ?? 'Item';
    final code = item['item_code']?.toString() ?? '—';
    final bc = item['barcode']?.toString() ?? '—';
    final unit = item['unit']?.toString() ??
        item['stock_unit']?.toString() ??
        item['default_unit']?.toString() ??
        '';
    final unitLabel = unit.isNotEmpty ? unit.toUpperCase() : '';
    final stock = coerceToDouble(item['current_stock']);

    final lpDateRaw = item['last_purchase_date'];
    DateTime? lpDate;
    if (lpDateRaw is String && lpDateRaw.isNotEmpty) {
      lpDate = DateTime.tryParse(lpDateRaw);
    } else if (lpDateRaw is DateTime) {
      lpDate = lpDateRaw;
    }
    final lpQty = coerceToDoubleNullable(item['last_purchase_qty']);
    final lpUnit =
        item['last_purchase_unit']?.toString().trim() ?? unit;
    final supplier = item['supplier_name']?.toString().trim() ?? '';

    String lastPurchaseLine;
    if (lpQty != null && lpQty > 0) {
      final parts = <String>[
        formatQtyForDisplay(lpQty),
        if (lpUnit.isNotEmpty) lpUnit.toUpperCase(),
      ];
      if (lpDate != null) {
        parts.add(DateFormat('d MMM yy').format(lpDate.toLocal()));
      }
      if (supplier.isNotEmpty) {
        parts.add(
          supplier.length > 22 ? '${supplier.substring(0, 22)}…' : supplier,
        );
      }
      lastPurchaseLine = parts.join(' · ');
    } else {
      lastPurchaseLine = 'No purchase yet';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$code · $bc',
              style: const TextStyle(fontSize: 12, color: HexaColors.textBody),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            'Current stock: ${formatQtyForDisplay(stock)}${unitLabel.isEmpty ? '' : ' $unitLabel'}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Last purchase: $lastPurchaseLine',
            style: const TextStyle(fontSize: 12, color: HexaColors.textBody),
          ),
        ],
      ),
    );
  }
}
