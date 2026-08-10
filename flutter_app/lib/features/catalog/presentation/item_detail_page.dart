import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/hexa_responsive.dart';
import '../../../core/design_system/widgets/app_button.dart';
import '../../../core/providers/business_write_event.dart';
import '../../../core/providers/deferred_invalidation.dart';
import '../../../core/providers/item_detail_providers.dart';
import '../../../core/providers/stock_list_exceptions.dart';
import '../../../core/providers/stock_providers.dart'
    show
        stockItemActivityProvider,
        stockItemAuditProvider,
        stockItemDetailProvider;
import '../../../core/providers/trade_purchases_provider.dart'
    show tradePurchasesForItemProvider;
import '../../../core/theme/hexa_colors.dart';
import '../../../core/widgets/friendly_load_error.dart'
    show GroupedSectionErrorCard;
import '../../../core/auth/session_notifier.dart' show sessionProvider;
import '../../../core/router/post_auth_route.dart' show sessionIsStaff;
import '../../../shared/widgets/hexa_empty_state.dart';
import '../../stock/presentation/stock_quick_purchase_sheet.dart';
import '../../stock/presentation/update_stock_sheet.dart';
import '../../stock/presentation/widgets/stock_update_mode_toggle.dart';
import 'item_detail_tab_matrix.dart';
import 'widgets/item_detail_header.dart';
import 'widgets/item_quick_actions_bar.dart';
import 'widgets/item_analytics_section.dart';
import 'widgets/item_ledger_section.dart';
import 'widgets/item_physical_verification_card.dart';
import 'widgets/item_purchase_history_section.dart';
import 'widgets/item_supplier_intelligence_section.dart';
import 'widgets/item_stock_snapshot_card.dart';
import 'widgets/item_timeline_section.dart';
import '../../stock/presentation/widgets/stock_item_history_panel.dart';

