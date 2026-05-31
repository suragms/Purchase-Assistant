import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/business_aggregates_invalidation.dart';
import '../../core/providers/business_write_event.dart';

/// Shell-level fan-out: any purchase/stock write refreshes warehouse providers app-wide.
class BusinessWriteStockListener extends ConsumerWidget {
  const BusinessWriteStockListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BusinessWriteEvent>(businessWriteEventProvider, (prev, next) {
      if (prev != null && prev.revision == next.revision) return;
      final kind = next.kind;
      if (kind == 'purchase' || kind == 'stock') {
        invalidateWarehouseSurfacesLight(ref);
        for (final id in next.affectedItemIds) {
          if (id.isEmpty) continue;
          invalidateWarehouseSurfacesLight(ref, itemId: id);
        }
      }
    });
    return child;
  }
}
