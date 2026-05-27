import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/trade_purchase_models.dart';

/// Compact pending / received delivery banner.
class PurchaseDetailDeliveryBanner extends StatelessWidget {
  const PurchaseDetailDeliveryBanner({
    super.key,
    required this.purchase,
    required this.onToggleDelivery,
  });

  final TradePurchase purchase;
  final VoidCallback onToggleDelivery;

  @override
  Widget build(BuildContext context) {
    final delivered = purchase.isDelivered;
    final borderColor =
        delivered ? const Color(0xFF16A34A) : const Color(0xFFE65100);
    final bg = delivered ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                delivered
                    ? Icons.check_circle_outline_rounded
                    : Icons.local_shipping_outlined,
                size: 20,
                color: borderColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivered ? 'Received at warehouse' : 'Pending delivery',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      delivered
                          ? (purchase.deliveredAt != null
                              ? 'Received on ${DateFormat('d MMM yyyy').format(purchase.deliveredAt!)}'
                              : 'Warehouse confirmed')
                          : 'Waiting for warehouse confirmation',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onToggleDelivery,
              style: OutlinedButton.styleFrom(
                foregroundColor: borderColor,
                side: BorderSide(color: borderColor),
              ),
              child: Text(delivered ? 'Mark Pending' : 'Mark Received'),
            ),
          ),
        ],
      ),
    );
  }
}
