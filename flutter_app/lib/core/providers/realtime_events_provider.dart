import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'business_aggregates_invalidation.dart';
import 'low_stock_providers.dart';
import 'stock_providers.dart';
import 'trade_purchases_provider.dart';

void invalidateAfterStockWrite(WidgetRef ref, {String? itemId}) {
  invalidateWarehouseSurfacesLight(ref, itemId: itemId);
  ref.invalidate(stockStatusCountsProvider);
  ref.invalidate(lowStockOperationsSummaryProvider);
}

void invalidateAfterPurchaseWrite(WidgetRef ref) {
  ref.invalidate(tradePurchasesListProvider);
  invalidateAfterStockWrite(ref);
}

@visibleForTesting
Set<String> itemIdsFromRealtimePayload(Map<String, dynamic>? payload) {
  if (payload == null || payload.isEmpty) return const {};
  final out = <String>{};
  final single = payload['item_id']?.toString();
  if (single != null && single.isNotEmpty) out.add(single);
  final many = payload['item_ids'];
  if (many is List) {
    for (final raw in many) {
      final id = raw?.toString() ?? '';
      if (id.isNotEmpty) out.add(id);
    }
  }
  return out;
}

/// What changed on the latest realtime poll (consumers decide how to refresh).
class RealtimeInvalidationSignal {
  const RealtimeInvalidationSignal({
    required this.tick,
    this.notifications = false,
    this.warehouse = false,
    this.affectedItemIds = const {},
  });

  final int tick;
  final bool notifications;
  final bool warehouse;
  final Set<String> affectedItemIds;
}

/// Polls server events; does **not** invalidate providers itself (avoids double-refresh).
final realtimeInvalidationProvider =
    StreamProvider<RealtimeInvalidationSignal>((ref) async* {
  final link = ref.keepAlive();
  ref.onDispose(() => link.close());

  final session = ref.watch(sessionProvider);
  if (session == null) return;
  final api = ref.read(hexaApiProvider);
  final seen = <String>{};
  var tick = 0;

  Future<RealtimeInvalidationSignal> poll({required bool initial}) async {
    final rows = await api.listRealtimeEvents(
      businessId: session.primaryBusiness.id,
      limit: 40,
    );
    var notifications = false;
    var warehouse = false;
    final affectedItemIds = <String>{};
    for (final row in rows) {
      final key =
          '${row['type']}:${row['created_at']}:${row['payload']?.toString() ?? ''}';
      if (!seen.add(key) || initial) continue;
      final type = row['type']?.toString() ?? '';
      final payload = row['payload'] is Map
          ? Map<String, dynamic>.from(row['payload'] as Map)
          : null;
      if (type == 'notification.changed') {
        notifications = true;
      } else if (type == 'stock.changed' ||
          type == 'stock.activity_changed' ||
          type == 'purchase.changed') {
        warehouse = true;
        affectedItemIds.addAll(itemIdsFromRealtimePayload(payload));
      }
    }
    return RealtimeInvalidationSignal(
      tick: tick,
      notifications: notifications,
      warehouse: warehouse,
      affectedItemIds: affectedItemIds,
    );
  }

  yield await poll(initial: true);
  final timer = Stream.periodic(const Duration(seconds: 60));
  await for (final _ in timer) {
    tick++;
    yield await poll(initial: false);
  }
});
