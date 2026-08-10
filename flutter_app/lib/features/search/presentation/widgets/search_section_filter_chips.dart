import 'package:flutter/material.dart';

/// Search result-section filters (Wrap — no horizontal scroll for 5+ chips).
class SearchSectionFilterChips extends StatelessWidget {
  const SearchSectionFilterChips({
    super.key,
    required this.sections,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 6),
  });

  /// `(id, label)` pairs — e.g. `('items', 'Items')` or `('items', 'Items (3)')`.
  final List<(String, String)> sections;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final e in sections)
            ChoiceChip(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              label: Text(
                e.$2,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              selected: selected == e.$1,
              onSelected: (_) => onSelected(e.$1),
            ),
        ],
      ),
    );
  }
}
