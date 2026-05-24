import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'stock_compact_update_sheet.dart';

/// Backward-compatible entry for barcode scan, changes page, etc.
Future<bool> showQuickStockPatchSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> item,
}) {
  return showStockCompactUpdateSheet(
    context: context,
    ref: ref,
    item: item,
  );
}