class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BusinessWriteEvent>(businessWriteEventProvider, (prev, next) {
      if (next.revision <= (prev?.revision ?? -1)) return;
      if (next.kind == 'stock_patch') return;
      final purchaseOrStock =
          next.kind == 'purchase' || next.kind == 'stock';
      if (purchaseOrStock &&
          (next.affectsItem(itemId) || next.isGlobal)) {
        deferInvalidateDelayed(ref, itemDetailBundleProvider(itemId));
        if (next.kind == 'purchase') {
          deferInvalidateDelayed(ref, tradePurchasesForItemProvider(itemId));
        }
      }
    });

    ref.watch(itemDetailBundleProvider(itemId));
    final bundleAsync = ref.watch(itemDetailBundleProvider(itemId));
    final catalog = ref.watch(itemDetailCatalogProvider(itemId)) ??
        const <String, dynamic>{};
    final stock = ref.watch(itemDetailStockProvider(itemId)) ??
        const <String, dynamic>{};
    final hasAnyData = catalog.isNotEmpty || stock.isNotEmpty;
    final gutter = HexaResponsive.pageGutter(context, operational: true);
    final desktop = HexaBreakpoints.isDesktop(context);

    Future<void> doRefresh() async {
      ref.invalidate(itemDetailBundleProvider(itemId));
      await ref.read(itemDetailBundleProvider(itemId).future).then((_) {});
    }

    Widget buildDetail({
      required Map<String, dynamic> item,
      required Map<String, dynamic> stockRow,
    }) {
      final name = (item['name']?.toString() ?? '').trim();
      final code = (item['item_code']?.toString() ?? '').trim();
      final cat = (stockRow['category_name']?.toString() ??
              item['category_name']?.toString() ??
              '')
          .trim();
      final sub = (stockRow['subcategory_name']?.toString() ??
              item['type_name']?.toString() ??
              '')
          .trim();
      final categoryLabel = [cat, sub].where((s) => s.isNotEmpty).join(' · ');

      final Widget scrollBody;
      if (desktop) {
        // Desktop: NEVER wrap Column+Expanded/TabBarView in SingleChildScrollView —
        // unbounded height blanks the whole item page (and View Item Activity) on web.
        scrollBody = LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;
            return SizedBox(
              height: h,
              child: Padding(
                padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 16),
                child: HexaResponsiveCenter(
                  maxWidth: HexaResponsive.maxContentWidth,
                  padding: EdgeInsets.zero,
                  child: _DesktopItemLayout(
                    itemId: itemId,
                    name: name.isNotEmpty
                        ? name
                        : (code.isNotEmpty ? code : 'Item'),
                    code: code.isNotEmpty ? code : null,
                    categoryLabel: categoryLabel,
                    onRefresh: doRefresh,
                    onMore: () => _showMore(context, ref, item),
                  ),
                ),
              ),
            );
          },
        );
      } else {
        scrollBody = _ItemDetailMobileScroll(
          itemId: itemId,
          name: name.isNotEmpty ? name : (code.isNotEmpty ? code : 'Item'),
          code: code.isNotEmpty ? code : null,
          categoryLabel: categoryLabel,
          gutter: gutter,
          onRefresh: doRefresh,
          onMore: () => _showMore(context, ref, item),
        );
      }

      Widget content = SizedBox.expand(child: scrollBody);
      return content;
    }

    final itemName = (catalog['name']?.toString() ?? '').trim();

    if (!hasAnyData &&
        bundleAsync.isLoading &&
        !bundleAsync.hasError) {
      return const Scaffold(
        backgroundColor: HexaColors.brandBackground,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (!hasAnyData && bundleAsync.hasError) {
      return Scaffold(
        backgroundColor: HexaColors.brandBackground,
        body: SafeArea(
          child: ItemDetailLoadError(
            onRetry: () {
              ref.invalidate(itemDetailBundleProvider(itemId));
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: HexaColors.brandBackground,
      body: SafeArea(
        child: buildDetail(item: catalog, stockRow: stock),
      ),
      bottomNavigationBar: hasAnyData && !desktop
          ? _ItemStickyActions(
              itemId: itemId,
              itemName: itemName.isNotEmpty
                  ? itemName
                  : (catalog['item_code']?.toString() ?? '').trim(),
            )
          : null,
    );
  }

  Future<void> _showMore(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item,
  ) async {
    final itemName = (item['name']?.toString() ?? 'Item').trim();
    final v = await showHexaBottomSheet<String>(
      context: context,
      compact: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Ledger & statement'),
            onTap: () => Navigator.pop(context, 'ledger'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('Purchase history'),
            onTap: () => Navigator.pop(context, 'history'),
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Activity'),
            onTap: () => Navigator.pop(context, 'activity'),
          ),
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: const Text('Copy item name'),
            subtitle: Text(itemName),
            onTap: () => Navigator.pop(context, 'copy'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    switch (v) {
      case 'ledger':
        context.push('/catalog/item/$itemId/ledger');
      case 'history':
        context.push('/catalog/item/$itemId/purchase-history');
      case 'activity':
        // Deep-link Activity tab (desktop + mobile item detail).
        context.push('/catalog/item/$itemId?tab=activity');
      case 'copy':
        await Clipboard.setData(ClipboardData(text: itemName));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied')),
        );
    }
  }
}

class _ItemStickyActions extends ConsumerWidget {
  const _ItemStickyActions({required this.itemId, required this.itemName});

  final String itemId;
  final String itemName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session == null) return const SizedBox.shrink();
    final isStaff = sessionIsStaff(session);
    final name = itemName.trim().isNotEmpty ? itemName.trim() : 'Item';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: HexaColors.slateBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppPrimaryButton(
                label: 'Physical',
                onPressed: () async {
                  final row = ref.read(itemDetailStockProvider(itemId));
                  if (!context.mounted) return;
                  await showUpdateStockSheet(
                    context: context,
                    ref: ref,
                    itemId: itemId,
                    itemName: name,
                    stockRow: row == null || row.isEmpty ? null : row,
                    initialMode: StockUpdateMode.physical,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppSecondaryButton(
                dense: true,
                label: 'System',
                onPressed: () async {
                  final row = ref.read(itemDetailStockProvider(itemId));
                  if (!context.mounted) return;
                  await showUpdateStockSheet(
                    context: context,
                    ref: ref,
                    itemId: itemId,
                    itemName: name,
                    stockRow: row == null || row.isEmpty ? null : row,
                    initialMode: StockUpdateMode.system,
                  );
                },
              ),
            ),
            if (!isStaff) ...[
              const SizedBox(width: 8),
              Expanded(
                child: AppSecondaryButton(
                  dense: true,
                  label: 'Add qty',
                  onPressed: () async {
                    final item = ref.read(itemDetailStockProvider(itemId));
                    if (!context.mounted) return;
                    if (item == null || item.isEmpty) return;
                    await showStockQuickPurchaseSheet(
                      context: context,
                      ref: ref,
                      item: item,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopItemLayout extends ConsumerWidget {
  const _DesktopItemLayout({
    required this.itemId,
    required this.name,
    required this.code,
    required this.categoryLabel,
    required this.onMore,
    required this.onRefresh,
  });

  final String itemId;
  final String name;
  final String? code;
  final String categoryLabel;
  final VoidCallback onMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final isStaff = session != null && sessionIsStaff(session);
    final tabs = itemDetailTabsForRole(isStaff: isStaff);
    final tabQuery = _ItemDetailMobileScrollState._tabQuery(context);
    final initialIndex = itemDetailInitialTabIndex(
      tabQuery,
      isStaff: isStaff,
    ).clamp(0, tabs.length - 1);

    Widget overviewBody() {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItemPhysicalVerificationCard(itemId: itemId),
              if (!isStaff) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ItemAnalyticsSection(
                      itemId: itemId,
                      loadIntelligence: true,
                      suppressInlineError: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget purchasesBody() {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ItemLedgerSection(itemId: itemId),
              const SizedBox(height: 8),
              ItemPurchaseHistorySection(
                itemId: itemId,
                itemName: name,
              ),
              const SizedBox(height: 8),
              ItemSupplierIntelligenceSection(
                itemId: itemId,
                itemName: name,
                suppressInlineError: true,
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      key: ValueKey('desktop-item-tabs-$itemId-${tabs.length}-$initialIndex'),
      length: tabs.length,
      initialIndex: initialIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ItemDetailHeader(
            itemName: name,
            categoryLabel: categoryLabel,
            snapshot: null,
            onEdit: () => context.push('/catalog/item/$itemId/edit'),
            onMore: onMore,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onRefresh(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ),
          const SizedBox(height: 4),
          _ItemDetailGroupedLoadBanner(
            itemId: itemId,
            includePurchases: !isStaff,
            includeIntelligence: !isStaff,
          ),
          ItemStockSnapshotCard(itemId: itemId, suppressInlineError: true),
          if (!isStaff) ...[
            const SizedBox(height: 8),
            ItemQuickActionsBar(
              itemId: itemId,
              itemName: name,
              itemCode: code,
            ),
          ],
          const SizedBox(height: 8),
          TabBar(
            isScrollable: tabs.length >= 3,
            tabs: [for (final t in tabs) Tab(text: t.label)],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 280),
              child: TabBarView(
                children: [
                  for (final t in tabs)
                    switch (t.id) {
                      ItemDetailTabId.overview => overviewBody(),
                      ItemDetailTabId.purchases => purchasesBody(),
                      ItemDetailTabId.activity => _DesktopActivityTab(
                          itemId: itemId,
                          onRefresh: onRefresh,
                        ),
                    },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desktop Activity tab — history + movement timeline (never blank).
class _DesktopActivityTab extends ConsumerWidget {
  const _DesktopActivityTab({
    required this.itemId,
    required this.onRefresh,
  });

  final String itemId;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final warehouse =
        session?.primaryBusiness.effectiveDisplayTitle.trim() ?? '';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stockItemAuditProvider(itemId));
        ref.invalidate(stockItemActivityProvider(itemId));
        await onRefresh();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
              ? constraints.maxHeight
              : 420.0;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (warehouse.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Warehouse: $warehouse',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HexaColors.neutral,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Stock change history',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push('/catalog/item/$itemId/ledger'),
                    child: const Text('Export / statement'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: (h * 0.55).clamp(280.0, 480.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: StockItemHistoryPanel(
                      itemId: itemId,
                      compact: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ItemTimelineSection(itemId: itemId),
            ],
          );
        },
      ),
    );
  }
}

class _ItemDetailMobileScroll extends ConsumerStatefulWidget {
  const _ItemDetailMobileScroll({
    required this.itemId,
    required this.name,
    required this.code,
    required this.categoryLabel,
    required this.gutter,
    required this.onRefresh,
    required this.onMore,
  });

  final String itemId;
  final String name;
  final String? code;
  final String categoryLabel;
  final double gutter;
  final Future<void> Function() onRefresh;
  final VoidCallback onMore;

  @override
  ConsumerState<_ItemDetailMobileScroll> createState() =>
      _ItemDetailMobileScrollState();
}

class _ItemDetailMobileScrollState extends ConsumerState<_ItemDetailMobileScroll>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<int> _loadedTabIndexes = {0};

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    final isStaff =
        session != null && sessionIsStaff(session);
    final tabCount = isStaff ? 2 : 3;
    final initial = _initialTabIndex(isStaff).clamp(0, tabCount - 1);
    _loadedTabIndexes.add(initial);
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: initial,
    );
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (_loadedTabIndexes.add(idx) && mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = ref.read(sessionProvider);
    final isStaff = session != null && sessionIsStaff(session);
    final desired = _initialTabIndex(isStaff).clamp(0, _tabController.length - 1);
    if (_tabController.index != desired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_tabController.index == desired) return;
        _loadedTabIndexes.add(desired);
        _tabController.animateTo(desired);
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  bool _tabReady(int index) => _loadedTabIndexes.contains(index);

  int _initialTabIndex(bool isStaff) {
    return itemDetailInitialTabIndex(_tabQuery(context), isStaff: isStaff);
  }

  static String? _tabQuery(BuildContext context) {
    return GoRouter.maybeOf(context)
        ?.state
        .uri
        .queryParameters['tab']
        ?.toLowerCase();
  }

  Widget _paddedSection(Widget child) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.gutter, 8, widget.gutter, 8),
      child: HexaResponsiveCenter(
        maxWidth: HexaResponsive.maxContentWidth,
        padding: EdgeInsets.zero,
        child: child,
      ),
    );
  }

  Widget _scrollTab(Widget child) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: child,
    );
  }

  Widget _overviewTab(bool isStaff) {
    if (!_tabReady(0)) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return _scrollTab(
      ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          _paddedSection(ItemPhysicalVerificationCard(itemId: widget.itemId)),
          if (!isStaff) ...[
            _paddedSection(
              ItemAnalyticsSection(
                itemId: widget.itemId,
                loadIntelligence: false,
                suppressInlineError: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _purchasesTab() {
    if (!_tabReady(1)) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return _scrollTab(
      ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        children: [
        _paddedSection(ItemLedgerSection(itemId: widget.itemId)),
        _paddedSection(
          ItemPurchaseHistorySection(
            itemId: widget.itemId,
            itemName: widget.name,
          ),
        ),
        _paddedSection(
          ItemSupplierIntelligenceSection(
            itemId: widget.itemId,
            itemName: widget.name,
            suppressInlineError: true,
          ),
        ),
      ],
      ),
    );
  }

  Widget _activityTab(int tabIndex) {
    if (!_tabReady(tabIndex)) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final session = ref.watch(sessionProvider);
    final warehouse =
        session?.primaryBusiness.effectiveDisplayTitle.trim() ?? '';
    return _scrollTab(
      ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          if (warehouse.isNotEmpty)
            _paddedSection(
              Text(
                'Warehouse: $warehouse',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HexaColors.neutral,
                ),
              ),
            ),
          _paddedSection(
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Stock change history',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context
                              .push('/catalog/item/${widget.itemId}/ledger'),
                          child: const Text('Export'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 360,
                      child: StockItemHistoryPanel(
                        itemId: widget.itemId,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _paddedSection(ItemTimelineSection(itemId: widget.itemId)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isStaff = session != null && sessionIsStaff(session);
    final tabs = itemDetailTabsForRole(isStaff: isStaff);
    final activityIndex =
        tabs.indexWhere((t) => t.id == ItemDetailTabId.activity);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(widget.gutter, 8, widget.gutter, 0),
                child: HexaResponsiveCenter(
                  maxWidth: HexaResponsive.maxContentWidth,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ItemDetailHeader(
                        itemName: widget.name,
                        categoryLabel: widget.categoryLabel,
                        snapshot: null,
                        onEdit: () => context
                            .push('/catalog/item/${widget.itemId}/edit'),
                        onMore: widget.onMore,
                      ),
                      const SizedBox(height: 8),
                      _ItemDetailGroupedLoadBanner(
                        itemId: widget.itemId,
                        includePurchases: !isStaff,
                        includeIntelligence: false,
                      ),
                      ItemStockSnapshotCard(
                        itemId: widget.itemId,
                        suppressInlineError: true,
                      ),
                      const SizedBox(height: 8),
                      ItemQuickActionsBar(
                        itemId: widget.itemId,
                        itemName: widget.name,
                        itemCode: widget.code,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: HexaColors.brandBackground,
            child: TabBar(
              controller: _tabController,
              isScrollable: tabs.length >= 3,
              onTap: (index) {
                if (_loadedTabIndexes.add(index) && mounted) {
                  setState(() {});
                }
              },
              tabs: [for (final t in tabs) Tab(text: t.label)],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final t in tabs)
                  switch (t.id) {
                    ItemDetailTabId.overview => _overviewTab(isStaff),
                    ItemDetailTabId.purchases => _purchasesTab(),
                    ItemDetailTabId.activity =>
                      _activityTab(activityIndex < 0 ? 0 : activityIndex),
                  },
              ],
            ),
          ),
        ],
    );
  }
}

/// Collapses multi-section item-detail fetch failures into one Retry-all banner.
class _ItemDetailGroupedLoadBanner extends ConsumerWidget {
  const _ItemDetailGroupedLoadBanner({
    required this.itemId,
    this.includePurchases = false,
    this.includeIntelligence = false,
  });

  final String itemId;
  final bool includePurchases;
  final bool includeIntelligence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockFetch = ref.watch(stockItemDetailProvider(itemId));
    final purchasesFetch = includePurchases
        ? ref.watch(tradePurchasesForItemProvider(itemId))
        : null;
    final intelFetch = includeIntelligence
        ? ref.watch(itemStockIntelligenceProvider(itemId))
        : null;

    final failed = <String>[];
    void consider(AsyncValue<dynamic>? async, String label) {
      if (async == null) return;
      if (!async.hasError || async.hasValue) return;
      if (isTransientStockFetchError(async.error)) return;
      failed.add(label);
    }

    consider(stockFetch, 'Stock summary');
    consider(purchasesFetch, 'Supplier / purchases');
    consider(intelFetch, 'Analytics');

    if (failed.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: GroupedSectionErrorCard(
        message: 'Some item details couldn\'t load',
        failedSections: failed,
        onRetryAll: () {
          ref.invalidate(stockItemDetailProvider(itemId));
          if (includePurchases) {
            ref.invalidate(tradePurchasesForItemProvider(itemId));
          }
          if (includeIntelligence) {
            ref.invalidate(itemStockIntelligenceProvider(itemId));
          }
        },
      ),
    );
  }
}

/// Full item detail bundle load failure (UX-142).
@visibleForTesting
class ItemDetailLoadError extends StatelessWidget {
  const ItemDetailLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return HexaEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'Could not load item',
      subtitle: 'Check your connection, then retry.',
      primaryActionLabel: 'Retry',
      onPrimaryAction: onRetry,
    );
  }
}
