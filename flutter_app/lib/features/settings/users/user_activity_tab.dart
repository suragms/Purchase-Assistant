import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_facing_errors.dart';
import '../../../shared/widgets/hexa_empty_state.dart';
import 'user_activity_timeline.dart';
import 'user_profile_providers.dart';

enum UserActivitySection { feed, stock, purchases, items, ledger }

final userActivitySectionProvider =
    StateProvider<UserActivitySection>((ref) => UserActivitySection.feed);

/// Activity tab — timeline + stock / purchase / item / ledger subsections.
class UserActivityTab extends ConsumerWidget {
  const UserActivityTab({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(userActivitySectionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in UserActivitySection.values)
                  _SectionChip(
                    label: _sectionLabel(s),
                    selected: section == s,
                    onTap: () => ref
                        .read(userActivitySectionProvider.notifier)
                        .state = s,
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: switch (section) {
            UserActivitySection.feed => _FeedSection(userId: userId),
            UserActivitySection.stock => _StockSection(userId: userId),
            UserActivitySection.purchases => _PurchasesSection(userId: userId),
            UserActivitySection.items => _ItemsSection(userId: userId),
            UserActivitySection.ledger => _LedgerSection(userId: userId),
          },
        ),
      ],
    );
  }

  static String _sectionLabel(UserActivitySection s) => switch (s) {
        UserActivitySection.feed => 'All activity',
        UserActivitySection.stock => 'Stock',
        UserActivitySection.purchases => 'Purchases',
        UserActivitySection.items => 'Items',
        UserActivitySection.ledger => 'Ledger',
      };
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _FeedSection extends ConsumerWidget {
  const _FeedSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userActivityFeedProvider(userId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => UserActivitySectionLoadError(
        title: userFacingError(e),
        onRetry: () => ref.invalidate(userActivityFeedProvider(userId)),
      ),
      data: (rows) => UserActivityTimeline(
        rows: rows,
        onRefresh: () => ref.invalidate(userActivityFeedProvider(userId)),
      ),
    );
  }
}

class _StockSection extends ConsumerWidget {
  const _StockSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userStockHistoryProvider(userId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => UserActivitySectionLoadError(
        onRetry: () => ref.invalidate(userStockHistoryProvider(userId)),
      ),
      data: (rows) {
        final mapped = rows.map((r) {
          return {
            'created_at': r['created_at']?.toString(),
            'action_type': 'stock_updated',
            'item_name':
                '${r['item_name']} · ${r['old_qty']} → ${r['new_qty']}',
          };
        }).toList();
        return UserActivityTimeline(
          rows: mapped,
          emptyTitle: 'No stock activity yet',
          emptySubtitle: 'Stock changes by this user will show here.',
          onRefresh: () => ref.invalidate(userStockHistoryProvider(userId)),
        );
      },
    );
  }
}

class _PurchasesSection extends ConsumerWidget {
  const _PurchasesSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userPurchasesProvider(userId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => UserActivitySectionLoadError(
        onRetry: () => ref.invalidate(userPurchasesProvider(userId)),
      ),
      data: (rows) {
        final mapped = rows.map((p) {
          return {
            'created_at': p['purchase_date']?.toString() ??
                p['created_at']?.toString(),
            'action_type': 'purchase_created',
            'item_name':
                '${p['human_id'] ?? p['id']} · ${p['status'] ?? ''}',
          };
        }).toList();
        return UserActivityTimeline(
          rows: mapped,
          emptyTitle: 'No purchase activity yet',
          emptySubtitle: 'Purchases created by this user will show here.',
          onRefresh: () => ref.invalidate(userPurchasesProvider(userId)),
        );
      },
    );
  }
}

class _ItemsSection extends ConsumerWidget {
  const _ItemsSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userCreatedItemsProvider(userId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => UserActivitySectionLoadError(
        onRetry: () => ref.invalidate(userCreatedItemsProvider(userId)),
      ),
      data: (rows) {
        final mapped = rows.map((it) {
          return {
            'created_at': it['created_at']?.toString(),
            'action_type': 'item_created',
            'item_name': it['name']?.toString(),
          };
        }).toList();
        return UserActivityTimeline(
          rows: mapped,
          emptyTitle: 'No items created yet',
          emptySubtitle: 'Catalog items created by this user will show here.',
          onRefresh: () => ref.invalidate(userCreatedItemsProvider(userId)),
        );
      },
    );
  }
}

class _LedgerSection extends ConsumerWidget {
  const _LedgerSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userLedgerGroupedProvider(userId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => UserActivitySectionLoadError(
        onRetry: () => ref.invalidate(userLedgerGroupedProvider(userId)),
      ),
      data: (grouped) {
        final all = <Map<String, dynamic>>[];
        for (final key in ['today', 'yesterday', 'this_week']) {
          final raw = grouped[key];
          if (raw is! List) continue;
          for (final e in raw) {
            if (e is! Map) continue;
            final m = Map<String, dynamic>.from(e);
            all.add({
              'created_at': m['at']?.toString() ?? m['created_at']?.toString(),
              'action_type': m['kind']?.toString() ?? 'ledger',
              'item_name': '${m['title'] ?? ''} ${m['subtitle'] ?? ''}'.trim(),
            });
          }
        }
        return UserActivityTimeline(
          rows: all,
          emptyTitle: 'No ledger activity yet',
          emptySubtitle: 'Ledger entries linked to this user will show here.',
          onRefresh: () => ref.invalidate(userLedgerGroupedProvider(userId)),
        );
      },
    );
  }
}

/// User profile activity subsection load failure.
@visibleForTesting
class UserActivitySectionLoadError extends StatelessWidget {
  const UserActivitySectionLoadError({
    super.key,
    required this.onRetry,
    this.title = 'Unable to load data',
  });

  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.history_outlined,
      title: title,
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
