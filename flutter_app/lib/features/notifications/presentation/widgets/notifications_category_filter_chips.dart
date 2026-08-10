import 'package:flutter/material.dart';

import '../../../../core/providers/notifications_provider.dart'
    show NotificationCategoryFilter;
import '../../../../core/theme/hexa_colors.dart';

/// Category filters for the notifications center (Wrap — no horizontal scroll).
class NotificationsCategoryFilterChips extends StatelessWidget {
  const NotificationsCategoryFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<NotificationCategoryFilter> filters;
  final NotificationCategoryFilter selected;
  final ValueChanged<NotificationCategoryFilter> onSelected;

  static String labelFor(NotificationCategoryFilter f) => switch (f) {
        NotificationCategoryFilter.all => 'All',
        NotificationCategoryFilter.critical => 'Critical',
        NotificationCategoryFilter.warehouse => 'Warehouse',
        NotificationCategoryFilter.purchases => 'Purchases',
        NotificationCategoryFilter.staff => 'Staff',
        NotificationCategoryFilter.system => 'System',
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final f in filters)
          _FilterChip(
            label: labelFor(f),
            selected: selected == f,
            onTap: () => onSelected(f),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? HexaColors.primaryMid : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
