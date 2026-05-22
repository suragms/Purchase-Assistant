import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../quick_stock_patch_sheet.dart';
import '../stock_undo_snackbar.dart';
import '../update_stock_sheet.dart';

Future<void> showStockRowActions({
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> item,
}) async {
  final id = item['id']?.toString() ?? '';
  if (id.isEmpty) return;
  final name = item['name']?.toString() ?? 'Item';
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.flash_on_outlined),
            title: const Text('Quick add/remove'),
            onTap: () async {
              Navigator.pop(ctx);
              final saved = await showQuickStockPatchSheet(
                context: context,
                ref: ref,
                item: item,
              );
              if (saved && context.mounted) {
                showStockUndoSnackBar(
                  context: context,
                  ref: ref,
                  itemId: id,
                  itemName: name,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit stock'),
            onTap: () {
              Navigator.pop(ctx);
              showUpdateStockSheet(
                context: context,
                ref: ref,
                itemId: id,
                itemName: name,
                stockRow: item,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('View history'),
            onTap: () {
              Navigator.pop(ctx);
              context.push(
                '/stock/$id/history?name=${Uri.encodeComponent(name)}',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Print barcode'),
            onTap: () {
              Navigator.pop(ctx);
              context.push('/barcode/print/${Uri.encodeComponent(id)}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: const Text('View intelligence'),
            onTap: () {
              Navigator.pop(ctx);
              context.push('/stock/intelligence/$id');
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Movement history'),
            onTap: () {
              Navigator.pop(ctx);
              context.push(
                '/stock/$id/history?name=${Uri.encodeComponent(name)}',
              );
            },
          ),
        ],
      ),
    ),
  );
}
