import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'catalog_providers.dart';
import 'stock_providers.dart';
import 'trade_purchases_provider.dart';

class ItemDetailBundle {
  const ItemDetailBundle({
    required this.catalogItem,
    required this.stockDetail,
    required this.activity,
    required this.tradePurchases,
  });

  final Map<String, dynamic> catalogItem;
  final Map<String, dynamic> stockDetail;
  final Map<String, dynamic> activity;
  final List<Map<String, dynamic>> tradePurchases;
}

/// Parallel fetch for item detail. Keep this light: it is mounted whenever
/// `/catalog/item/:id` is opened.
final itemDetailBundleProvider =
    FutureProvider.autoDispose.family<ItemDetailBundle, String>((ref, itemId) async {
  final session = ref.watch(sessionProvider);
  if (session == null) {
    return const ItemDetailBundle(
      catalogItem: {},
      stockDetail: {},
      activity: {},
      tradePurchases: [],
    );
  }

  final results = await Future.wait([
    ref.watch(catalogItemDetailProvider(itemId).future),
    ref.watch(stockItemDetailProvider(itemId).future),
    ref.watch(stockItemActivityProvider(itemId).future),
    ref.watch(tradePurchasesCatalogIntelProvider.future),
  ]);

  final catalog = (results[0] as Map?) != null
      ? Map<String, dynamic>.from(results[0] as Map)
      : <String, dynamic>{};
  final stock = (results[1] as Map?) != null
      ? Map<String, dynamic>.from(results[1] as Map)
      : <String, dynamic>{};
  final activity = (results[2] as Map?) != null
      ? Map<String, dynamic>.from(results[2] as Map)
      : <String, dynamic>{};
  final purchases = (results[3] as List?) != null
      ? (results[3] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
      : <Map<String, dynamic>>[];

  return ItemDetailBundle(
    catalogItem: catalog,
    stockDetail: stock,
    activity: activity,
    tradePurchases: purchases,
  );
});

