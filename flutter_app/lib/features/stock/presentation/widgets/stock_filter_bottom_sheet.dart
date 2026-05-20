import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/stock_providers.dart';
import '../../../../core/providers/suppliers_list_provider.dart';
import '../../../../core/providers/catalog_providers.dart';

/// Bottom sheet for stock list filters (status, sort, category, supplier, subcategory).
Future<void> showStockFilterBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required StockListQuery initial,
  required TextEditingController subcategoryCtrl,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return _StockFilterSheetBody(
        initial: initial,
        subcategoryCtrl: subcategoryCtrl,
      );
    },
  );
}

class _StockFilterSheetBody extends ConsumerStatefulWidget {
  const _StockFilterSheetBody({
    required this.initial,
    required this.subcategoryCtrl,
  });

  final StockListQuery initial;
  final TextEditingController subcategoryCtrl;

  @override
  ConsumerState<_StockFilterSheetBody> createState() =>
      _StockFilterSheetBodyState();
}

class _StockFilterSheetBodyState extends ConsumerState<_StockFilterSheetBody> {
  late String _status;
  late String _sort;
  late String _category;
  late String _supplier;
  late final TextEditingController _subcatField;
  final _supplierSearch = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.initial.status;
    _sort = widget.initial.sort;
    _category = widget.initial.category;
    _supplier = widget.initial.supplier;
    _subcatField = TextEditingController(text: widget.initial.subcategory);
  }

  @override
  void dispose() {
    _subcatField.dispose();
    _supplierSearch.dispose();
    super.dispose();
  }

  void _apply() {
    ref.read(stockListQueryProvider.notifier).state = widget.initial.copyWith(
          status: _status,
          sort: _sort,
          category: _category,
          supplier: _supplier,
          subcategory: _subcatField.text.trim(),
          page: 1,
        );
    widget.subcategoryCtrl.text = _subcatField.text.trim();
    Navigator.pop(context);
  }

  void _clear() {
    ref.read(stockListQueryProvider.notifier).state = const StockListQuery();
    widget.subcategoryCtrl.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final catsAsync = ref.watch(itemCategoriesListProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final supplierQuery = _supplierSearch.text.trim().toLowerCase();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Filter stock',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Text('Status', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in [
                    ('all', 'All'),
                    ('low', 'Low'),
                    ('critical', 'Critical'),
                    ('out', 'Out'),
                  ])
                    FilterChip(
                      label: Text(e.$2),
                      selected: _status == e.$1,
                      onSelected: (_) => setState(() => _status = e.$1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Sort', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in [
                    ('name', 'Name A–Z'),
                    ('stock_asc', 'Stock ↑'),
                    ('stock_desc', 'Stock ↓'),
                    ('recent', 'Recent'),
                  ])
                    FilterChip(
                      label: Text(e.$2),
                      selected: _sort == e.$1,
                      onSelected: (_) => setState(() => _sort = e.$1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              catsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (cats) {
                  final names = [
                    for (final c in cats)
                      if ((c['name'] ?? '').toString().trim().isNotEmpty)
                        c['name'].toString().trim(),
                  ];
                  if (names.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Category',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _category.isEmpty,
                            onSelected: (_) =>
                                setState(() => _category = ''),
                          ),
                          for (final n in names)
                            FilterChip(
                              label: Text(n),
                              selected: _category == n,
                              onSelected: (_) =>
                                  setState(() => _category = n),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              Text('Supplier',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _supplierSearch,
                decoration: const InputDecoration(
                  hintText: 'Search supplier',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              suppliersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (rows) {
                  final names = [
                    for (final s in rows)
                      if ((s['name'] ?? '').toString().trim().isNotEmpty)
                        s['name'].toString().trim(),
                  ]..sort();
                  final filtered = supplierQuery.isEmpty
                      ? names
                      : names
                          .where((n) => n.toLowerCase().contains(supplierQuery))
                          .toList();
                  return SizedBox(
                    height: 200,
                    child: ListView(
                      children: [
                        ListTile(
                          dense: true,
                          title: const Text('All suppliers'),
                          selected: _supplier.isEmpty,
                          onTap: () => setState(() => _supplier = ''),
                        ),
                        for (final n in filtered.take(80))
                          ListTile(
                            dense: true,
                            title: Text(n,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            selected: _supplier == n,
                            onTap: () => setState(() => _supplier = n),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subcatField,
                decoration: const InputDecoration(
                  labelText: 'Subcategory',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _apply,
                child: const Text('Apply filters'),
              ),
              TextButton(
                onPressed: _clear,
                child: const Text('Clear all'),
              ),
            ],
          ),
        );
      },
    );
  }
}

bool stockHasActiveFilters(StockListQuery q) =>
    q.category.isNotEmpty ||
    q.supplier.isNotEmpty ||
    q.subcategory.isNotEmpty ||
    q.sort != 'name' ||
    q.status != 'all';

String stockActiveFilterSummary(StockListQuery q) {
  final parts = <String>[];
  if (q.category.isNotEmpty) parts.add(q.category);
  if (q.supplier.isNotEmpty) parts.add(q.supplier);
  if (q.subcategory.isNotEmpty) parts.add(q.subcategory);
  if (q.sort == 'recent') parts.add('Recent');
  if (q.status != 'all') parts.add(q.status);
  return parts.join(' · ');
}
