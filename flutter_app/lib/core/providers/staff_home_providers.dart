import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'barcode_recent_scans.dart';

final staffDisplayNameProvider = FutureProvider.autoDispose<String>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return 'Staff';
  try {
    final p = await ref.read(hexaApiProvider).meProfile();
    for (final k in ['name', 'full_name', 'username']) {
      final v = p[k]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
  } catch (_) {}
  return 'Staff';
});

final staffTodayActivityProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  return ref.read(hexaApiProvider).listActivityLog(
        businessId: session.primaryBusiness.id,
        period: 'today',
        page: 1,
        perPage: 80,
      );
});

final staffLowStockAlertsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return [];
  final m = await ref.read(hexaApiProvider).listStock(
        businessId: session.primaryBusiness.id,
        page: 1,
        perPage: 8,
        status: 'low',
      );
  final items = m['items'];
  if (items is! List) return [];
  return [
    for (final e in items)
      if (e is Map) Map<String, dynamic>.from(e),
  ];
});

/// Last barcode scans from device prefs (shared with [BarcodeScanPage]).
final staffRecentScansProvider =
    FutureProvider.autoDispose<List<BarcodeRecentScan>>((ref) async {
  return loadBarcodeRecentScans(max: 8);
});

/// Counts for today's activity summary cards on staff home.
class StaffTodayActivitySummary {
  const StaffTodayActivitySummary({
    this.scanned = 0,
    this.stockUpdates = 0,
    this.itemsCreated = 0,
    this.verifications = 0,
  });

  final int scanned;
  final int stockUpdates;
  final int itemsCreated;
  final int verifications;

  int get total => scanned + stockUpdates + itemsCreated + verifications;
}

StaffTodayActivitySummary summarizeStaffActivity(List<Map<String, dynamic>> rows) {
  var scan = 0;
  var stock = 0;
  var create = 0;
  var verify = 0;
  for (final r in rows) {
    final a = (r['action_type'] ?? r['action'] ?? '').toString().toUpperCase();
    if (a.contains('SCAN')) {
      scan++;
    } else if (a.contains('STOCK')) {
      stock++;
    } else if (a.contains('ITEM') && a.contains('CREATE')) {
      create++;
    } else if (a.contains('VERIF')) {
      verify++;
    }
  }
  return StaffTodayActivitySummary(
    scanned: scan,
    stockUpdates: stock,
    itemsCreated: create,
    verifications: verify,
  );
}

final staffTodaySummaryProvider =
    Provider.autoDispose<AsyncValue<StaffTodayActivitySummary>>((ref) {
  return ref.watch(staffTodayActivityProvider).whenData(summarizeStaffActivity);
});
