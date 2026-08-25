import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/hexa_colors.dart';
import '../../../../core/units/dynamic_unit_label_engine.dart' as unit_lbl;
import '../../../../core/utils/trade_purchase_rate_display.dart';
import '../../../../core/utils/unit_utils.dart';
import '../../domain/purchase_draft.dart';
import '../../mapping/purchase_line_display_adapter.dart';
import '../../state/purchase_draft_provider.dart';
import '../../state/purchase_trade_preview_provider.dart';

import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../widgets/purchase_line_actions.dart';
import '../../../../shared/widgets/hexa_empty_state.dart';

String _inr0(num n) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(n);

typedef OpenAdvancedItemSheet = Future<void> Function({
  int? editIndex,
  Map<String, dynamic>? initialOverride,
});

/// Items step — expanded list + sticky [+ Add Item] (Part 2).
class PurchaseFastItemsStep extends ConsumerStatefulWidget {
  const PurchaseFastItemsStep({
    super.key,
    required this.listScrollController,
    required this.onDraftChanged,
    required this.openAdvancedItemEditor,
    this.lineJustAdded,
    this.onDismissLineJustAdded,
  });

  final ScrollController listScrollController;
  final VoidCallback onDraftChanged;
  final OpenAdvancedItemSheet openAdvancedItemEditor;
  final PurchaseLineDraft? lineJustAdded;
  final VoidCallback? onDismissLineJustAdded;

  @override
  ConsumerState<PurchaseFastItemsStep> createState() =>
      _PurchaseFastItemsStepState();
}

class _PurchaseFastItemsStepState extends ConsumerState<PurchaseFastItemsStep> {
  void _removeAt(int i) {
    final line = ref.read(purchaseDraftProvider).lines[i];
    removePurchaseLineWithUndo(
      context: context,
      ref: ref,
      index: i,
      line: line,
      onDraftChanged: widget.onDraftChanged,
    );
    setState(() {});
  }

  Future<void> _confirmClearAll() async {
    await clearPurchaseLinesWithConfirm(
      context: context,
      ref: ref,
      onDraftChanged: () {
        widget.onDraftChanged();
        setState(() {});
      },
    );
  }

  String _qtyHuman(PurchaseLineDraft l) {
    final u = l.unit.trim();
    final q = formatStockQtyForUnit(u, l.qty);
    final ul = u.toLowerCase();
    if (l.kgPerUnit != null &&
        l.kgPerUnit! > 0 &&
        (ul == 'bag' || ul == 'sack')) {
      final kg = l.qty * l.kgPerUnit!;
      return '$q $u • ${formatStockQtyForUnit('kg', kg)} kg';
    }
    return '$q $u';
  }

  String _pRateQuick(PurchaseLineDraft l, Map<String, dynamic>? rateContext) {
    final tl = tradeLineForDisplay(l, rateContext: rateContext);
    final r = tradePurchaseLineDisplayPurchaseRate(tl);
    final d = unit_lbl.purchaseRateSuffix(tl);
    return 'P ₹${r.toStringAsFixed(1)}/$d';
  }

