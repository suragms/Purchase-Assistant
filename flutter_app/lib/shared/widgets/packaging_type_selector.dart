import 'package:flutter/material.dart';

import '../../core/unit_engine/stock_tracking_profile.dart';
import '../../core/utils/unit_utils.dart';

/// Step 2: explicit packaging type (not auto bag from "5 KG" in name).
class PackagingTypeSelector extends StatelessWidget {
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
  });

  void _autofillWeightFromName(String mode) {
    if (weightController == null || itemNameForAutofill == null) return;
    if (mode != StockTrackingMode.wholesaleBag &&
        mode != StockTrackingMode.retailPacket) {
      return;
    }
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*KG\b', caseSensitive: false)
        .firstMatch(itemNameForAutofill!);
    if (m != null && weightController!.text.trim().isEmpty) {
      weightController!.text = m.group(1) ?? '';
    }
  }

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
    final preview = _buildPreview();
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
        if (suggestedMode != null) ...[
          const SizedBox(height: 8),
          Material(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.lightbulb_outline, size: 20),
              title: Text(
                'Suggested: ${StockTrackingMode.labelForMode(suggestedMode!)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              trailing: TextButton(
                onPressed: () {
                  onModeChanged(suggestedMode!);
                  _autofillWeightFromName(suggestedMode!);
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
                selected: selectedMode == m,
                onSelected: (_) {
                  onModeChanged(m);
                  _autofillWeightFromName(m);
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (selectedMode == StockTrackingMode.wholesaleBag ||
            selectedMode == StockTrackingMode.retailPacket) ...[
          TextField(
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: selectedMode == StockTrackingMode.wholesaleBag
                  ? 'Kg per bag'
                  : 'Kg per packet',
              errorText: weightError,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        if (selectedMode == StockTrackingMode.box) ...[
          TextField(
            controller: itemsPerBoxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Pieces per box (optional)',
              errorText: boxError,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        if (selectedMode == StockTrackingMode.tin) ...[
          TextField(
            controller: weightPerTinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Litres / kg per tin (optional)',
              errorText: tinError,
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

  String? _buildPreview() {
    if (selectedMode == null) return null;
    final unit = StockTrackingMode.catalogUnitForMode(selectedMode!);
    const sampleQty = 100.0;
    if (selectedMode == StockTrackingMode.wholesaleBag ||
        selectedMode == StockTrackingMode.retailPacket) {
      final w = double.tryParse(weightController?.text.trim() ?? '');
      if (w == null || w <= 0) {
        return 'Enter weight to see total kg equivalent.';
      }
      final primary = stockDisplayPrimary(sampleQty, unit);
      final kg = sampleQty * w;
      return '$primary\n(${formatStockQtyNumber(kg)} kg total)';
    }
    if (selectedMode == StockTrackingMode.looseKg) {
      return '${formatStockQtyNumber(sampleQty)} kg';
    }
    return stockDisplayPrimary(sampleQty, unit);
  }
}
