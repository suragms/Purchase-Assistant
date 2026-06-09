import 'package:flutter/material.dart';

import '../../core/unit_engine/stock_tracking_profile.dart';
import '../../core/utils/unit_utils.dart';

/// Step 2: explicit packaging type (not auto bag from "5 KG" in name).
class PackagingTypeSelector extends StatefulWidget {
  const PackagingTypeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    this.suggestedMode,
    this.weightController,
    this.itemsPerBoxController,
    this.weightPerTinController,
    this.weightError,
    this.boxError,
    this.tinError,
    this.itemNameForAutofill,
    this.autoFilledWeight = false,
  });

  final String? selectedMode;
  final ValueChanged<String> onModeChanged;
  final String? suggestedMode;
  final TextEditingController? weightController;
  final TextEditingController? itemsPerBoxController;
  final TextEditingController? weightPerTinController;
  final String? weightError;
  final String? boxError;
  final String? tinError;
  final String? itemNameForAutofill;
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

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview(widget);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What type of stock is this?',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how this item is counted in the warehouse.',
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
                'Suggested: ${StockTrackingMode.labelForMode(widget.suggestedMode!)}',
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in modes)
              ChoiceChip(
                label: Text(StockTrackingMode.labelForMode(m)),
                selected: widget.selectedMode == m,
                onSelected: (_) {
                  widget.onModeChanged(m);
                  _autofillWeightFromName(m);
                },
              ),
          ],
        ),
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
                                  ? 'Kg per bag'
                                  : 'Kg per packet',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
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
                    ? 'Kg per bag'
                    : 'Kg per packet',
                errorText: widget.weightError,
                border: const OutlineInputBorder(),
              ),
            ),
        ],
        if (widget.selectedMode == StockTrackingMode.box) ...[
          TextField(
            controller: widget.itemsPerBoxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Pieces per box (optional)',
              errorText: widget.boxError,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        if (widget.selectedMode == StockTrackingMode.tin) ...[
          TextField(
            controller: widget.weightPerTinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litres / kg per tin (optional)',
              errorText: widget.tinError,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        if (preview != null) ...[
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

  String? _buildPreview(PackagingTypeSelector w) {
    if (w.selectedMode == null) return null;
    final unit = StockTrackingMode.catalogUnitForMode(w.selectedMode!);
    const sampleQty = 100.0;
    if (w.selectedMode == StockTrackingMode.wholesaleBag ||
        w.selectedMode == StockTrackingMode.retailPacket) {
      final kg = double.tryParse(w.weightController?.text.trim() ?? '');
      if (kg == null || kg <= 0) {
        return 'Enter weight to see total kg equivalent.';
      }
      final primary = stockDisplayPrimary(sampleQty, unit);
      final totalKg = sampleQty * kg;
      return '$primary\n(${formatStockQtyNumber(totalKg)} kg total)';
    }
    if (w.selectedMode == StockTrackingMode.looseKg) {
      return '${formatStockQtyNumber(sampleQty)} kg';
    }
    return stockDisplayPrimary(sampleQty, unit);
  }
}
