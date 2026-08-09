import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/calc_engine.dart';
import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/theme/hexa_colors.dart';
import '../../../../core/utils/unit_utils.dart';
import '../../domain/purchase_draft.dart';
import '../../state/purchase_draft_provider.dart';

/// Desktop-only (≥1024px) sticky summary sidebar for the purchase entry page.
///
/// Rendered in the right 30% of the 70/30 desktop split. Reads the existing
/// strict breakdown / quantity providers so every value matches the review step
/// and the server preview. It never writes to the payload — the only interactive
/// field (Freight) reuses the existing `setFreightText`/`setFreightType`
/// notifier, and the Confirm button invokes the wizard's `_validateAndSave`.
class PurchaseSummarySidebar extends ConsumerStatefulWidget {
  const PurchaseSummarySidebar({
    super.key,
    required this.onConfirmSave,
    required this.isSaving,
    required this.onDraftChanged,
  });

  final VoidCallback onConfirmSave;
  final bool isSaving;
  /// Wizard dirty-tracking hook — fired after freight edits so the local WIP
  /// draft stays recoverable exactly like the other header fields.
  final VoidCallback onDraftChanged;

  @override
  ConsumerState<PurchaseSummarySidebar> createState() =>
      _PurchaseSummarySidebarState();
}

class _PurchaseSummarySidebarState extends ConsumerState<PurchaseSummarySidebar> {
  final TextEditingController _freightCtrl = TextEditingController();
  final FocusNode _freightFocus = FocusNode();
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    final d = ref.read(purchaseDraftProvider);
    final f = d.freightAmount;
    _freightCtrl.text = (f != null && f > 0)
        ? f.toStringAsFixed(2)
        : '';
  }

  @override
  void dispose() {
    _freightCtrl.dispose();
    _freightFocus.dispose();
    super.dispose();
  }

  String _inr(num n, {int decimals = 0}) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: decimals)
          .format(n);

  double _lineBuyApprox(PurchaseLineDraft l) {
    final kpu = l.kgPerUnit;
    final pk = l.landingCostPerKg;
    if (kpu != null && pk != null && kpu > 0 && pk > 0) {
      return l.qty * kpu * pk;
    }
    return l.qty * l.landingCost;
  }

  TradeCalcLine _toCalc(PurchaseLineDraft l) => TradeCalcLine(
        qty: l.qty,
        landingCost: l.landingCost,
        kgPerUnit: l.kgPerUnit,
        landingCostPerKg: l.landingCostPerKg,
        taxPercent: l.taxPercent,
        discountPercent: l.lineDiscountPercent,
        freightType: l.freightType,
        freightValue: l.freightValue,
        deliveredRate: l.deliveredRate,
        billtyRate: l.billtyRate,
      );

  /// Display-only CGST/SGST/IGST split. The app only stores a single `taxTotal`
  /// (no CGST/SGST/IGST anywhere), so per-line tax is split in half —
  /// intra-state estimate. Never touches the payload.
  ({double cgst, double sgst, double igst}) _taxSplit(List<PurchaseLineDraft> lines) {
    var cgst = 0.0;
    var igst = 0.0;
    for (final l in lines) {
      final tax = lineTaxAmountDecimal(_toCalc(l)).toDouble();
      cgst += tax / 2;
      igst += 0;
    }
    return (cgst: cgst, sgst: cgst, igst: igst);
  }

  void _buildQtyBits(PurchaseQuantityTotals qt, List<String> out) {
    if (qt.totalKg > 1e-6) {
      out.add('${formatStockQtyForUnit('kg', qt.totalKg)} KG');
    }
    qt.qtyByUnit.forEach((k, v) {
      if (v > 1e-9) {
        final lk = k.trim().toLowerCase();
        if (lk == 'kg' || lk == 'kgs' || lk == 'kilogram') return;
        out.add('${formatStockQtyForUnit(k, v)} ${k.toUpperCase()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(purchaseDraftProvider);
    final bd = ref.watch(purchaseStrictBreakdownProvider);
    final qt = ref.watch(purchaseQuantityTotalsProvider);
    ref.listen(purchaseDraftProvider, (prev, next) {
      if (_freightFocus.hasFocus) return;
      final f = next.freightAmount;
      final text = (f != null && f > 0) ? f.toStringAsFixed(2) : '';
      if (_freightCtrl.text != text) {
        _freightCtrl.text = text;
      }
    });

    final unitBits = <String>[];
    _buildQtyBits(qt, unitBits);
    final qtyLine = unitBits.isEmpty ? '—' : unitBits.join(' • ');

    var estRetail = 0.0;
    var hasRetail = false;
    for (final l in draft.lines) {
      final sp = l.sellingPrice;
      if (sp == null || sp <= 0) continue;
      estRetail += sp * l.qty - _lineBuyApprox(l);
      hasRetail = true;
    }
    final split = _taxSplit(draft.lines);
    final sub = HexaDsType.overline();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Purchase summary',
              style: HexaDsType.sectionTitle(),
            ),
            const SizedBox(height: 14),
            _SummaryRow(
              label: 'Total Quantity',
              value: qtyLine,
              valueSmall: true,
            ),
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Subtotal',
              value: _inr(bd.subtotalGross),
            ),
            const SizedBox(height: 16),
            Text(
              'TAX BREAKDOWN',
              style: sub,
            ),
            const SizedBox(height: 8),
            _SummaryRow(label: 'CGST', value: _inr(split.cgst, decimals: 2)),
            const SizedBox(height: 6),
            _SummaryRow(label: 'SGST', value: _inr(split.sgst, decimals: 2)),
            const SizedBox(height: 6),
            _SummaryRow(label: 'IGST', value: _inr(split.igst, decimals: 2)),
            const SizedBox(height: 6),
            Text(
              'Intra-state estimate',
              style: TextStyle(
                fontSize: 10,
                color: HexaColors.slate400,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text('FREIGHT / EXTRA CHARGES', style: sub),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _freightCtrl,
                    focusNode: _freightFocus,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Freight amount (₹)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      ref
                          .read(purchaseDraftProvider.notifier)
                          .setFreightText(v);
                      widget.onDraftChanged();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _FreightTypeDropdown(
                    value: draft.freightType,
                    onChanged: (v) {
                      if (v == null) return;
                      ref.read(purchaseDraftProvider.notifier).setFreightType(v);
                      widget.onDraftChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: HexaColors.slateBorder),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Grand Total',
              value: _inr(bd.grand),
              bold: true,
              grand: true,
            ),
            const SizedBox(height: 12),
            if (hasRetail) ...[
              _ProfitBadge(amount: estRetail),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            MouseRegion(
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              cursor: SystemMouseCursors.click,
              child: FilledButton(
                onPressed: widget.isSaving ? null : widget.onConfirmSave,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _hover ? HexaColors.brandHover : HexaColors.brandPrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm & Save Purchase',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.grand = false,
    this.valueSmall = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool grand;
  final bool valueSmall;

  @override
  Widget build(BuildContext context) {
    final vStyle = grand
        ? const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: HexaColors.textOnLightSurface,
          )
        : TextStyle(
            fontSize: valueSmall ? 12 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: HexaColors.textOnLightSurface,
          );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: grand ? 13 : 12,
              fontWeight: grand ? FontWeight.w800 : FontWeight.w500,
              color: HexaColors.slate400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: vStyle,
          ),
        ),
      ],
    );
  }
}

class _ProfitBadge extends StatelessWidget {
  const _ProfitBadge({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final positive = amount >= 0;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: HexaDsColors.successSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 14,
              color: HexaDsColors.successForeground,
            ),
            const SizedBox(width: 6),
            Text(
              'Est. Profit ${NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: HexaDsColors.successForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FreightTypeDropdown extends StatelessWidget {
  const _FreightTypeDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isDense: true,
      decoration: const InputDecoration(
        labelText: 'Type',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'separate', child: Text('Separate')),
        DropdownMenuItem(value: 'included', child: Text('Included')),
      ],
      onChanged: onChanged,
    );
  }
}
