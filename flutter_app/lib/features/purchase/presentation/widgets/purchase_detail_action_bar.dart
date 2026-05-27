import 'package:flutter/material.dart';

import '../../../../core/design_system/hexa_responsive.dart';
import '../../../../core/models/trade_purchase_models.dart';

/// Bottom action bar: primary Mark as Paid + horizontal secondary actions.
class PurchaseDetailActionBar extends StatelessWidget {
  const PurchaseDetailActionBar({
    super.key,
    required this.purchase,
    required this.hideFinancials,
    required this.onMarkPaid,
    required this.onEdit,
    required this.onExportPdf,
    required this.onShare,
    required this.onPrint,
  });

  final TradePurchase purchase;
  final bool hideFinancials;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onEdit;
  final VoidCallback? onExportPdf;
  final VoidCallback? onShare;
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    if (hideFinancials) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final showMarkPaid = purchase.statusEnum != PurchaseStatus.paid &&
        purchase.statusEnum != PurchaseStatus.cancelled;

    return Material(
      elevation: 10,
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showMarkPaid) ...[
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onMarkPaid,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Mark as Paid'),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: HexaResponsive.minTouchTarget,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _actionChip(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    label: 'Export PDF',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: onExportPdf,
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    label: 'Share',
                    icon: Icons.share_outlined,
                    onPressed: onShare,
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    label: 'Print',
                    icon: Icons.print_outlined,
                    onPressed: onPrint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, HexaResponsive.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}
