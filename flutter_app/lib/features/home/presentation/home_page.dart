import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_notifier.dart' show hexaApiProvider, sessionProvider;
import '../../../core/models/session.dart';
import '../../../core/models/trade_purchase_models.dart';
import '../../../core/providers/home_dashboard_provider.dart'
    show bustHomeDashboardVolatileCaches, homeDashboardDataProvider;
import '../../../core/providers/home_owner_dashboard_providers.dart'
    show
        homeMonthDashboardDataProvider,
        homeRecentActivityFeedProvider,
        homeTodayDashboardDataProvider,
        stockAlertCountsProvider,
        stockAuditPeriodProvider,
        stockLowTopHomeProvider,
        stockVariancesTodayProvider;
import '../../../core/providers/purchase_post_save_provider.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/notifications_provider.dart'
    show notificationsUnreadCountProvider;
import '../../../core/providers/prefs_provider.dart';
import '../../../core/providers/server_notifications_provider.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../purchase/presentation/widgets/purchase_saved_sheet.dart';
import '../../purchase/presentation/widgets/resume_purchase_draft_banner.dart';
import 'widgets/daily_stock_report_sheet.dart';
import 'widgets/home_category_pills.dart';
import 'widgets/home_compact_header.dart';
import 'widgets/home_kpi_strip.dart';
import 'widgets/home_live_status_bar.dart';
import 'widgets/home_low_stock_section.dart';
import 'widgets/home_period_filter_row.dart';
import 'widgets/home_quick_actions_grid.dart';
import 'widgets/home_recent_changes_section.dart';
import 'widgets/home_stock_movement_section.dart';

bool _sessionIsOwner(Session s) {
  final r = s.primaryBusiness.role.toLowerCase();
  return r == 'owner' || r == 'super_admin' || s.isSuperAdmin;
}

