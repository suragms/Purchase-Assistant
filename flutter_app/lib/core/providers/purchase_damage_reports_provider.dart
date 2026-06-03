import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart' show activeSessionProvider, hexaApiProvider;

final purchaseDamageReportsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, purchaseId) async {
  final session = ref.watch(activeSessionProvider);
  if (session == null || purchaseId.isEmpty) return [];
  return ref.read(hexaApiProvider).listPurchaseDamageReports(
        businessId: session.primaryBusiness.id,
        purchaseId: purchaseId,
      );
});
