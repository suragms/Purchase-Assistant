part of 'hexa_api.dart';

mixin HexaApiCatalogMethods on HexaApiBase {

  Future<List<Map<String, dynamic>>> listItemCategories(
      {required String businessId}) async {
    final res =
        await _dio.get<dynamic>('/v1/businesses/$businessId/item-categories');
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<Map<String, dynamic>> createItemCategory(
      {required String businessId, required String name}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/item-categories',
      data: {'name': name},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> updateItemCategory({
    required String businessId,
    required String categoryId,
    required String name,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/item-categories/$categoryId',
      data: {'name': name},
    );
    return res.data ?? {};
  }


  Future<void> deleteItemCategory(
      {required String businessId, required String categoryId}) async {
    await _dio
        .delete<void>('/v1/businesses/$businessId/item-categories/$categoryId');
  }


  Future<List<Map<String, dynamic>>> listCategoryTypes({
    required String businessId,
    required String categoryId,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/item-categories/$categoryId/category-types',
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// All category types with parent category name (single round-trip).

  /// All category types with parent category name (single round-trip).
  Future<List<Map<String, dynamic>>> listCategoryTypesIndex({
    required String businessId,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/category-types-index',
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<Map<String, dynamic>> createCategoryType({
    required String businessId,
    required String categoryId,
    required String name,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/item-categories/$categoryId/category-types',
      data: {'name': name},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> updateCategoryType({
    required String businessId,
    required String categoryId,
    required String typeId,
    required String name,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/item-categories/$categoryId/category-types/$typeId',
      data: {'name': name},
    );
    return res.data ?? {};
  }


  Future<void> deleteCategoryType({
    required String businessId,
    required String categoryId,
    required String typeId,
  }) async {
    await _dio.delete<void>(
      '/v1/businesses/$businessId/item-categories/$categoryId/category-types/$typeId',
    );
  }


  Future<List<Map<String, dynamic>>> listCatalogItems({
    required String businessId,
    String? categoryId,
    String? typeId,
    int perPage = 500,
    bool fetchAllPages = true,
  }) async {
    final out = <Map<String, dynamic>>[];
    var page = 1;
    const maxPages = 50;
    while (page <= maxPages) {
      final res = await _dio.get<dynamic>(
        '/v1/businesses/$businessId/catalog-items',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          if (typeId != null && typeId.isNotEmpty) 'type_id': typeId,
        },
      );
      final data = res.data;
      if (data is! List) break;
      final chunk = data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (chunk.isEmpty) break;
      out.addAll(chunk);
      if (!fetchAllPages || chunk.length < perPage) break;
      page++;
    }
    return out;
  }

  /// Token-sort fuzzy matches for catalog duplicate hints (create-item UIs).

  /// Token-sort fuzzy matches for catalog duplicate hints (create-item UIs).
  Future<List<Map<String, dynamic>>> catalogFuzzyCheck({
    required String businessId,
    required String name,
    String? supplierId,
    String? categoryId,
    String? typeId,
  }) async {
    final q = name.trim();
    if (q.isEmpty) return [];
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/catalog/fuzzy-check',
      queryParameters: {
        'name': q,
        if (supplierId != null && supplierId.isNotEmpty)
          'supplier_id': supplierId,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (typeId != null && typeId.isNotEmpty) 'type_id': typeId,
      },
    );
    final data = res.data;
    if (data is! Map) return [];
    final hits = data['hits'];
    if (hits is! List) return [];
    return hits
        .map((e) => e is Map ? Map<String, dynamic>.from(e) : null)
        .whereType<Map<String, dynamic>>()
        .toList();
  }


  Future<Map<String, dynamic>> generateCatalogItemCode({
    required String businessId,
    required String itemId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/$itemId/generate-code',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> createCatalogItem({
    required String businessId,
    required String categoryId,
    required String name,
    required String defaultUnit,
    required List<String> defaultSupplierIds,
    String? hsnCode,
    String? itemCode,
    String? typeId,
    double? defaultKgPerBag,
    double? defaultItemsPerBox,
    double? defaultWeightPerTin,
    String? defaultPurchaseUnit,
    String? defaultSaleUnit,
    double? taxPercent,
    double? defaultLandingCost,
    double? defaultSellingCost,
    String? packageType,
    List<String> defaultBrokerIds = const [],
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items',
      data: {
        'category_id': categoryId,
        'name': name,
        'default_unit': defaultUnit,
        'default_supplier_ids': defaultSupplierIds,
        if (defaultBrokerIds.isNotEmpty) 'default_broker_ids': defaultBrokerIds,
        if (hsnCode != null && hsnCode.trim().isNotEmpty)
          'hsn_code': hsnCode.trim(),
        if (itemCode != null && itemCode.trim().isNotEmpty)
          'item_code': itemCode.trim(),
        if (typeId != null && typeId.isNotEmpty) 'type_id': typeId,
        if (defaultKgPerBag != null && defaultKgPerBag > 0)
          'default_kg_per_bag': defaultKgPerBag,
        if (defaultItemsPerBox != null && defaultItemsPerBox > 0)
          'default_items_per_box': defaultItemsPerBox,
        if (defaultWeightPerTin != null && defaultWeightPerTin > 0)
          'default_weight_per_tin': defaultWeightPerTin,
        if (defaultPurchaseUnit != null && defaultPurchaseUnit.isNotEmpty)
          'default_purchase_unit': defaultPurchaseUnit,
        if (defaultSaleUnit != null && defaultSaleUnit.isNotEmpty)
          'default_sale_unit': defaultSaleUnit,
        if (taxPercent != null) 'tax_percent': taxPercent,
        if (defaultLandingCost != null)
          'default_landing_cost': defaultLandingCost,
        if (defaultSellingCost != null)
          'default_selling_cost': defaultSellingCost,
        if (packageType != null && packageType.trim().isNotEmpty)
          'package_type': packageType.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> createCatalogItemFromScan({
    required String businessId,
    required String barcode,
    required String itemCode,
    required String name,
    required String typeId,
    required String defaultUnit,
    double? defaultKgPerBag,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/from-scan',
      data: {
        'barcode': barcode.trim(),
        'item_code': itemCode.trim(),
        'name': name.trim(),
        'type_id': typeId,
        'default_unit': defaultUnit,
        if (defaultKgPerBag != null && defaultKgPerBag > 0)
          'default_kg_per_bag': defaultKgPerBag,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> patchCatalogItemCode({
    required String businessId,
    required String itemId,
    required String itemCode,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/$itemId/item-code',
      data: {'item_code': itemCode.trim()},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> patchCatalogItemBarcode({
    required String businessId,
    required String itemId,
    required String barcode,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/$itemId/barcode',
      data: {'barcode': barcode.trim()},
    );
    return res.data ?? {};
  }

  /// Batch-create catalog items (same shape as `CatalogBatchItemIn`).

  /// Batch-create catalog items (same shape as `CatalogBatchItemIn`).
  Future<Map<String, dynamic>> createCatalogItemsBatch({
    required String businessId,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/batch',
      data: {'items': items},
    );
    return res.data ?? {};
  }

  /// JSON bundle: catalog, suppliers, 90-day purchases, stock audits.

  Future<Map<String, dynamic>> getCatalogItem(
      {required String businessId, required String itemId}) async {
    final res = await _dio.get<Map<String, dynamic>>(
        '/v1/businesses/$businessId/catalog-items/$itemId');
    return res.data ?? {};
  }


  /// Resolve catalog item by barcode / item code.
  Future<Map<String, dynamic>> barcodeStockLookup({
    required String businessId,
    required String code,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/barcode/lookup',
      queryParameters: {'code': code.trim()},
    );
    return res.data ?? {};
  }

  /// Stock + recent purchases for one item.

  Future<Map<String, dynamic>> getBarcodeLabel({
    required String businessId,
    required String itemId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/barcode/$itemId',
    );
    return res.data ?? {};
  }


  Future<List<Map<String, dynamic>>> barcodeLabelBatch({
    required String businessId,
    required List<String> itemIds,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/barcode/batch',
      data: {'item_ids': itemIds},
    );
    final labels = res.data?['labels'];
    if (labels is List) {
      return labels
          .map((e) => e is Map ? Map<String, dynamic>.from(e) : null)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }

  /// Trade purchases only: latest price per supplier, last five landed prices, avg.

  Future<Map<String, dynamic>> updateCatalogItem({
    required String businessId,
    required String itemId,
    String? categoryId,
    String? typeId,
    bool patchTypeId = false,
    String? name,
    String? defaultUnit,
    bool includeDefaultUnit = false,
    bool patchDefaultKgPerBag = false,
    double? defaultKgPerBag,
    bool patchDefaultItemsPerBox = false,
    double? defaultItemsPerBox,
    bool patchDefaultWeightPerTin = false,
    double? defaultWeightPerTin,
    String? defaultPurchaseUnit,
    String? defaultSaleUnit,
    String? hsnCode,
    String? itemCode,
    double? taxPercent,
    double? defaultLandingCost,
    double? defaultSellingCost,
    List<String>? defaultSupplierIds,
    List<String>? defaultBrokerIds,
    bool patchReorderLevel = false,
    double? reorderLevel,
  }) async {
    final data = <String, dynamic>{
      if (categoryId != null) 'category_id': categoryId,
      if (patchTypeId) 'type_id': typeId,
      if (name != null) 'name': name,
    };
    if (includeDefaultUnit) {
      data['default_unit'] = defaultUnit;
    } else if (defaultUnit != null) {
      data['default_unit'] = defaultUnit;
    }
    if (patchDefaultKgPerBag) {
      data['default_kg_per_bag'] = defaultKgPerBag;
    }
    if (patchDefaultItemsPerBox) {
      data['default_items_per_box'] = defaultItemsPerBox;
    }
    if (patchDefaultWeightPerTin) {
      data['default_weight_per_tin'] = defaultWeightPerTin;
    }
    if (defaultPurchaseUnit != null) {
      data['default_purchase_unit'] = defaultPurchaseUnit;
    }
    if (defaultSaleUnit != null) {
      data['default_sale_unit'] = defaultSaleUnit;
    }
    if (hsnCode != null) {
      data['hsn_code'] = hsnCode.isEmpty ? null : hsnCode;
    }
    if (itemCode != null) {
      data['item_code'] = itemCode.trim().isEmpty ? null : itemCode.trim();
    }
    if (taxPercent != null) {
      data['tax_percent'] = taxPercent;
    }
    if (defaultLandingCost != null) {
      data['default_landing_cost'] = defaultLandingCost;
    }
    if (defaultSellingCost != null) {
      data['default_selling_cost'] = defaultSellingCost;
    }
    if (defaultSupplierIds != null) {
      data['default_supplier_ids'] = defaultSupplierIds;
    }
    if (defaultBrokerIds != null) {
      data['default_broker_ids'] = defaultBrokerIds;
    }
    if (patchReorderLevel) {
      data['reorder_level'] = reorderLevel;
    }
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/$itemId',
      data: data,
    );
    return res.data ?? {};
  }


  Future<void> deleteCatalogItem(
      {required String businessId, required String itemId}) async {
    await _dio.delete<void>('/v1/businesses/$businessId/catalog-items/$itemId');
  }


  Future<Map<String, dynamic>> catalogItemInsights({
    required String businessId,
    required String itemId,
    required String from,
    required String to,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/$itemId/insights',
      queryParameters: {'from': from, 'to': to},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> categoryInsights({
    required String businessId,
    required String categoryId,
    required String from,
    required String to,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/item-categories/$categoryId/insights',
      queryParameters: {'from': from, 'to': to},
    );
    return res.data ?? {};
  }

  /// Confirmed trade aggregates per item in a category (decision dashboard).

  /// Confirmed trade aggregates per item in a category (decision dashboard).
  Future<Map<String, dynamic>> categoryTradeSummary({
    required String businessId,
    required String categoryId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/item-categories/$categoryId/trade-summary',
    );
    return res.data ?? {};
  }


  Future<List<Map<String, dynamic>>> catalogItemLines({
    required String businessId,
    required String itemId,
    required String from,
    required String to,
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/catalog-items/$itemId/lines',
      queryParameters: {
        'from': from,
        'to': to,
        'limit': limit,
        'offset': offset,
      },
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<List<Map<String, dynamic>>> listCatalogVariants({
    required String businessId,
    required String itemId,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/v1/businesses/$businessId/catalog-items/$itemId/variants',
      );
      final data = res.data;
      if (data is! List) return [];
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on DioException catch (e) {
      // Current server returns 200 (maybe empty). A 404 here usually means the
      // running API is older than this client (route not registered) — treat as no variants.
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }


  Future<Map<String, dynamic>> createCatalogVariant({
    required String businessId,
    required String itemId,
    required String name,
    double? defaultKgPerBag,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-items/$itemId/variants',
      data: {
        'name': name,
        if (defaultKgPerBag != null) 'default_kg_per_bag': defaultKgPerBag,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> updateCatalogVariant({
    required String businessId,
    required String variantId,
    String? name,
    double? defaultKgPerBag,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog-variants/$variantId',
      data: {
        if (name != null) 'name': name,
        if (defaultKgPerBag != null) 'default_kg_per_bag': defaultKgPerBag,
      },
    );
    return res.data ?? {};
  }


  Future<void> deleteCatalogVariant(
      {required String businessId, required String variantId}) async {
    await _dio
        .delete<void>('/v1/businesses/$businessId/catalog-variants/$variantId');
  }


  Future<List<Map<String, dynamic>>> categoryItems({
    required String businessId,
    required String category,
    required String from,
    required String to,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/contacts/category-items',
      queryParameters: {'category': category, 'from': from, 'to': to},
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<Map<String, dynamic>> getCatalogDuplicateClusters({
    required String businessId,
    double minScore = 0.85,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog/duplicate-clusters',
      queryParameters: {'min_score': minScore},
    );
    return res.data ?? {};
  }


  Future<void> bulkArchiveCatalogItems({
    required String businessId,
    required List<String> itemIds,
  }) async {
    await _dio.post<void>(
      '/v1/businesses/$businessId/catalog/items/bulk-archive',
      data: {'item_ids': itemIds},
    );
  }


  Future<Map<String, dynamic>> bulkReorderCatalogItems({
    required String businessId,
    required List<String> itemIds,
    required double reorderLevel,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/catalog/items/bulk-reorder',
      data: {'item_ids': itemIds, 'reorder_level': reorderLevel},
    );
    return res.data ?? {};
  }
}
