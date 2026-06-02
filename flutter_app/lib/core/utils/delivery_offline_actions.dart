import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_error_messages.dart' show shouldQueueScanOffline;
import '../auth/session_notifier.dart';
import '../services/offline_store.dart';

/// Mark purchase arrived — queue when warehouse has no connectivity.
Future<({bool queued, Map<String, dynamic>? body})> markPurchaseArrivedResilient({
  required WidgetRef ref,
  required String businessId,
  required String purchaseId,
  String? notes,
  String? truckNumber,
  String? driverContact,
  double? damageQty,
  double? missingQty,
  bool? brokerConfirmed,
}) async {
  try {
    final body = await ref.read(hexaApiProvider).arrivePurchase(
          businessId: businessId,
          purchaseId: purchaseId,
          notes: notes,
          truckNumber: truckNumber,
          driverContact: driverContact,
          damageQty: damageQty,
          missingQty: missingQty,
          brokerConfirmed: brokerConfirmed,
        );
    return (queued: false, body: Map<String, dynamic>.from(body));
  } on DioException catch (e) {
    if (!shouldQueueScanOffline(e)) rethrow;
    await OfflineStore.queuePurchaseArrive(
      businessId: businessId,
      purchaseId: purchaseId,
      notes: notes,
    );
    return (queued: true, body: null);
  }
}
