import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/stock_providers.dart';
import 'quick_stock_action_sheet.dart';
import 'widgets/stock_update_mode_toggle.dart';

/// Opens the unified stock sheet (physical count vs system ledger edit).
Future<void> showUpdateStockSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String itemId,
  required String itemName,
  Map<String, dynamic>? stockRow,
  StockUpdateMode initialMode = StockUpdateMode.physical,
}) async {
  Map<String, dynamic>? row = stockRow;
  if (row == null || row.isEmpty) {
    row = await ref.read(stockItemDetailProvider(itemId).future);
  }
  if (!context.mounted) return;
  final item = Map<String, dynamic>.from(row ?? {'id': itemId, 'name': itemName});
  if (!item.containsKey('id')) item['id'] = itemId;
  if (!item.containsKey('name')) item['name'] = itemName;

  await showQuickStockActionSheet(
    context: context,
    ref: ref,
    item: item,
    initialMode: initialMode,
  );
}
