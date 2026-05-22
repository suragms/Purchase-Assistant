import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'home_owner_dashboard_providers.dart';

/// Consolidated warehouse alert counts for home / stock LIVE chips.
class WarehouseAlerts {
  const WarehouseAlerts({
    this.pendingDeliveries = 0,
    this.lowStock = 0,
    this.criticalStock = 0,
    this.pendingVerifications = 0,
    this.missingBarcode = 0,
    this.missingUsageLogs = 0,
    this.evictionCount = 0,
    this.checklistCompletionPct = 100,
  });

  final int pendingDeliveries;
  final int lowStock;
  final int criticalStock;
  final int pendingVerifications;
  final int missingBarcode;
  final int missingUsageLogs;
  final int evictionCount;
  final double checklistCompletionPct;

  bool get incompleteChecklist => checklistCompletionPct < 100;

  bool get hasAny =>
      pendingDeliveries > 0 ||
      lowStock > 0 ||
      criticalStock > 0 ||
      pendingVerifications > 0 ||
      missingBarcode > 0 ||
      missingUsageLogs > 0 ||
      evictionCount > 0 ||
      incompleteChecklist;

  int get total =>
      pendingDeliveries +
      lowStock +
      criticalStock +
      pendingVerifications +
      missingBarcode +
      missingUsageLogs +
      evictionCount;
}

final warehouseAlertsProvider =
    FutureProvider.autoDispose<WarehouseAlerts>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return const WarehouseAlerts();
  final dash = ref.watch(homeOwnerPeriodDashboardProvider);
  final alerts = await ref.watch(stockAlertCountsProvider.future);
  final variances = ref.watch(stockVariancesTodayProvider).valueOrNull ?? [];
  final api = ref.read(hexaApiProvider);
  final bid = session.primaryBusiness.id;
  Map<String, dynamic> summary = {};
  Map<String, dynamic> checklist = {};
  try {
    summary = await api.getStockAlertsSummary(businessId: bid);
  } catch (_) {}
  try {
    checklist = await api.getChecklistSummary(businessId: bid);
  } catch (_) {}
  return WarehouseAlerts(
    pendingDeliveries: dash.pendingDeliveryCount,
    lowStock: alerts.low,
    criticalStock: alerts.critical,
    pendingVerifications: variances.length,
    missingBarcode: (summary['missing_barcode'] as num?)?.toInt() ?? 0,
    missingUsageLogs: (summary['missing_usage_logs'] as num?)?.toInt() ?? 0,
    evictionCount: (summary['eviction_count'] as num?)?.toInt() ?? 0,
    checklistCompletionPct:
        (checklist['completion_pct'] as num?)?.toDouble() ?? 100,
  );
});