/// Harisree owner home — dense industrial warehouse operations dashboard.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  Timer? _poll;
  Timer? _rtPoll;
  Timer? _resumeRefreshDebounce;
  bool _handlingPurchasePostSave = false;
  int _lastUnread = 0;
  int _lastNotifiedLowCount = 0;
  final _notifiedStaffPurchaseIds = <String>{};
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;
  DateTime? _lastRefreshedAt;
  DateTime? _lastThrottledInvalidate;

  bool _throttleHomeInvalidate({bool force = false}) {
    if (force) {
      _lastThrottledInvalidate = DateTime.now();
      return false;
    }
    final now = DateTime.now();
    if (_lastThrottledInvalidate != null &&
        now.difference(_lastThrottledInvalidate!).inSeconds < 5) {
      return true;
    }
    _lastThrottledInvalidate = now;
    return false;
  }

  void _invalidateHomeDataProviders() {
    bustHomeDashboardVolatileCaches();
    ref.invalidate(homeDashboardDataProvider);
    ref.invalidate(homeTodayDashboardDataProvider);
    ref.invalidate(homeMonthDashboardDataProvider);
    ref.invalidate(stockAlertCountsProvider);
    ref.invalidate(stockLowTopHomeProvider);
    ref.invalidate(stockAuditPeriodProvider);
    ref.invalidate(stockVariancesTodayProvider);
    ref.invalidate(homeRecentActivityFeedProvider);
  }

  @override
  void initState() {
    super.initState();
    _lastRefreshedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _poll = Timer.periodic(const Duration(minutes: 5), (_) {
      if (!mounted || _throttleHomeInvalidate()) return;
      _invalidateHomeDataProviders();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lastUnread = ref.read(notificationsUnreadCountProvider);
      }
    });
    _rtPoll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _lastRefreshedAt = DateTime.now());
      if (!_throttleHomeInvalidate()) {
        _invalidateHomeDataProviders();
      }
      ref.invalidate(appNotificationUnreadCountProvider);
      _maybePushBackgroundAlert();
      _maybeNotifyStaffPurchases();
    });
  }

  void _maybeNotifyStaffPurchases() {
    final session = ref.read(sessionProvider);
    if (session == null || !_sessionIsOwner(session)) return;
    if (!ref.read(localNotificationsOptInProvider)) return;
    final bg = _lifecycle == AppLifecycleState.paused ||
        _lifecycle == AppLifecycleState.hidden ||
        _lifecycle == AppLifecycleState.inactive;
    if (!bg) return;

    ref
        .read(hexaApiProvider)
        .listActivityLog(
          businessId: session.primaryBusiness.id,
          period: 'today',
          perPage: 12,
        )
        .then((rows) {
      if (!mounted) return;
      for (final r in rows) {
        final a = (r['action_type'] ?? '').toString();
        if (a != 'PURCHASE_CREATE') continue;
        final id = r['id']?.toString() ?? '';
        if (id.isEmpty || _notifiedStaffPurchaseIds.contains(id)) continue;
        _notifiedStaffPurchaseIds.add(id);
        if (_notifiedStaffPurchaseIds.length > 40) {
          _notifiedStaffPurchaseIds.remove(_notifiedStaffPurchaseIds.first);
        }
        final user = r['user_name']?.toString() ?? 'Staff';
        final details = r['details'];
        String? amount;
        if (details is Map) {
          amount = details['total_formatted']?.toString();
        }
        unawaited(
          LocalNotificationsService.instance.showStaffPurchase(
            staffName: user,
            amountFormatted: amount,
          ),
        );
      }
    }).catchError((_) {});
  }

  @override
  void dispose() {
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
    if (_throttleHomeInvalidate()) return;
    _invalidateHomeDataProviders();
    if (mounted) setState(() => _lastRefreshedAt = DateTime.now());
  }

  Future<void> _showAccountMenu() async {
    final session = ref.read(sessionProvider);
    if (session == null || !mounted) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(session.primaryBusiness.role.toUpperCase()),
              subtitle: Text(
                session.primaryBusiness.contactEmail ??
                    session.primaryBusiness.phone ??
                    session.primaryBusiness.name,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () => Navigator.pop(ctx, 'logout'),
            ),
          ],
        ),
      ),
    );
    if (action == 'logout' && mounted) {
      await ref.read(sessionProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PurchasePostSavePayload?>(purchasePostSaveProvider, (prev, next) {
      if (next == null || _handlingPurchasePostSave) return;
      _handlingPurchasePostSave = true;
      unawaited(_doHandlePurchasePostSave(next));
    });
    ref.listen(stockAlertCountsProvider, (prev, next) {
      if (!ref.read(localNotificationsOptInProvider)) return;
      next.whenData((counts) {
        final count = counts.low + counts.critical;
        if (count <= _lastNotifiedLowCount) {
          _lastNotifiedLowCount = count;
          return;
        }
        _lastNotifiedLowCount = count;
        final rows = ref.read(stockLowTopHomeProvider).valueOrNull;
        if (rows != null && rows.isNotEmpty) {
          final r = rows.first;
          final name =
              r['name']?.toString() ?? r['item_name']?.toString() ?? 'Item';
          final qty = r['stock_qty'] ?? r['quantity'] ?? r['on_hand'];
          final unit =
              r['unit']?.toString() ?? r['stock_unit']?.toString() ?? '';
          final qtyLabel = qty != null
              ? '${qty.toString()} ${unit.trim()} left'.trim()
              : 'running low';
          unawaited(LocalNotificationsService.instance.showLowStockItem(
            itemName: name,
            detail: qtyLabel,
          ));
        } else {
          unawaited(LocalNotificationsService.instance.showLowStockItem(
            itemName: 'Inventory',
            detail: count == 1
                ? '1 item running low'
                : '$count items running low',
          ));
        }
      });
    });

    final session = ref.watch(sessionProvider);
    final isOwner = session != null && _sessionIsOwner(session);
    final todayAsync = ref.watch(homeTodayDashboardDataProvider);
    final monthAsync = ref.watch(homeMonthDashboardDataProvider);
    final alertCountsAsync = ref.watch(stockAlertCountsProvider);
    final variances = ref.watch(stockVariancesTodayProvider);
    final conn = ref.watch(connectivityResultsProvider);
    final offline =
        conn.valueOrNull != null && isOfflineResult(conn.valueOrNull!);

    return Scaffold(
      backgroundColor: HexaColors.brandBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: [
              HomeCompactHeader(
                offline: offline,
                onSettingsLongPress: _showAccountMenu,
              ),
              const SizedBox(height: 12),
              const ResumePurchaseDraftBanner(),
              if (isOwner) ...[
                const HomePeriodFilterRow(),
                const SizedBox(height: 12),
              ],
              HomeQuickActionsGrid(
                isOwner: isOwner,
                onScan: () => context.push('/barcode/scan'),
                onStock: () => context.go('/stock'),
                onPurchase: () => context.push('/purchase/new'),
                onReports: () => context.go('/reports'),
                onPrint: () => context.push('/barcode/bulk-print'),
                onDaily: isOwner
                    ? () => DailyStockReportSheet.show(context)
                    : null,
                onUsers: () => context.push('/settings/users'),
              ),
              const SizedBox(height: 12),
              if (isOwner) ...[
                HomeLiveStatusBar(
                  offline: offline,
                  lastRefreshedAt: _lastRefreshedAt,
                ),
                const SizedBox(height: 12),
                HomeKpiStrip(
                  todayAsync: todayAsync,
                  monthAsync: monthAsync,
                  alertCountsAsync: alertCountsAsync,
                ),
                const SizedBox(height: 12),
                const HomeCategoryPills(),
                const SizedBox(height: 12),
                const HomeRecentChangesSection(),
                const SizedBox(height: 12),
              ],
              const HomeLowStockSection(),
              variances.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (rows) {
                  if (rows.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Material(
                      color: const Color(0xFFFFF5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFC62828)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFC62828),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pending verification · ${rows.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            for (final v in rows.take(3))
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '${v['item_name'] ?? 'Item'}: expected '
                                  '${v['expected_qty'] ?? '—'} · found '
                                  '${v['found_qty'] ?? '—'}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const HomeStockMovementSection(),
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
      _invalidateOwnerCachesFromContainer(container);
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
    bustHomeDashboardVolatileCaches();
    c.invalidate(homeTodayDashboardDataProvider);
    c.invalidate(homeMonthDashboardDataProvider);
    c.invalidate(stockAlertCountsProvider);
    c.invalidate(stockLowTopHomeProvider);
    c.invalidate(stockAuditPeriodProvider);
    c.invalidate(stockVariancesTodayProvider);
    c.invalidate(homeRecentActivityFeedProvider);
    c.invalidate(homeDashboardDataProvider);
  }
}
