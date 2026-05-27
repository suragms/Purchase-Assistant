import 'package:flutter/material.dart';

import '../../../../core/theme/hexa_colors.dart';

/// Owner dashboard quick actions (max 7, no scan in primary row).
class HomeOwnerQuickActions extends StatelessWidget {
  const HomeOwnerQuickActions({
    super.key,
    required this.onStock,
    required this.onPurchase,
    required this.onLowStock,
    required this.onPendingDeliveries,
    required this.onReports,
    required this.onUsers,
    required this.onBarcode,
  });

  final VoidCallback onStock;
  final VoidCallback onPurchase;
  final VoidCallback onLowStock;
  final VoidCallback onPendingDeliveries;
  final VoidCallback onReports;
  final VoidCallback onUsers;
  final VoidCallback onBarcode;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Spec('Purchase', Icons.add_shopping_cart_rounded, HexaColors.brandPrimary, onPurchase),
      _Spec('Stock', Icons.inventory_2_rounded, const Color(0xFF1565C0), onStock),
      _Spec('Low stock', Icons.warning_amber_rounded, const Color(0xFFB45309), onLowStock),
      _Spec('Deliveries', Icons.local_shipping_outlined, const Color(0xFF3B6D11), onPendingDeliveries),
      _Spec('Reports', Icons.bar_chart_rounded, const Color(0xFF0D9488), onReports),
      _Spec('Users', Icons.group_rounded, const Color(0xFF5D4037), onUsers),
      _Spec('Barcode', Icons.qr_code_2_rounded, const Color(0xFF455A64), onBarcode),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.95,
      children: [
        for (final a in actions) _Tile(spec: a),
      ],
    );
  }
}

class _Spec {
  const _Spec(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _Tile extends StatelessWidget {
  const _Tile({required this.spec});
  final _Spec spec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: spec.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: spec.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(spec.icon, color: spec.color, size: 26),
            const SizedBox(height: 6),
            Text(
              spec.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: spec.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
