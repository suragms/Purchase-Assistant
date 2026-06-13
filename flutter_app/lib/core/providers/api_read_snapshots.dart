import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/hexa_api.dart';
import '../auth/session_notifier.dart' show activeSessionProvider, hexaApiProvider;
import '../auth/provider_api_guard.dart';

/// SSOT for `GET …/stock/audit/recent` — one fetch serves home, stock tabs, and activity.
final stockAuditRecentSnapshotProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), link.close);
  ref.onDispose(timer.cancel);
  if (providerSkipApi(ref)) return [];
  final session = ref.watch(activeSessionProvider);
  if (session == null) return [];
  return ref.read(hexaApiProvider).listStockAuditRecent(
        businessId: session.primaryBusiness.id,
        limit: HexaApi.stockAuditRecentMaxLimit,
      );
});

/// SSOT for recent unfiltered `GET …/trade-purchases?limit=50` (alerts + catalog intel).
final tradePurchasesRecentSnapshotProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 2), link.close);
  ref.onDispose(timer.cancel);
  if (providerSkipApi(ref)) return [];
  final session = ref.watch(activeSessionProvider);
  if (session == null) return [];
  return ref.read(hexaApiProvider).listTradePurchases(
        businessId: session.primaryBusiness.id,
        limit: 50,
      );
});

void bustStockAuditRecentSnapshot(dynamic ref) {
  ref.invalidate(stockAuditRecentSnapshotProvider);
}

void bustTradePurchasesRecentSnapshot(dynamic ref) {
  ref.invalidate(tradePurchasesRecentSnapshotProvider);
}
