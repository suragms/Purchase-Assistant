import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'catalog_providers.dart';
import 'stock_providers.dart';

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
  final keepAlive = ref.keepAlive();
  final timer = Timer(const Duration(seconds: 45), keepAlive.close);
  ref.onDispose(timer.cancel);

  final session = ref.watch(sessionProvider);
  if (session == null) {
    return const ItemDetailBundle(
      catalogItem: {},
      stockDetail: {},
      activity: {},
      tradePurchases: [],
    );
  }

  // Purchase history loads lazily via [tradePurchasesForItemProvider].
  final results = await Future.wait([
    ref.read(catalogItemDetailProvider(itemId).future),
    ref.read(stockItemDetailProvider(itemId).future),
    ref.read(stockItemActivityProvider(itemId).future),
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
  return ItemDetailBundle(
    catalogItem: catalog,
    stockDetail: stock,
    activity: activity,
    tradePurchases: const [],
  );
});

/// Stock map for item detail sections — sourced from [itemDetailBundleProvider]
/// (no extra HTTP while bundle is mounted on `/catalog/item/:id`).
final itemDetailStockProvider =
    Provider.autoDispose.family<AsyncValue<Map<String, dynamic>>, String>(
        (ref, itemId) {
  return ref.watch(itemDetailBundleProvider(itemId)).when(
        data: (b) => AsyncValue.data(b.stockDetail),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
});

/// Catalog map for item detail sections (same bundle, no duplicate fetch).
final itemDetailCatalogProvider =
    Provider.autoDispose.family<AsyncValue<Map<String, dynamic>>, String>(
        (ref, itemId) {
  return ref.watch(itemDetailBundleProvider(itemId)).when(
        data: (b) => AsyncValue.data(b.catalogItem),
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
});

