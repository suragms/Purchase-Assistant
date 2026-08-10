import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/barcode_recent_scans.dart';

/// Recent barcode lookup chips (Wrap — no horizontal scroll for 5+ chips).
class BarcodeRecentScansChips extends StatelessWidget {
  const BarcodeRecentScansChips({
    super.key,
    required this.scans,
    required this.enabled,
    required this.onCodeSelected,
    this.maxItems = 8,
  });

  final List<BarcodeRecentScan> scans;
  final bool enabled;
  final ValueChanged<BarcodeRecentScan> onCodeSelected;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) return const SizedBox.shrink();
    final recent = scans.take(maxItems).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final r in recent)
            ActionChip(
              label: Text(
                r.name.length > 15 ? '${r.name.substring(0, 15)}…' : r.name,
                maxLines: 1,
              ),
              onPressed: enabled
                  ? () {
                      if (r.id.isNotEmpty) {
                        context.push('/catalog/item/${r.id}?source=scan');
                      } else {
                        onCodeSelected(r);
                      }
                    }
                  : null,
            ),
        ],
      ),
    );
  }
}
