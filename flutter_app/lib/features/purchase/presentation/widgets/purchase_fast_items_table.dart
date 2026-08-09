import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/calc_engine.dart';
import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/theme/hexa_colors.dart';
import '../../domain/purchase_draft.dart';
import '../../state/purchase_draft_provider.dart';
import '../wizard/purchase_fast_items_step.dart' show OpenAdvancedItemSheet;

String _inr2(num n) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
        .format(n);

const Color _kDrawerBg = Color(0xFFF1F5F9); // slate-100 (reference bg)
const List<String> _kUnits = ['kg', 'bag', 'box', 'tin', 'pcs'];

TradeCalcLine _lineToCalc(PurchaseLineDraft l) => TradeCalcLine(
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

double? _parseNum(String t) {
  final v = t.trim().replaceAll(',', '');
  if (v.isEmpty) return null;
  final d = double.tryParse(v);
  if (d == null || !d.isFinite) return null;
  return d;
}

/// Desktop-only (≥1024px) inline items table for the purchase wizard.
///
/// Columns: Item Name/HSN | Qty | Unit | Purchase Rate | Selling Rate |
/// Tax Mode | Tax % | Total | Actions. Qty/Unit/Rates/Tax% are editable in
/// place; the Actions chevron opens a slate drawer with the 6 extra line
/// fields. Every edit writes back through the existing `addOrReplaceLine`
/// notifier (same wire keys as the item sheet) so totals and the payload stay
/// consistent.
class PurchaseFastItemsTable extends ConsumerStatefulWidget {
  const PurchaseFastItemsTable({
    super.key,
    required this.onDraftChanged,
    required this.openAdvancedItemEditor,
    this.lineJustAdded,
    this.onDismissLineJustAdded,
  });

  final VoidCallback onDraftChanged;
  final OpenAdvancedItemSheet openAdvancedItemEditor;
  final PurchaseLineDraft? lineJustAdded;
  final VoidCallback? onDismissLineJustAdded;

  @override
  ConsumerState<PurchaseFastItemsTable> createState() =>
      _PurchaseFastItemsTableState();
}

class _PurchaseFastItemsTableState
    extends ConsumerState<PurchaseFastItemsTable> {
  int? _expandedIndex;

  Future<void> _confirmClearAll() async {
    final ok = await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Clear all items?'),
            content: const Text('This removes every line from this purchase.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok || !mounted) return;
    ref.read(purchaseDraftProvider.notifier).setLinesFromMaps([]);
    widget.onDraftChanged();
    setState(() => _expandedIndex = null);
  }

  Future<void> _editAdvanced(int i) async {
    setState(() => _expandedIndex = null);
    await widget.openAdvancedItemEditor(editIndex: i);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(purchaseDraftProvider.select((d) => d.lines));
    final supplierId =
        ref.watch(purchaseDraftProvider.select((d) => d.supplierId));
    final blocked = supplierId == null || supplierId.isEmpty;

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
          _LineAddedBanner(
            line: widget.lineJustAdded!,
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
            TextButton(
              onPressed: blocked || lines.isEmpty ? null : _confirmClearAll,
              child: const Text('Clear all'),
            ),
          ],
        ),
        const Divider(height: 16),
        _ColumnHeaderRow(),
        const SizedBox(height: 6),
        if (lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                blocked
                    ? 'Supplier required for catalog links.'
                    : 'No items yet. Tap + Add Item below.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                _DesktopLineRow(
                  key: ValueKey('${lines[i].catalogItemId ?? ''}#$i'),
                  line: lines[i],
                  index: i,
                  expanded: _expandedIndex == i,
                  onToggle: () => setState(() {
                    _expandedIndex = _expandedIndex == i ? null : i;
                  }),
                  onEditAdvanced: () => _editAdvanced(i),
                  onDraftChanged: widget.onDraftChanged,
                ),
                const Divider(height: 1),
              ],
            ],
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: blocked ? null : () => widget.openAdvancedItemEditor(),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            label: const Text(
              '+ Add Item',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: HexaColors.brandPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColumnHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: HexaColors.slate400,
      letterSpacing: 0.2,
    );
    Widget h(String t, {int flex = 1, TextAlign align = TextAlign.left}) =>
        Expanded(
          flex: flex,
          child: Text(t, style: style, textAlign: align, maxLines: 1),
        );
    return Row(
      children: [
        h('Item Name / HSN', flex: 4),
        h('Qty', align: TextAlign.right),
        h('Unit'),
        h('Purchase Rate', flex: 2, align: TextAlign.right),
        h('Selling Rate', flex: 2, align: TextAlign.right),
        h('Tax Mode'),
        h('Tax %', align: TextAlign.right),
        h('Total', flex: 2, align: TextAlign.right),
        h('Actions', align: TextAlign.center),
      ],
    );
  }
}

