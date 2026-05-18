import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/json_coerce.dart';
import '../../../core/models/session.dart';
import '../../../core/models/trade_purchase_models.dart';
import '../../../core/providers/home_dashboard_provider.dart'
    show HomeDashboardData, bustHomeDashboardVolatileCaches, homeDashboardDataProvider;
import '../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../core/providers/purchase_post_save_provider.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/notifications_provider.dart'
    show notificationsUnreadCountProvider;
import '../../../core/providers/prefs_provider.dart';
import '../../../core/providers/server_notifications_provider.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/providers/reports_provider.dart';
import '../../../core/providers/trade_purchases_provider.dart'
    show invalidateTradePurchaseCaches, invalidateTradePurchaseCachesFromContainer;
import '../../../core/theme/hexa_colors.dart';
import '../../../shared/widgets/shell_quick_ref_actions.dart';
import '../../purchase/presentation/widgets/purchase_saved_sheet.dart';
import '../../purchase/presentation/widgets/resume_purchase_draft_banner.dart';

String _inr(num n) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
        .format(n);

bool _sessionIsOwner(Session s) {
  final r = s.primaryBusiness.role.toLowerCase();
  return r == 'owner' || r == 'super_admin' || s.isSuperAdmin;
}

/// Harisree owner home: quick actions, today stats, stock, audits, recent purchases.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer? _poll;
  Timer? _rtPoll;
  Timer? _resumeRefreshDebounce;
  bool _handlingPurchasePostSave = false;
  int _lastUnread = 0;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;
  late final AnimationController _livePulse;

  @override
  void initState() {
    super.initState();
    _livePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted) return;
      bustHomeDashboardVolatileCaches();
      invalidateTradePurchaseCaches(ref);
      ref.invalidate(homeTodayDashboardDataProvider);
      ref.invalidate(stockLowCountProvider);
      ref.invalidate(stockCriticalCountProvider);
      ref.invalidate(stockLowTopHomeProvider);
      ref.invalidate(stockAuditRecentHomeProvider);
      ref.invalidate(activeSessionsCountProvider);
      ref.invalidate(homeRecentPurchasesCompactProvider);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lastUnread = ref.read(notificationsUnreadCountProvider);
      }
    });
    _rtPoll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      ref.invalidate(stockListProvider);
      invalidateTradePurchaseCaches(ref);
      ref.invalidate(homeTodayDashboardDataProvider);
      ref.invalidate(stockLowCountProvider);
      ref.invalidate(stockCriticalCountProvider);
      ref.invalidate(stockLowTopHomeProvider);
      ref.invalidate(stockAuditRecentHomeProvider);
      ref.invalidate(homeRecentPurchasesCompactProvider);
      ref.invalidate(appNotificationUnreadCountProvider);
      _maybePushBackgroundAlert();
    });
  }

  @override
  void dispose() {
    _livePulse.dispose();
    _poll?.cancel();
    _rtPoll?.cancel();
    _resumeRefreshDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _maybePushBackgroundAlert() {
    if (!ref.read(localNotificationsOptInProvider)) return;
    final bg = _lifecycle == AppLifecycleState.paused ||
        _lifecycle == AppLifecycleState.hidden ||
        _lifecycle == AppLifecycleState.inactive;
    if (!bg) return;
    final unread = ref.read(notificationsUnreadCountProvider);
    if (unread <= _lastUnread) return;
    final delta = unread - _lastUnread;
    unawaited(
      LocalNotificationsService.instance.showStockOrInAppAlert(
        title: 'Harisree Agency',
        body: delta == 1
            ? 'You have 1 new alert'
            : 'You have $delta new alerts',
        payload: 'notifications',
      ),
    );
    _lastUnread = unread;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    _lifecycle = s;
    if (s == AppLifecycleState.resumed) {
      _lastUnread = ref.read(notificationsUnreadCountProvider);
    }
    if (s != AppLifecycleState.resumed) return;
    _resumeRefreshDebounce?.cancel();
    _resumeRefreshDebounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) {
        _resumeRefreshDebounce = null;
        return;
      }
      _resumeRefreshDebounce = null;
      unawaited(_refresh());
    });
  }

  Future<void> _refresh() async {
    bustHomeDashboardVolatileCaches();
    ref.invalidate(homeDashboardDataProvider);
    ref.invalidate(homeTodayDashboardDataProvider);
    ref.invalidate(stockLowCountProvider);
    ref.invalidate(stockCriticalCountProvider);
    ref.invalidate(stockLowTopHomeProvider);
    ref.invalidate(stockAuditRecentHomeProvider);
    ref.invalidate(activeSessionsCountProvider);
    ref.invalidate(homeRecentPurchasesCompactProvider);
    invalidateTradePurchaseCaches(ref);
    ref.invalidate(reportsPurchasesPayloadProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PurchasePostSavePayload?>(purchasePostSaveProvider, (prev, next) {
      if (next == null || _handlingPurchasePostSave) return;
      _handlingPurchasePostSave = true;
      unawaited(_doHandlePurchasePostSave(next));
    });

    final session = ref.watch(sessionProvider);
    final isOwner = session != null && _sessionIsOwner(session);
    final todayAsync = ref.watch(homeTodayDashboardDataProvider);
    final lowN = ref.watch(stockLowCountProvider);
    final critN = ref.watch(stockCriticalCountProvider);
    final sessionsN = ref.watch(activeSessionsCountProvider);
    final lowRows = ref.watch(stockLowTopHomeProvider);
    final audits = ref.watch(stockAuditRecentHomeProvider);
    final recentPurch = ref.watch(homeRecentPurchasesCompactProvider);
    final bellCount = ref.watch(notificationsUnreadCountProvider);
    final conn = ref.watch(connectivityResultsProvider);
    final offline =
        conn.valueOrNull != null && isOfflineResult(conn.valueOrNull!);

    return Scaffold(
      backgroundColor: HexaColors.brandBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexaColors.brandBackground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Harisree Agency',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: -0.2,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (!offline) ...[
                  const SizedBox(width: 8),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.45, end: 1).animate(
                      CurvedAnimation(
                        parent: _livePulse,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Live',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Text(
                    'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          if (session != null)
            PopupMenuButton<String>(
              tooltip: 'Account',
              offset: const Offset(0, 40),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: HexaColors.brandPrimary.withValues(alpha: 0.15),
                child: Text(
                  () {
                    final t = session.primaryBusiness.effectiveDisplayTitle;
                    return t.isNotEmpty ? t[0].toUpperCase() : 'H';
                  }(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: HexaColors.brandPrimary,
                  ),
                ),
              ),
              onSelected: (v) async {
                if (v == 'logout') {
                  await ref.read(sessionProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    session.primaryBusiness.role.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Sign out'),
                ),
              ],
            ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              isLabelVisible: bellCount > 0,
              label: Text(
                bellCount > 99 ? '99+' : '$bellCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          ShellQuickRefActions(
            onRefresh: _refresh,
            suppressToolbarSearch: true,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const ResumePurchaseDraftBanner(),
              const SizedBox(height: 8),
              _QuickActionGrid(
                isOwner: isOwner,
                onScan: () => context.push('/barcode/scan'),
                onAddStock: () => context.go('/stock'),
                onPurchase: () => context.push('/purchase/new'),
                onReports: () => context.go('/reports'),
                onBulkPrint: () => context.push('/barcode/bulk-print'),
                onUsers: () => context.push('/settings/users'),
              ),
              const SizedBox(height: 14),
              _StatsRow(
                todayAsync: todayAsync,
                lowN: lowN,
                critN: critN,
                sessionsN: sessionsN,
              ),
              const SizedBox(height: 16),
              Text(
                'Low stock',
                style: HexaDsType.heading(16, color: HexaDsColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _LowStockTable(rowsAsync: lowRows),
              const SizedBox(height: 20),
              Text(
                'Recent stock updates',
                style: HexaDsType.heading(16, color: HexaDsColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _AuditRecentList(rowsAsync: audits),
              const SizedBox(height: 20),
              Text(
                "Today's purchases",
                style: HexaDsType.heading(16, color: HexaDsColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _RecentPurchasesCompact(rowsAsync: recentPurch),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doHandlePurchasePostSave(PurchasePostSavePayload payload) async {
    try {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      container.invalidate(homeDashboardDataProvider);
      container.invalidate(homeTodayDashboardDataProvider);
      _invalidateOwnerCachesFromContainer(container);
      invalidateTradePurchaseCachesFromContainer(container);
      container.read(purchasePostSaveProvider.notifier).state = null;
      _handlingPurchasePostSave = false;
      if (!mounted) return;
      final route = await showPurchaseSavedSheet(
        context,
        ref,
        savedJson: payload.savedJson,
        wasEdit: payload.wasEdit,
      );
      if (!mounted) return;
      final sid = payload.savedJson['id']?.toString();
      if (route == 'edit_missing' && sid != null && sid.isNotEmpty) {
        context.go('/purchase/edit/$sid');
      } else if (route == 'detail' && sid != null && sid.isNotEmpty) {
        TradePurchase? seed;
        try {
          seed = TradePurchase.fromJson(
            Map<String, dynamic>.from(payload.savedJson),
          );
        } catch (_) {}
        if (!mounted) return;
        context.go('/purchase/detail/$sid', extra: seed);
      }
    } finally {
      _handlingPurchasePostSave = false;
    }
  }

  void _invalidateOwnerCachesFromContainer(ProviderContainer c) {
    c.invalidate(homeTodayDashboardDataProvider);
    c.invalidate(stockLowCountProvider);
    c.invalidate(stockCriticalCountProvider);
    c.invalidate(stockLowTopHomeProvider);
    c.invalidate(stockAuditRecentHomeProvider);
    c.invalidate(activeSessionsCountProvider);
    c.invalidate(homeRecentPurchasesCompactProvider);
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({
    required this.isOwner,
    required this.onScan,
    required this.onAddStock,
    required this.onPurchase,
    required this.onReports,
    required this.onBulkPrint,
    required this.onUsers,
  });

  final bool isOwner;
  final VoidCallback onScan;
  final VoidCallback onAddStock;
  final VoidCallback onPurchase;
  final VoidCallback onReports;
  final VoidCallback onBulkPrint;
  final VoidCallback onUsers;

  @override
  Widget build(BuildContext context) {
    final tiles = <({String label, IconData icon, VoidCallback onTap})>[
      (label: 'Scan', icon: Icons.qr_code_scanner_rounded, onTap: onScan),
      (label: 'Add stock', icon: Icons.inventory_2_outlined, onTap: onAddStock),
      (label: 'Purchase', icon: Icons.add_shopping_cart_outlined, onTap: onPurchase),
      (label: 'Reports', icon: Icons.bar_chart_outlined, onTap: onReports),
      (label: 'Bulk print', icon: Icons.print_outlined, onTap: onBulkPrint),
      if (isOwner)
        (label: 'Users', icon: Icons.group_outlined, onTap: onUsers),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: [
        for (final t in tiles)
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: t.onTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon, color: HexaColors.brandPrimary, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      t.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.todayAsync,
    required this.lowN,
    required this.critN,
    required this.sessionsN,
  });

  final AsyncValue<HomeDashboardData> todayAsync;
  final AsyncValue<int> lowN;
  final AsyncValue<int> critN;
  final AsyncValue<int> sessionsN;

  @override
  Widget build(BuildContext context) {
    final today = todayAsync.valueOrNull;
    final purchaseToday = today?.totalPurchase ?? 0;
    final countToday = today?.purchaseCount ?? 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatPill(
            label: 'Today',
            value: todayAsync.isLoading ? '…' : _inr(purchaseToday),
            sub: todayAsync.isLoading ? 'loading' : '$countToday bills',
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: 'Low',
            value: lowN.isLoading ? '…' : '${lowN.valueOrNull ?? 0}',
            sub: 'SKU',
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: 'Critical',
            value: critN.isLoading ? '…' : '${critN.valueOrNull ?? 0}',
            sub: 'SKU',
          ),
          const SizedBox(width: 8),
          _StatPill(
            label: 'Active',
            value: sessionsN.isLoading ? '…' : '${sessionsN.valueOrNull ?? 0}',
            sub: 'sessions',
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.sub,
  });

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HexaColors.brandBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockTable extends StatelessWidget {
  const _LowStockTable({required this.rowsAsync});

  final AsyncValue<List<Map<String, dynamic>>> rowsAsync;

  @override
  Widget build(BuildContext context) {
    return rowsAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(strokeWidth: 2),
      )),
      error: (e, _) => Text('Could not load low stock', style: TextStyle(color: Colors.red.shade700)),
      data: (rows) {
        if (rows.isEmpty) {
          return Text(
            'No low-stock items',
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          );
        }
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                ListTile(
                  dense: true,
                  title: Text(
                    rows[i]['name']?.toString() ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  subtitle: Text(
                    '${rows[i]['current_stock'] ?? '—'} / ${rows[i]['reorder_level'] ?? '—'} ${rows[i]['unit'] ?? ''}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    (rows[i]['stock_status'] ?? '').toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: HexaColors.brandPrimary,
                    ),
                  ),
                  onTap: () {
                    final id = rows[i]['id']?.toString();
                    if (id != null && id.isNotEmpty) {
                      context.push('/catalog/item/$id');
                    }
                  },
                ),
                if (i < rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _auditDelta(Map<String, dynamic> r) {
  final n = coerceToDouble(r['new_qty']);
  final o = coerceToDouble(r['old_qty']);
  final d = n - o;
  if ((d - d.roundToDouble()).abs() < 1e-6) return d.round().toString();
  return d.toStringAsFixed(2);
}

class _AuditRecentList extends StatelessWidget {
  const _AuditRecentList({required this.rowsAsync});

  final AsyncValue<List<Map<String, dynamic>>> rowsAsync;

  @override
  Widget build(BuildContext context) {
    return rowsAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(strokeWidth: 2),
      )),
      error: (_, __) => const Text('Could not load stock audits'),
      data: (rows) {
        if (rows.isEmpty) {
          return Text('No recent adjustments', style: TextStyle(color: Colors.grey.shade600));
        }
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                ListTile(
                  dense: true,
                  title: Text(
                    (rows[i]['adjustment_type'] ?? 'Update').toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  subtitle: Text(
                    '${rows[i]['updated_by_name'] ?? '—'} · ${rows[i]['updated_at'] ?? ''}',
                    maxLines: 2,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    _auditDelta(rows[i]),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                if (i < rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RecentPurchasesCompact extends StatelessWidget {
  const _RecentPurchasesCompact({required this.rowsAsync});

  final AsyncValue<List<Map<String, dynamic>>> rowsAsync;

  @override
  Widget build(BuildContext context) {
    return rowsAsync.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(strokeWidth: 2),
      )),
      error: (_, __) => const Text('Could not load purchases'),
      data: (rows) {
        if (rows.isEmpty) {
          return Text('No purchases today', style: TextStyle(color: Colors.grey.shade600));
        }
        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                ListTile(
                  dense: true,
                  title: Text(
                    rows[i]['supplier_name']?.toString() ?? rows[i]['bill_no']?.toString() ?? 'Purchase',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  subtitle: Text(
                    rows[i]['purchase_date']?.toString() ?? '',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    _inr(coerceToDouble(rows[i]['total_amount'] ?? rows[i]['bill_total'] ?? 0)),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  onTap: () {
                    final id = rows[i]['id']?.toString();
                    if (id != null && id.isNotEmpty) {
                      context.push('/purchase/detail/$id');
                    }
                  },
                ),
                if (i < rows.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        );
      },
    );
  }
}
