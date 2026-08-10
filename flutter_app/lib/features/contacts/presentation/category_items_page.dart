import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/navigation/open_trade_item_from_report.dart';
import '../../../core/router/navigation_ext.dart';
import '../../../core/providers/contacts_hub_provider.dart';
import '../../../shared/widgets/hexa_empty_state.dart';

final contactsCategoryItemsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, category) async {
  ref.keepAlive();
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  final api = ref.read(hexaApiProvider);
  final r = contactsDefaultRange();
  return api.categoryItems(
    businessId: session.primaryBusiness.id,
    category: category,
    from: r.from,
    to: r.to,
  );
});

class CategoryItemsPage extends ConsumerWidget {
  const CategoryItemsPage({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(contactsCategoryItemsProvider(category));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.popOrGo('/contacts')),
        title: Text(category),
      ),
      body: async.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => CategoryItemsLoadError(
          onRetry: () =>
              ref.invalidate(contactsCategoryItemsProvider(category)),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return HexaEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No line items in this period',
              subtitle:
                  'No purchase lines in this category for the last $contactsLookbackDays days.',
              primaryActionLabel: 'Back to Contacts',
              onPrimaryAction: () => context.popOrGo('/contacts'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final row = rows[i];
              final name = row['item_name']?.toString() ?? '—';
              final profit = (row['total_profit'] as num?)?.toDouble() ?? 0;
              final qty = (row['total_qty'] as num?)?.toDouble() ?? 0;
              final lines = (row['line_count'] as num?)?.toInt() ?? 0;
              return Card(
                child: ListTile(
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      'Lines: $lines · Qty: ${qty.toStringAsFixed(2)} · Profit: ${profit.toStringAsFixed(0)}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => unawaited(
                    openTradeItemFromReportRow(context, ref, row),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Category items page load failure.
@visibleForTesting
class CategoryItemsLoadError extends StatelessWidget {
  const CategoryItemsLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Could not load category items',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
