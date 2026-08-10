import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/design_system/hexa_operational_tokens.dart';
import '../../../core/providers/catalog_providers.dart';
import '../../../core/router/navigation_ext.dart';
import '../../../core/router/post_auth_route.dart';
import '../../../core/widgets/list_skeleton.dart';
import '../../../shared/widgets/hexa_empty_state.dart';
import '../catalog_taxonomy_utils.dart';
import 'widgets/quick_catalog_taxonomy_sheet.dart';

/// Staff + owner hub: browse categories → subcategories without deep nav first.
class CatalogTaxonomyHubPage extends ConsumerStatefulWidget {
  const CatalogTaxonomyHubPage({super.key});

  @override
  ConsumerState<CatalogTaxonomyHubPage> createState() =>
      _CatalogTaxonomyHubPageState();
}

class _CatalogTaxonomyHubPageState extends ConsumerState<CatalogTaxonomyHubPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCategorySheet() async {
    final r = await showQuickCatalogTaxonomySheet(
      context,
      mode: QuickCatalogTaxonomyMode.categoryAndOptionalSub,
    );
    if (r != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            r.typeName != null
                ? 'Created ${r.categoryName} · ${r.typeName}'
                : 'Created ${r.categoryName}',
          ),
        ),
      );
    }
  }

  Future<void> _openSubcategorySheet({String? categoryId}) async {
    final r = await showQuickCatalogTaxonomySheet(
      context,
      mode: QuickCatalogTaxonomyMode.subcategoryOnly,
      preselectedCategoryId: categoryId,
    );
    if (r != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subcategory ${r.typeName ?? ''} added')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isStaff = session != null && sessionIsStaff(session);
    final catsAsync = ref.watch(itemCategoriesListProvider);
    final indexAsync = ref.watch(categoryTypesIndexProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.popOrGo(isStaff ? '/staff/home' : '/home'),
        ),
        title: const Text('Categories'),
        actions: [
          if (!isStaff)
            IconButton(
              tooltip: 'Full catalog',
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: () => context.push('/catalog'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              HexaOp.pageGutter,
              4,
              HexaOp.pageGutter,
              0,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: Text(
                'How categories work',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              children: [
                Text(
                  'Categories group your items. Expand a row to see subcategories '
                  '(types), e.g. Rice → Biriyani rice. Use + on a row to add a subcategory.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HexaOp.pageGutter),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search categories',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: catsAsync.when(
              loading: () => const ListSkeleton(),
              error: (_, __) => CatalogTaxonomyHubLoadError(
                onRetry: () {
                  invalidateCatalogTaxonomy(ref);
                },
              ),
              data: (cats) {
                final index = indexAsync.valueOrNull ?? [];

                var list = cats;
                if (_query.isNotEmpty) {
                  list = cats
                      .where((c) =>
                          (c['name']?.toString().toLowerCase() ?? '')
                              .contains(_query))
                      .toList();
                }

                if (list.isEmpty) {
                  return HexaEmptyState(
                    icon: Icons.category_outlined,
                    title: _query.isEmpty
                        ? 'No categories yet'
                        : 'No matches',
                    subtitle: 'Tap + to add your first category.',
                    primaryActionLabel: 'Add category',
                    onPrimaryAction: _openCategorySheet,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    invalidateCatalogTaxonomy(ref);
                    await ref.read(itemCategoriesListProvider.future);
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      HexaOp.pageGutter,
                      4,
                      HexaOp.pageGutter,
                      MediaQuery.paddingOf(context).bottom + 88,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final c = list[i];
                      final id = c['id']?.toString() ?? '';
                      final name = c['name']?.toString() ?? '—';
                      final types = id.isEmpty
                          ? const <Map<String, dynamic>>[]
                          : typesForCategory(index, id);
                      final subN = types.length;
                      return CatalogTaxonomyCategoryTile(
                        categoryId: id,
                        categoryName: name,
                        types: types,
                        subcategoryCount: subN,
                        showOpenDetail: !isStaff,
                        onAddSubcategory: id.isEmpty
                            ? null
                            : () => _openSubcategorySheet(categoryId: id),
                        onOpenDetail: !isStaff && id.isNotEmpty
                            ? () => context.push('/catalog/category/$id')
                            : null,
                        onOpenType: (typeId) {
                          if (id.isEmpty || typeId.isEmpty) return;
                          context.push('/catalog/category/$id/type/$typeId');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add category',
        onPressed: _openCategorySheet,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

/// Expandable category row with inline subcategory (type) children.
class CatalogTaxonomyCategoryTile extends StatelessWidget {
  const CatalogTaxonomyCategoryTile({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.types,
    required this.subcategoryCount,
    required this.showOpenDetail,
    this.onAddSubcategory,
    this.onOpenDetail,
    required this.onOpenType,
  });

  final String categoryId;
  final String categoryName;
  final List<Map<String, dynamic>> types;
  final int subcategoryCount;
  final bool showOpenDetail;
  final VoidCallback? onAddSubcategory;
  final VoidCallback? onOpenDetail;
  final ValueChanged<String> onOpenType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExpansionTile(
      key: ValueKey('taxonomy-cat-$categoryId'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        child: Icon(
          Icons.folder_outlined,
          color: scheme.primary,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subcategoryCount == 0
                      ? 'No subcategories · General created automatically'
                      : '$subcategoryCount subcategories',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Add subcategory',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: onAddSubcategory,
          ),
          if (showOpenDetail)
            IconButton(
              tooltip: 'Open category',
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onPressed: onOpenDetail,
            ),
        ],
      ),
      children: [
        if (types.isEmpty)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 56, right: 8),
            dense: true,
            title: Text(
              'No subcategories yet',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            trailing: TextButton(
              onPressed: onAddSubcategory,
              child: const Text('Add'),
            ),
          )
        else
          for (final t in types)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 56, right: 8),
              dense: true,
              leading: Icon(
                Icons.subdirectory_arrow_right_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              title: Text(
                t['name']?.toString() ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () {
                final typeId = t['id']?.toString() ?? '';
                onOpenType(typeId);
              },
            ),
      ],
    );
  }
}

/// Catalog taxonomy hub categories load failure (UX-141).
@visibleForTesting
class CatalogTaxonomyHubLoadError extends StatelessWidget {
  const CatalogTaxonomyHubLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.category_outlined,
      title: 'Could not load categories',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
