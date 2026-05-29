import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/stock_providers.dart';

/// Out-of-stock items with Buy Now CTA.
class HomeOutOfStockSection extends ConsumerWidget {
  const HomeOutOfStockSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload =
        ref.watch(stockListCacheProvider(kHomeOutOfStockListQuery)).valueOrNull;
    final raw = payload?['items'];
    final rows = raw is List
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];
    final out = rows
        .where((r) => (r['stock_status']?.toString() ?? '') == 'out')
        .take(5)
        .toList();
    if (out.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Out of stock',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        ...out.map(
          (r) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              title: Text(
                r['name']?.toString() ?? 'Item',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: FilledButton(
                onPressed: () {
                  final id = r['id']?.toString();
                  if (id != null && id.isNotEmpty) {
                    context.push('/purchase/new?catalog_item_id=$id');
                  } else {
                    context.push('/purchase/new');
                  }
                },
                child: const Text('Buy now'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
