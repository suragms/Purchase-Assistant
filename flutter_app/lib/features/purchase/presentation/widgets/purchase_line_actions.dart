import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/purchase_draft.dart';
import '../../state/purchase_draft_provider.dart';

/// Confirms and clears all purchase lines (header draft preserved).
Future<bool> confirmClearPurchaseLines(BuildContext context) async {
  final ok = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Clear all items?'),
          content: const Text(
            'Remove all items from this purchase? Header fields stay as they are.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear all'),
            ),
          ],
        ),
      ) ??
      false;
  return ok;
}

/// Clears lines after confirmation and shows acknowledgement snackbar.
Future<void> clearPurchaseLinesWithConfirm({
  required BuildContext context,
  required WidgetRef ref,
  required VoidCallback onDraftChanged,
}) async {
  final ok = await confirmClearPurchaseLines(context);
  if (!ok || !context.mounted) return;
  ref.read(purchaseDraftProvider.notifier).setLinesFromMaps([]);
  onDraftChanged();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('All items cleared'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}

/// Removes one line immediately with Undo snackbar (ERP speed — no dialog).
void removePurchaseLineWithUndo({
  required BuildContext context,
  required WidgetRef ref,
  required int index,
  required PurchaseLineDraft line,
  required VoidCallback onDraftChanged,
}) {
  ref.read(purchaseDraftProvider.notifier).removeLineAt(index);
  onDraftChanged();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Item removed'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          final current = ref.read(purchaseDraftProvider).lines;
          final restored = List<PurchaseLineDraft>.from(current);
          final at = index.clamp(0, restored.length);
          restored.insert(at, line);
          ref.read(purchaseDraftProvider.notifier).setLinesFromMaps(
                [for (final l in restored) l.toLineMap()],
              );
          onDraftChanged();
        },
      ),
    ),
  );
}