  Future<void> _editAdvanced(int i) async {
    await widget.openAdvancedItemEditor(editIndex: i);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lines =
        ref.watch(purchaseDraftProvider.select((d) => d.lines));
    final supplierId =
        ref.watch(purchaseDraftProvider.select((d) => d.supplierId));
    final blocked = supplierId == null || supplierId.isEmpty;
    final preview = ref.watch(tradePurchasePreviewProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (blocked)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Pick a supplier on the Party step to add catalog lines.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade900,
                fontSize: 13,
              ),
            ),
          ),
        if (widget.lineJustAdded != null) ...[
          _PurchaseLineAddedPreviewCard(
            line: widget.lineJustAdded!,
            qtyLabel: _qtyHuman(widget.lineJustAdded!),
            amountLabel: _inr0(widget.lineJustAdded!.landingApprox),
            onDismiss: widget.onDismissLineJustAdded,
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Text(
              'Items (${lines.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: HexaColors.textOnLightSurface,
                  ),
            ),
            const Spacer(),
            if (lines.isNotEmpty)
              TextButton(
                onPressed: blocked ? null : _confirmClearAll,
                child: const Text('Clear all'),
              ),
          ],
        ),
        const Divider(height: 16),
        Expanded(
          child: lines.isEmpty
              ? PurchaseFastItemsEmpty(
                  blocked: blocked,
                  onAddItem: () => widget.openAdvancedItemEditor(),
                )
              : ListView.separated(
                  controller: widget.listScrollController,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final ln = lines[i];
                    final rc = tradePreviewLineRateContext(preview, i);
                    final buy = ln.landingApprox;
                    final tax = ln.taxPercent ?? 0;
                    return Material(
                      color: Colors.white,
                      elevation: 0,
                      shape: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () => _editAdvanced(i),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 10, 0, 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ln.itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: HexaColors.textOnLightSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_qtyHuman(ln)}  ·  ${_pRateQuick(ln, rc)}'
                                      '${tax > 0 ? '  ·  GST ${tax.toStringAsFixed(tax == tax.roundToDouble() ? 0 : 1)}%' : ''}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: HexaColors.slate400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _inr0(buy),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: HexaColors.textOnLightSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                                onPressed: () => _removeAt(i),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed:
                  blocked ? null : () => widget.openAdvancedItemEditor(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                '+ Add item',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Consumer(
          builder: (cx, rf, _) {
            final bd = rf.watch(purchaseStrictBreakdownProvider);
            final qt = rf.watch(purchaseQuantityTotalsProvider);
            final unitBits = <String>[];
            if (qt.totalKg > 1e-6) {
              unitBits.add('${formatStockQtyForUnit('kg', qt.totalKg)} KG');
            }
            qt.qtyByUnit.forEach((k, v) {
              if (v > 1e-9) {
                final lk = k.trim().toLowerCase();
                if (lk == 'kg' || lk == 'kgs' || lk == 'kilogram') {
                  return;
                }
                unitBits.add(
                  '${formatStockQtyForUnit(k, v)} ${k.toUpperCase()}',
                );
              }
            });
            final qtyLine = unitBits.isEmpty ? '—' : unitBits.join(' • ');
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MobileSummaryRow(label: 'Qty', value: qtyLine),
                  _MobileSummaryRow(
                    label: 'Subtotal',
                    value: _inr0(bd.subtotalGross),
                  ),
                  _MobileSummaryRow(
                    label: 'Tax',
                    value: _inr0(bd.taxTotal),
                  ),
                  _MobileSummaryRow(
                    label: 'Charges',
                    value: _inr0(bd.freight + bd.commission),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text(
                        'GRAND TOTAL',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: HexaColors.slate400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _inr0(bd.grand),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: HexaColors.textOnLightSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MobileSummaryRow extends StatelessWidget {
  const _MobileSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: HexaColors.slate400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: HexaColors.textOnLightSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty list chrome for purchase fast-items (mobile step + desktop table).
class PurchaseFastItemsEmpty extends StatelessWidget {
  const PurchaseFastItemsEmpty({
    super.key,
    required this.blocked,
    required this.onAddItem,
    this.compact = false,
  });

  final bool blocked;
  final VoidCallback onAddItem;

  /// Dense ERP empty row (desktop/tablet table) — no giant icon chrome.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (blocked) {
      if (compact) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Pick a supplier first so catalog links and rates work.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade900,
              fontSize: 13,
            ),
          ),
        );
      }
      return const HexaEmptyState(
        icon: Icons.storefront_outlined,
        title: 'Supplier required',
        subtitle: 'Pick a supplier first so catalog links and rates work.',
      );
    }
    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No items added yet.',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: HexaColors.textOnLightSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your first purchase line.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HexaColors.slate400,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Add item',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return HexaEmptyState(
      icon: Icons.add_shopping_cart_outlined,
      title: 'No items yet',
      subtitle: 'Add a line to build this purchase.',
      primaryActionLabel: 'Add item',
      onPrimaryAction: onAddItem,
    );
  }
}

class _PurchaseLineAddedPreviewCard extends StatelessWidget {
  const _PurchaseLineAddedPreviewCard({
    required this.line,
    required this.qtyLabel,
    required this.amountLabel,
    this.onDismiss,
  });

  final PurchaseLineDraft line;
  final String qtyLabel;
  final String amountLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: HexaDsColors.successSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_rounded, color: cs.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Added · ${line.itemName}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: HexaColors.textOnLightSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$qtyLabel · $amountLabel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: HexaColors.brandTealBright,
                        ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                tooltip: 'Dismiss',
                visualDensity: VisualDensity.compact,
                onPressed: onDismiss,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
