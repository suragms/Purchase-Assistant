import 'package:flutter/material.dart';

import '../../core/unit_engine/stock_tracking_profile.dart';
import '../../core/utils/unit_utils.dart';

/// Packaging type picker for catalog create/edit.
class PackagingTypeSelector extends StatefulWidget {
  const PackagingTypeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    this.suggestedMode,
    this.weightController,
    this.weightPerTinController,
    this.weightError,
    this.tinError,
    this.itemNameForAutofill,
    this.compactLayout = false,
    this.autoFilledWeight = false,
  });

  final String? selectedMode;
  final ValueChanged<String> onModeChanged;
  final String? suggestedMode;
  final TextEditingController? weightController;
  final TextEditingController? weightPerTinController;
  final String? weightError;
  final String? tinError;
  final String? itemNameForAutofill;

  /// When true, show all unit chips in one row with short labels (kg, bag, pc, …).
  final bool compactLayout;

  /// When true and weight field has a positive value, show locked auto-detected kg UI.
  final bool autoFilledWeight;

  @override
  State<PackagingTypeSelector> createState() => _PackagingTypeSelectorState();
}

class _PackagingTypeSelectorState extends State<PackagingTypeSelector> {
  bool _weightUnlocked = false;

  @override
  void didUpdateWidget(covariant PackagingTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.autoFilledWeight && oldWidget.autoFilledWeight) {
      _weightUnlocked = false;
    }
  }

  void _autofillWeightFromName(String mode) {
    if (widget.weightController == null || widget.itemNameForAutofill == null) {
      return;
    }
    if (mode != StockTrackingMode.wholesaleBag &&
        mode != StockTrackingMode.retailPacket) {
      return;
    }
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*KG\b', caseSensitive: false)
        .firstMatch(widget.itemNameForAutofill!);
    if (m != null && widget.weightController!.text.trim().isEmpty) {
      widget.weightController!.text = m.group(1) ?? '';
    }
  }

  bool get _showLockedWeight {
    if (!widget.autoFilledWeight || _weightUnlocked) return false;
    if (widget.weightController == null) return false;
    final w = double.tryParse(widget.weightController!.text.trim());
    return w != null && w > 0;
  }

  static const modes = [
    StockTrackingMode.looseKg,
    StockTrackingMode.wholesaleBag,
    StockTrackingMode.retailPacket,
    StockTrackingMode.box,
    StockTrackingMode.tin,
    StockTrackingMode.piece,
  ];

  /// Compact create form: kg, bag, pc, box, tin (no separate retail packet chip).
  static const compactModes = [
    StockTrackingMode.looseKg,
    StockTrackingMode.wholesaleBag,
    StockTrackingMode.piece,
    StockTrackingMode.box,
    StockTrackingMode.tin,
  ];

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Unit type *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'How you count this item when buying and in stock.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        if (widget.suggestedMode != null) ...[
          const SizedBox(height: 8),
          Material(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.lightbulb_outline, size: 20),
              title: Text(
                'Suggested: ${StockTrackingMode.shortLabelForMode(widget.suggestedMode!)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              trailing: TextButton(
                onPressed: () {
                  widget.onModeChanged(widget.suggestedMode!);
                  _autofillWeightFromName(widget.suggestedMode!);
                },
                child: const Text('Use'),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        if (widget.compactLayout)
          _compactModeChips(context)
        else
          _modeChips(context, modes),
        const SizedBox(height: 12),
        if (widget.selectedMode == StockTrackingMode.wholesaleBag ||
            widget.selectedMode == StockTrackingMode.retailPacket) ...[
          if (_showLockedWeight)
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _weightUnlocked = true),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedMode ==
                                      StockTrackingMode.wholesaleBag
                                  ? 'Kg per bag *'
                                  : 'Kg per packet',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Auto-detected from name',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.weightController!.text.trim()} kg',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to edit',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            TextField(
              controller: widget.weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: widget.selectedMode == StockTrackingMode.wholesaleBag
                    ? 'Kg per bag *'
                    : 'Kg per packet (optional)',
                errorText: widget.weightError,
                border: const OutlineInputBorder(),
              ),
            ),
        ],
        if (widget.selectedMode == StockTrackingMode.tin) ...[
          TextField(
            controller: widget.weightPerTinController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litres / kg per tin (optional)',
              errorText: widget.tinError,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        if (preview != null && !widget.compactLayout) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(preview, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _compactModeChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in compactModes)
          ChoiceChip(
            label: Text(StockTrackingMode.shortLabelForMode(m)),
            selected: m == StockTrackingMode.piece
                ? StockTrackingMode.isPieceLikeMode(widget.selectedMode)
                : widget.selectedMode == m,
            onSelected: (_) {
              widget.onModeChanged(m);
              _autofillWeightFromName(m);
            },
          ),
      ],
    );
  }

  Widget _modeChips(BuildContext context, List<String> modeList) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in modeList)
          ChoiceChip(
            label: Text(StockTrackingMode.shortLabelForMode(m)),
            selected: widget.selectedMode == m,
            onSelected: (_) {
              widget.onModeChanged(m);
              _autofillWeightFromName(m);
            },
          ),
      ],
    );
  }

  String? _buildPreview() {
    if (widget.selectedMode == null) return null;
    final unit = StockTrackingMode.catalogUnitForMode(widget.selectedMode!);
    const sampleQty = 100.0;
    if (widget.selectedMode == StockTrackingMode.wholesaleBag ||
        widget.selectedMode == StockTrackingMode.retailPacket) {
      final w = double.tryParse(widget.weightController?.text.trim() ?? '');
      if (w == null || w <= 0) {
        return 'Enter weight to see total kg equivalent.';
      }
      final primary = stockDisplayPrimary(sampleQty, unit);
      final kg = sampleQty * w;
      return '$primary\n(${formatStockQtyNumber(kg)} kg total)';
    }
    if (widget.selectedMode == StockTrackingMode.looseKg) {
      return '${formatStockQtyNumber(sampleQty)} kg';
    }
    return stockDisplayPrimary(sampleQty, unit);
  }
}
