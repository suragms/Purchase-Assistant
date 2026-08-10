import 'package:flutter/material.dart';

/// Per-category subcategory filters for staff item gallery (Wrap — no horizontal scroll).
class StaffGallerySubcategoryFilterChips extends StatelessWidget {
  const StaffGallerySubcategoryFilterChips({
    super.key,
    required this.subs,
    required this.selected,
    required this.onSelected,
  });

  final List<String> subs;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final named = subs.where((s) => s != '—').toList();
    if (named.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ChoiceChip(
            label: const Text('All', style: TextStyle(fontSize: 11)),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
            visualDensity: VisualDensity.compact,
          ),
          for (final sub in named)
            ChoiceChip(
              label: Text(sub, style: const TextStyle(fontSize: 11)),
              selected: selected == sub,
              onSelected: (_) => onSelected(sub),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
