import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';

final checklistTodayProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return {};
  return ref.read(hexaApiProvider).getChecklistToday(
        businessId: session.primaryBusiness.id,
      );
});

final usageTodayProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return {};
  return ref.read(hexaApiProvider).getUsageToday(
        businessId: session.primaryBusiness.id,
      );
});

final itemTodaySnapshotProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, itemId) async {
  final session = ref.watch(sessionProvider);
  if (session == null || itemId.isEmpty) return null;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final rows = await ref.read(hexaApiProvider).listDailySnapshots(
        businessId: session.primaryBusiness.id,
        fromDate: today,
        toDate: today,
        itemId: itemId,
      );
  if (rows.isEmpty) return null;
  return rows.first;
});

final operationalReportsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return {};
  return ref.read(hexaApiProvider).getOperationalReports(
        businessId: session.primaryBusiness.id,
      );
});
