import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'stock_bulk_archive_sheet.dart';

void showStockBulkActionsSheet({
  required BuildContext context,
  required WidgetRef ref,
}) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.print_outlined),
            title: const Text('Bulk barcode print'),
            onTap: () {
              Navigator.pop(ctx);
              context.push('/barcode/bulk-print');
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Setup reorder levels'),
            onTap: () {
              Navigator.pop(ctx);
              context.push('/catalog/setup-reorder-levels');
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: const Text('Review duplicate items'),
            onTap: () {
              Navigator.pop(ctx);
              context.push('/catalog/duplicates');
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Bulk archive'),
            onTap: () {
              Navigator.pop(ctx);
              showStockBulkArchiveSheet(context: context, ref: ref);
            },
          ),
        ],
      ),
    ),
  );
}
