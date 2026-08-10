import 'package:flutter/material.dart';

import '../../../../core/theme/hexa_colors.dart';

/// Primary purchase-history filters (Wrap — no horizontal scroll for 5+ chips).
class PurchaseHistoryPrimaryFilterChips extends StatelessWidget {
  const PurchaseHistoryPrimaryFilterChips({
    super.key,
    required this.primary,
    required this.secondary,
    required this.undeliveredSort,
    required this.onSelectPrimary,
    required this.onUndeliveredSortChanged,
  });

  final String primary;
  final String? secondary;
  final bool undeliveredSort;
  final ValueChanged<String> onSelectPrimary;
  final ValueChanged<bool> onUndeliveredSortChanged;

  static const statusFilters = <(String, IconData?, String)>[
    ('all', null, 'All'),
    ('due', null, 'Due'),
    ('paid', null, 'Paid'),
    ('draft', null, 'Draft'),
    ('pending_delivery', Icons.local_shipping_outlined, 'Undelivered'),
    ('delivery_stuck', Icons.warning_amber_rounded, 'Stuck'),
    ('received', Icons.check_circle_outline_rounded, 'Done'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          FilterChip(
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            avatar: Icon(
              undeliveredSort
                  ? Icons.local_shipping_rounded
                  : Icons.local_shipping_outlined,
              size: 14,
              color: undeliveredSort
                  ? HexaColors.accentOrangeMid
                  : HexaColors.neutral,
            ),
            label: Text(
              'Wait ↑',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: undeliveredSort ? HexaColors.brandTealBright : null,
              ),
            ),
            selected: undeliveredSort,
            showCheckmark: false,
            onSelected: onUndeliveredSortChanged,
          ),
          for (final e in statusFilters)
            FilterChip(
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              avatar: e.$2 == null ? null : Icon(e.$2, size: 14),
              label: Text(
                e.$3,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              selected: secondary == null && primary == e.$1,
              onSelected: (_) => onSelectPrimary(e.$1),
            ),
        ],
      ),
    );
  }
}
