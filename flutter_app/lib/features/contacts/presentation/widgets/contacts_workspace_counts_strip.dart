import 'package:flutter/material.dart';

import '../../../../core/theme/hexa_colors.dart';

/// Contacts hub workspace counts (Wrap — no horizontal scroll for 5 chips).
class ContactsWorkspaceCountsStrip extends StatelessWidget {
  const ContactsWorkspaceCountsStrip({
    super.key,
    required this.loading,
    required this.suppliers,
    required this.brokers,
    required this.categories,
    required this.typesInUse,
    required this.items,
  });

  final bool loading;
  final int suppliers;
  final int brokers;
  final int categories;
  final int typesInUse;
  final int items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget chip(String label, int n) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: HexaColors.borderSubtle),
        ),
        child: Text(
          loading ? '$label …' : '$label $n',
          style: tt.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workspace',
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              chip('Suppliers', suppliers),
              chip('Brokers', brokers),
              chip('Categories', categories),
              chip('Types in use', typesInUse),
              chip('Items', items),
            ],
          ),
        ],
      ),
    );
  }
}
