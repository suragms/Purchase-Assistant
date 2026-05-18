import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/providers/catalog_providers.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/router/navigation_ext.dart';
import '../../../core/widgets/friendly_load_error.dart';
import '../../../core/widgets/list_skeleton.dart';
import 'update_stock_sheet.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  final _searchCtrl = TextEditingController();
  final _subcatCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _subcatCtrl.text = ref.read(stockListQueryProvider).subcategory;
  }

  bool _isShellStockRoot(BuildContext context) {
    final p = GoRouterState.of(context).uri.path;
    return p == '/stock' || p == '/staff/stock';
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ref.read(stockListQueryProvider.notifier).state =
          ref.read(stockListQueryProvider).copyWith(
                q: _searchCtrl.text.trim(),
                page: 1,
              );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _subcatCtrl.dispose();
    super.dispose();
  }

  String _fmtQty(dynamic v) {
    if (v == null) return '—';
    if (v is num) {
      return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
    }
    return '$v';
  }

  Color _statusColor(String st, ColorScheme cs) {
    switch (st) {
      case 'out':
        return cs.error;
      case 'critical':
        return const Color(0xFFC62828);
      case 'low':
        return const Color(0xFFE65100);
      case 'healthy':
        return const Color(0xFF2E7D32);
      default:
        return cs.onSurfaceVariant;
    }
  }

  String _statusLabel(String st) {
    switch (st) {
      case 'out':
        return 'Out';
      case 'critical':
        return 'Critical';
      case 'low':
        return 'Low';
      case 'healthy':
        return 'OK';
      default:
        return st;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = ref.watch(stockListQueryProvider);
    final listAsync = ref.watch(stockListProvider);
    final catsAsync = ref.watch(itemCategoriesListProvider);

    ref.listen<StockListQuery>(stockListQueryProvider, (prev, next) {
      if (prev?.subcategory != next.subcategory) {
        _subcatCtrl.text = next.subcategory;
      }
    });

    final shellStock = _isShellStockRoot(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !shellStock,
        leading: shellStock
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.popOrGo('/catalog'),
              ),
        title: const Text('Stock'),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/barcode/scan'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search name or item code',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final s in const [
                  ('all', 'All'),
                  ('healthy', 'OK'),
                  ('low', 'Low'),
                  ('critical', 'Critical'),
                  ('out', 'Out'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.$2),
                      selected: q.status == s.$1 && q.sort != 'recent',
                      onSelected: (_) {
                        ref.read(stockListQueryProvider.notifier).state =
                            ref.read(stockListQueryProvider).copyWith(
                                  status: s.$1,
                                  sort: 'name',
                                  page: 1,
                                );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Recent'),
                    selected: q.sort == 'recent',
                    onSelected: (_) {
                      ref.read(stockListQueryProvider.notifier).state =
                          ref.read(stockListQueryProvider).copyWith(
                                status: 'all',
                                sort: 'recent',
                                page: 1,
                              );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: q.sort,
                    decoration: const InputDecoration(
                      labelText: 'Sort',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Name A–Z')),
                      DropdownMenuItem(value: 'stock_asc', child: Text('Stock ↑')),
                      DropdownMenuItem(value: 'stock_desc', child: Text('Stock ↓')),
                      DropdownMenuItem(value: 'recent', child: Text('Recent update')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      ref.read(stockListQueryProvider.notifier).state =
                          ref.read(stockListQueryProvider).copyWith(sort: v, page: 1);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          catsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (cats) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey<String>('stock_cat_${q.category}'),
                        initialValue:
                            q.category.isEmpty ? null : q.category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All categories'),
                          ),
                          for (final c in cats)
                            DropdownMenuItem<String>(
                              value: c['name']?.toString() ?? '',
                              child: Text(c['name']?.toString() ?? ''),
                            ),
                        ],
                        onChanged: (v) {
                          ref.read(stockListQueryProvider.notifier).state =
                              ref.read(stockListQueryProvider).copyWith(
                                    category: v ?? '',
                                    subcategory: '',
                                    page: 1,
                                  );
                          _subcatCtrl.text = '';
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _subcatCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Subcategory',
                          hintText: 'Filter by type name',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (v) {
                          ref.read(stockListQueryProvider.notifier).state =
                              ref.read(stockListQueryProvider).copyWith(
                                    subcategory: v.trim(),
                                    page: 1,
                                  );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(stockListProvider);
                await ref.read(stockListProvider.future);
              },
              child: listAsync.when(
              loading: () => const ListSkeleton(),
              error: (_, __) => FriendlyLoadError(
                message: 'Could not load stock',
                onRetry: () => ref.invalidate(stockListProvider),
              ),
              data: (data) {
                final items = (data['items'] as List?) ?? const [];
                final total = (data['total'] as num?)?.toInt() ?? 0;
                final page = (data['page'] as num?)?.toInt() ?? 1;
                final perPage =
                    (data['per_page'] as num?)?.toInt() ?? q.perPage;
                final pages = (total / perPage).ceil().clamp(1, 99999);

                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No items match these filters.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final row = Map<String, dynamic>.from(
                              items[i] as Map,
                            );
                            final id = row['id']?.toString() ?? '';
                            final name = row['name']?.toString() ?? '';
                            final st =
                                row['stock_status']?.toString() ?? 'healthy';
                            final unit = row['unit']?.toString() ?? '';
                            final cur = _fmtQty(row['current_stock']);
                            final ro = _fmtQty(row['reorder_level']);
                            void openUpdate() {
                              if (id.isEmpty) return;
                              showUpdateStockSheet(
                                context: context,
                                ref: ref,
                                itemId: id,
                                itemName: name,
                                stockRow: row,
                              );
                            }

                            Widget card = Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: id.isEmpty
                                    ? null
                                    : () => context.push('/catalog/item/$id'),
                                onLongPress: id.isEmpty
                                    ? null
                                    : () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          showDragHandle: true,
                                          builder: (ctx) => SafeArea(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(Icons.inventory_2_outlined),
                                                  title: const Text('Update stock'),
                                                  onTap: () {
                                                    Navigator.pop(ctx);
                                                    openUpdate();
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.history_rounded),
                                                  title: const Text('Stock history'),
                                                  onTap: () {
                                                    Navigator.pop(ctx);
                                                    context.push(
                                                      '/stock/$id/history?name=${Uri.encodeComponent(name)}',
                                                    );
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(Icons.print_rounded),
                                                  title: const Text('Print barcode'),
                                                  onTap: () {
                                                    Navigator.pop(ctx);
                                                    context.push('/barcode/print/$id');
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(st, cs)
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _statusLabel(st),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: _statusColor(st, cs),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        [
                                          if ((row['category_name'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                            row['category_name'],
                                          if ((row['subcategory_name'] ?? '')
                                              .toString()
                                              .isNotEmpty)
                                            row['subcategory_name'],
                                        ].join(' · '),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'On hand: $cur${unit.isNotEmpty ? ' $unit' : ''} · Reorder at $ro',
                                        style: HexaDsType.purchaseQtyUnit
                                            .copyWith(fontSize: 13),
                                      ),
                                      if ((row['rack_location'] ?? '')
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Rack: ${row['rack_location']}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                            if (id.isNotEmpty) {
                              card = Dismissible(
                                key: ValueKey('stock_row_$id'),
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.inventory_2_outlined, color: cs.primary),
                                ),
                                confirmDismiss: (_) async {
                                  openUpdate();
                                  return false;
                                },
                                child: card,
                              );
                            }
                            return card;
                          },
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          children: [
                            Text(
                              'Page $page / $pages · $total items',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Previous page',
                              onPressed: page <= 1
                                  ? null
                                  : () {
                                      ref
                                          .read(
                                              stockListQueryProvider.notifier)
                                          .state = q.copyWith(page: page - 1);
                                    },
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              tooltip: 'Next page',
                              onPressed: page >= pages
                                  ? null
                                  : () {
                                      ref
                                          .read(
                                              stockListQueryProvider.notifier)
                                          .state = q.copyWith(page: page + 1);
                                    },
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }
}