class _DesktopLineRow extends ConsumerStatefulWidget {
  const _DesktopLineRow({
    super.key,
    required this.line,
    required this.index,
    required this.expanded,
    required this.onToggle,
    required this.onEditAdvanced,
    required this.onDraftChanged,
  });

  final PurchaseLineDraft line;
  final int index;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEditAdvanced;
  final VoidCallback onDraftChanged;

  @override
  ConsumerState<_DesktopLineRow> createState() => _DesktopLineRowState();
}

class _DesktopLineRowState extends ConsumerState<_DesktopLineRow> {
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _pRateCtrl = TextEditingController();
  final TextEditingController _sRateCtrl = TextEditingController();
  final TextEditingController _taxCtrl = TextEditingController();
  final TextEditingController _discCtrl = TextEditingController();
  final TextEditingController _freightCtrl = TextEditingController();
  final TextEditingController _deliveredCtrl = TextEditingController();
  final TextEditingController _billtyCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  String _unit = 'kg';
  String _freightType = 'separate';

  final FocusNode _qtyFocus = FocusNode();
  final FocusNode _pRateFocus = FocusNode();
  final FocusNode _sRateFocus = FocusNode();
  final FocusNode _taxFocus = FocusNode();
  final FocusNode _discFocus = FocusNode();
  final FocusNode _freightFocus = FocusNode();
  final FocusNode _deliveredFocus = FocusNode();
  final FocusNode _billtyFocus = FocusNode();
  final FocusNode _notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(covariant _DesktopLineRow old) {
    super.didUpdateWidget(old);
    if (old.line != widget.line && !_anyFocused()) {
      _seed();
    }
  }

  bool _anyFocused() =>
      _qtyFocus.hasFocus ||
      _pRateFocus.hasFocus ||
      _sRateFocus.hasFocus ||
      _taxFocus.hasFocus ||
      _discFocus.hasFocus ||
      _freightFocus.hasFocus ||
      _deliveredFocus.hasFocus ||
      _billtyFocus.hasFocus ||
      _notesFocus.hasFocus;

  void _seed() {
    final l = widget.line;
    _qtyCtrl.text = _fmt(l.qty);
    _pRateCtrl.text =
        l.landingCost > 0 ? l.landingCost.toStringAsFixed(2) : '';
    _sRateCtrl.text =
        (l.sellingPrice ?? 0) > 0 ? l.sellingPrice!.toStringAsFixed(2) : '';
    _taxCtrl.text =
        (l.taxPercent ?? 0) > 0 ? l.taxPercent!.toStringAsFixed(2) : '';
    _discCtrl.text = (l.lineDiscountPercent ?? 0) > 0
        ? l.lineDiscountPercent!.toStringAsFixed(2)
        : '';
    _freightCtrl.text =
        (l.freightValue ?? 0) > 0 ? l.freightValue!.toStringAsFixed(2) : '';
    _deliveredCtrl.text =
        (l.deliveredRate ?? 0) > 0 ? l.deliveredRate!.toStringAsFixed(2) : '';
    _billtyCtrl.text =
        (l.billtyRate ?? 0) > 0 ? l.billtyRate!.toStringAsFixed(2) : '';
    _notesCtrl.text = l.description ?? '';
    _unit = l.unit.trim().isNotEmpty ? l.unit : 'kg';
    _freightType = (l.freightType == 'included' || l.freightType == 'separate')
        ? l.freightType!
        : 'separate';
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(3);
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _pRateCtrl.dispose();
    _sRateCtrl.dispose();
    _taxCtrl.dispose();
    _discCtrl.dispose();
    _freightCtrl.dispose();
    _deliveredCtrl.dispose();
    _billtyCtrl.dispose();
    _notesCtrl.dispose();
    _qtyFocus.dispose();
    _pRateFocus.dispose();
    _sRateFocus.dispose();
    _taxFocus.dispose();
    _discFocus.dispose();
    _freightFocus.dispose();
    _deliveredFocus.dispose();
    _billtyFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  /// Round-trips the line through toLineMap/fromLineMap and commits through the
  /// existing notifier — same wire keys as the item sheet, so totals recompute
  /// live and the API payload shape is unchanged.
  void _applyField(String wireKey, Object? value) {
    final d = ref.read(purchaseDraftProvider);
    if (widget.index < 0 || widget.index >= d.lines.length) return;
    final m = Map<String, dynamic>.from(d.lines[widget.index].toLineMap());
    if (value == null || (value is String && value.trim().isEmpty)) {
      m.remove(wireKey);
    } else {
      m[wireKey] = value;
    }
    ref
        .read(purchaseDraftProvider.notifier)
        .addOrReplaceLine(PurchaseLineDraft.fromLineMap(m), editIndex: widget.index);
    widget.onDraftChanged();
  }

  void _applyPurchaseRate(double? rate) {
    final d = ref.read(purchaseDraftProvider);
    if (widget.index < 0 || widget.index >= d.lines.length) return;
    final line = d.lines[widget.index];
    final m = Map<String, dynamic>.from(line.toLineMap());
    if (rate == null || rate <= 0) {
      m.remove('purchase_rate');
      if (line.kgPerUnit != null && line.kgPerUnit! > 0) {
        m.remove('landing_cost_per_kg');
      }
    } else {
      m['purchase_rate'] = rate;
      final u = line.unit.trim().toLowerCase();
      final kpu = line.kgPerUnit;
      if ((u == 'bag' || u == 'sack') && kpu != null && kpu > 0) {
        m['landing_cost_per_kg'] = rate / kpu;
      }
    }
    ref
        .read(purchaseDraftProvider.notifier)
        .addOrReplaceLine(PurchaseLineDraft.fromLineMap(m), editIndex: widget.index);
    widget.onDraftChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.line;
    final li = _lineToCalc(l);
    final lineTotal = lineMoney(li) + lineItemFreightCharges(li);
    final taxMode = (l.taxPercent ?? 0) > 0 ? 'GST' : 'Nil';

    return Column(
      children: [
        InkWell(
          onTap: widget.onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: HexaColors.textOnLightSurface,
                        ),
                      ),
                      if (l.hsnCode != null && l.hsnCode!.trim().isNotEmpty)
                        Text(
                          'HSN ${l.hsnCode}',
                          style: TextStyle(
                            fontSize: 10,
                            color: HexaColors.slate400,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _EditableCell(
                    controller: _qtyCtrl,
                    focusNode: _qtyFocus,
                    onChanged: (v) => _applyField('qty', _parseNum(v)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _UnitCell(
                    value: _unit,
                    onChanged: (v) {
                      if (v == null) return;
                      _unit = v;
                      setState(() {});
                      _applyField('unit', v);
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _EditableCell(
                    controller: _pRateCtrl,
                    focusNode: _pRateFocus,
                    onChanged: (v) => _applyPurchaseRate(_parseNum(v)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _EditableCell(
                    controller: _sRateCtrl,
                    focusNode: _sRateFocus,
                    onChanged: (v) => _applyField('selling_rate', _parseNum(v)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      taxMode,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: taxMode == 'GST'
                            ? HexaDsColors.successForeground
                            : HexaColors.slate400,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _EditableCell(
                    controller: _taxCtrl,
                    focusNode: _taxFocus,
                    onChanged: (v) => _applyField('tax_percent', _parseNum(v)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _inr2(lineTotal),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: HexaColors.textOnLightSurface,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Edit item',
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        onPressed: widget.onEditAdvanced,
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: widget.expanded
                            ? 'Hide details'
                            : 'Show details',
                        icon: Icon(
                          widget.expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 20,
                          color: HexaColors.brandPrimary,
                        ),
                        onPressed: widget.onToggle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.expanded)
          _LineDrawerBar(
            discCtrl: _discCtrl,
            discFocus: _discFocus,
            freightCtrl: _freightCtrl,
            freightFocus: _freightFocus,
            deliveredCtrl: _deliveredCtrl,
            deliveredFocus: _deliveredFocus,
            billtyCtrl: _billtyCtrl,
            billtyFocus: _billtyFocus,
            notesCtrl: _notesCtrl,
            notesFocus: _notesFocus,
            freightType: _freightType,
            onFreightTypeChanged: (v) {
              if (v == null) return;
              _freightType = v;
              setState(() {});
              _applyField('freight_type', v);
            },
            onDiscChanged: (v) => _applyField('discount', _parseNum(v)),
            onFreightChanged: (v) => _applyField('freight_value', _parseNum(v)),
            onDeliveredChanged: (v) =>
                _applyField('delivered_rate', _parseNum(v)),
            onBilltyChanged: (v) => _applyField('billty_rate', _parseNum(v)),
            onNotesChanged: (v) => _applyField('description', v),
          ),
      ],
    );
  }
}

/// Dense numeric editable cell for the inline table.
class _EditableCell extends StatelessWidget {
  const _EditableCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.right,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: HexaColors.slateBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: HexaColors.slateBorder),
          ),
          hintText: '0',
          hintStyle: const TextStyle(fontSize: 12, color: HexaColors.slate400),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _UnitCell extends StatelessWidget {
  const _UnitCell({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = _kUnits.contains(value) ? _kUnits : [value, ..._kUnits];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isDense: true,
        isExpanded: true,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: HexaColors.slateBorder),
          ),
        ),
        items: [
          for (final u in items)
            DropdownMenuItem(value: u, child: Text(u)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Inline drawer beneath a row: Discount % | Freight Type | Freight Value |
/// Delivered Rate | Billty Rate | Line Notes on a slate-100 background.
class _LineDrawerBar extends StatelessWidget {
  const _LineDrawerBar({
    required this.discCtrl,
    required this.discFocus,
    required this.freightCtrl,
    required this.freightFocus,
    required this.deliveredCtrl,
    required this.deliveredFocus,
    required this.billtyCtrl,
    required this.billtyFocus,
    required this.notesCtrl,
    required this.notesFocus,
    required this.freightType,
    required this.onFreightTypeChanged,
    required this.onDiscChanged,
    required this.onFreightChanged,
    required this.onDeliveredChanged,
    required this.onBilltyChanged,
    required this.onNotesChanged,
  });

  final TextEditingController discCtrl;
  final FocusNode discFocus;
  final TextEditingController freightCtrl;
  final FocusNode freightFocus;
  final TextEditingController deliveredCtrl;
  final FocusNode deliveredFocus;
  final TextEditingController billtyCtrl;
  final FocusNode billtyFocus;
  final TextEditingController notesCtrl;
  final FocusNode notesFocus;
  final String freightType;
  final ValueChanged<String?> onFreightTypeChanged;
  final ValueChanged<String> onDiscChanged;
  final ValueChanged<String> onFreightChanged;
  final ValueChanged<String> onDeliveredChanged;
  final ValueChanged<String> onBilltyChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kDrawerBg,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Line details',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: HexaColors.slate400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DrawerField(
                  label: 'Discount %',
                  child: _EditableCell(
                    controller: discCtrl,
                    focusNode: discFocus,
                    onChanged: onDiscChanged,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DrawerField(
                  label: 'Freight Type',
                  child: DropdownButtonFormField<String>(
                    initialValue: freightType,
                    isDense: true,
                    isExpanded: true,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide:
                            const BorderSide(color: HexaColors.slateBorder),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'separate', child: Text('Separate')),
                      DropdownMenuItem(value: 'included', child: Text('Included')),
                    ],
                    onChanged: onFreightTypeChanged,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DrawerField(
                  label: 'Freight Value',
                  child: _EditableCell(
                    controller: freightCtrl,
                    focusNode: freightFocus,
                    onChanged: onFreightChanged,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DrawerField(
                  label: 'Delivered Rate',
                  child: _EditableCell(
                    controller: deliveredCtrl,
                    focusNode: deliveredFocus,
                    onChanged: onDeliveredChanged,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DrawerField(
                  label: 'Billty Rate',
                  child: _EditableCell(
                    controller: billtyCtrl,
                    focusNode: billtyFocus,
                    onChanged: onBilltyChanged,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DrawerField(
                  label: 'Line Notes',
                  child: _EditableCell(
                    controller: notesCtrl,
                    focusNode: notesFocus,
                    onChanged: onNotesChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerField extends StatelessWidget {
  const _DrawerField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: HexaColors.slate700,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _LineAddedBanner extends StatelessWidget {
  const _LineAddedBanner({required this.line, this.onDismiss});

  final PurchaseLineDraft line;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HexaDsColors.successSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: HexaDsColors.successForeground, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added ${line.itemName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: HexaDsColors.successForeground,
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
