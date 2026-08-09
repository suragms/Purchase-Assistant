part of 'hexa_api.dart';

mixin HexaApiStockMethods on HexaApiBase {

  /// Server-built stock inventory Excel (all catalog items).
  Future<Uint8List> downloadStockInventoryXlsx({
    required String businessId,
  }) async {
    final res = await _dio.get<List<int>>(
      '/v1/businesses/$businessId/exports/stock-inventory.xlsx',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    final raw = res.data;
    if (raw == null) return Uint8List(0);
    return Uint8List.fromList(raw);
  }

  /// Server-built PDF of trade purchases for the current calendar month.

  Future<Map<String, dynamic>> getStockTotals({
    required String businessId,
    String? periodStart,
    String? periodEnd,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/totals',
      queryParameters: {
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
        if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getStockItemBundle({
    required String businessId,
    required String itemId,
    String? periodStart,
    String? periodEnd,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/bundle',
      queryParameters: {
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
        if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getStockIntelligence({
    required String businessId,
    required String itemId,
    String? periodStart,
    String? periodEnd,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/intelligence',
      queryParameters: {
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
        if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      },
    );
    return res.data ?? {};
  }

  /// Stock list with filters (server-side pagination).
  /// Pass [ifNoneMatch] for ETag revalidation; 304 returns `{'_not_modified': true}`.

  /// Stock list with filters (server-side pagination).
  /// Pass [ifNoneMatch] for ETag revalidation; 304 returns `{'_not_modified': true}`.
  Future<Map<String, dynamic>> listStock({
    required String businessId,
    int page = 1,
    int perPage = 50,
    String q = '',
    String category = '',
    String subcategory = '',
    String status = 'all',
    String sort = 'name',
    bool includePeriod = false,
    String? periodStart,
    String? periodEnd,
    bool includeToday = true,
    bool purchasedInPeriod = false,
    bool missingBarcode = false,
    bool missingItemCode = false,
    bool reorderOnly = false,
    String unit = '',
    String? ifNoneMatch,
  }) async {
    Future<Response<Map<String, dynamic>>> doGet({required bool cacheBust}) {
      return _dio.get<Map<String, dynamic>>(
        '/v1/businesses/$businessId/stock/list',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'q': q,
          'category': category,
          'subcategory': subcategory,
          'status': status,
          'sort': sort,
          if (includePeriod) 'include_period': true,
          if (includeToday) 'include_today': true,
          if (purchasedInPeriod) 'purchased_in_period': true,
          if (missingBarcode) 'missing_barcode': true,
          if (missingItemCode) 'missing_item_code': true,
          if (reorderOnly) 'reorder_only': true,
          if (unit.trim().isNotEmpty) 'unit': unit.trim(),
          if (periodStart != null && periodStart.isNotEmpty) ...{
            'period_start': periodStart,
            'date_from': periodStart,
          },
          if (periodEnd != null && periodEnd.isNotEmpty) ...{
            'period_end': periodEnd,
            'date_to': periodEnd,
          },
          if (cacheBust) '_nc': DateTime.now().millisecondsSinceEpoch,
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            if (!cacheBust &&
                ifNoneMatch != null &&
                ifNoneMatch.isNotEmpty)
              'If-None-Match': ifNoneMatch,
          },
          validateStatus: (code) =>
              code != null && (code < 400 || code == 304),
        ),
      );
    }

    var res = await doGet(cacheBust: false);
    // Browser HTTP cache can return 304 even without If-None-Match — breaks RAM ETag path.
    if (res.statusCode == 304 &&
        (kIsWeb || ifNoneMatch == null || ifNoneMatch.isEmpty)) {
      res = await doGet(cacheBust: true);
    }
    if (res.statusCode == 304) {
      return const {'_not_modified': true};
    }
    final data = res.data ??
        <String, dynamic>{
          'items': <dynamic>[],
          'total': 0,
          'page': page,
          'per_page': perPage,
        };
    final etag = res.headers.value('etag');
    if (etag != null && etag.isNotEmpty) {
      data['_etag'] = etag;
    }
    return data;
  }

  /// Bundled Stock tab payload (list + KPI chips + delivery counts + audit preview).

  /// Bundled Stock tab payload (list + KPI chips + delivery counts + audit preview).
  Future<Map<String, dynamic>> fetchStockShellBundle({
    required String businessId,
    int page = 1,
    int perPage = 50,
    String q = '',
    String category = '',
    String subcategory = '',
    String status = 'all',
    String sort = 'name',
    bool includePeriod = false,
    String? periodStart,
    String? periodEnd,
    bool includeToday = true,
    bool purchasedInPeriod = false,
    bool missingBarcode = false,
    bool missingItemCode = false,
    bool reorderOnly = false,
    String unit = '',
    int auditLimit = 12,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/shell-bundle',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'q': q,
        'category': category,
        'subcategory': subcategory,
        'status': status,
        'sort': sort,
        if (includePeriod) 'include_period': true,
        if (includeToday) 'include_today': true,
        if (purchasedInPeriod) 'purchased_in_period': true,
        if (missingBarcode) 'missing_barcode': true,
        if (missingItemCode) 'missing_item_code': true,
        if (reorderOnly) 'reorder_only': true,
        if (unit.trim().isNotEmpty) 'unit': unit.trim(),
        if (periodStart != null && periodStart.isNotEmpty) ...{
          'period_start': periodStart,
          'date_from': periodStart,
        },
        if (periodEnd != null && periodEnd.isNotEmpty) ...{
          'period_end': periodEnd,
          'date_to': periodEnd,
        },
        'audit_limit': auditLimit,
      },
    );
    return res.data ?? {};
  }

  /// Pending/delivered truck counts for stock list filters (full catalog slice).

  /// Pending/delivered truck counts for stock list filters (full catalog slice).
  Future<Map<String, dynamic>> stockDeliveryIndicatorCounts({
    required String businessId,
    String q = '',
    String category = '',
    String subcategory = '',
    String status = 'all',
    String sort = 'name',
    bool includePeriod = false,
    String? periodStart,
    String? periodEnd,
    bool missingBarcode = false,
    bool missingItemCode = false,
    bool reorderOnly = false,
    String unit = '',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/delivery-indicator-counts',
      queryParameters: {
        'q': q,
        'category': category,
        'subcategory': subcategory,
        'status': status,
        'sort': sort,
        if (includePeriod) 'include_period': true,
        if (missingBarcode) 'missing_barcode': true,
        if (missingItemCode) 'missing_item_code': true,
        if (reorderOnly) 'reorder_only': true,
        if (unit.trim().isNotEmpty) 'unit': unit.trim(),
        if (periodStart != null && periodStart.isNotEmpty) ...{
          'period_start': periodStart,
          'date_from': periodStart,
        },
        if (periodEnd != null && periodEnd.isNotEmpty) ...{
          'period_end': periodEnd,
          'date_to': periodEnd,
        },
      },
    );
    return res.data ?? <String, dynamic>{'pending': 0, 'delivered': 0};
  }

  /// On-hand warehouse valuation (landing cost × qty) and unit buckets.

  /// On-hand warehouse valuation (landing cost × qty) and unit buckets.
  Future<Map<String, dynamic>> stockInventorySummary({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/inventory-summary',
    );
    return res.data ??
        <String, dynamic>{
          'total_value_inr': 0,
          'bags': 0,
          'boxes': 0,
          'tins': 0,
          'kg': 0,
          'item_count': 0,
        };
  }

  /// Low-stock operations summary for the enterprise operations header.

  /// Low-stock operations summary for the enterprise operations header.
  Future<Map<String, dynamic>> getLowStockSummary({
    required String businessId,
    String q = '',
    String category = '',
    String subcategory = '',
    String? periodStart,
    String? periodEnd,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/low-stock/summary',
      queryParameters: {
        if (q.isNotEmpty) 'q': q,
        if (category.isNotEmpty) 'category': category,
        if (subcategory.isNotEmpty) 'subcategory': subcategory,
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
        if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      },
    );
    return res.data ?? {};
  }

  /// Low-stock operations list with priority scoring and server-side paging.

  /// Low-stock operations list with priority scoring and server-side paging.
  Future<Map<String, dynamic>> listLowStockOperations({
    required String businessId,
    required int page,
    required int perPage,
    String q = '',
    String filter = 'all',
    String category = '',
    String subcategory = '',
    String sort = 'priority',
    String? periodStart,
    String? periodEnd,
  }) async {
    final cappedPerPage = perPage.clamp(1, HexaApi.lowStockOperationsMaxPerPage);
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/low-stock/operations',
      queryParameters: {
        'page': page,
        'per_page': cappedPerPage,
        if (q.isNotEmpty) 'q': q,
        'filter': filter,
        if (category.isNotEmpty) 'category': category,
        if (subcategory.isNotEmpty) 'subcategory': subcategory,
        'sort': sort,
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
        if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      },
    );
    return res.data ?? {};
  }

  /// Max rows for [listStockAuditRecent] (must match backend `le` on `/audit/recent`).

  /// Max rows for [listStockAuditRecent] (must match backend `le` on `/audit/recent`).
  /// See [HexaApi.stockAuditRecentMaxLimit].

  /// Max page size for [listLowStockOperations] (must match backend `le=200`).
  /// See [HexaApi.lowStockOperationsMaxPerPage].

  Future<List<Map<String, dynamic>>> listStockAuditRecent({
    required String businessId,
    int limit = 12,

    /// Calendar day filter (YYYY-MM-DD). Omit for latest across all days.
    String? on,
  }) async {
    final capped = limit.clamp(1, HexaApi.stockAuditRecentMaxLimit);
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/stock/audit/recent',
      queryParameters: {
        'limit': capped,
        if (on != null && on.isNotEmpty) 'on': on,
      },
    );
    final data = res.data;
    if (data is! List) return [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>)
          e
        else if (e is Map)
          Map<String, dynamic>.from(e),
    ];
  }

  /// Observation physical remaining history (Activity change log).

  /// Observation physical remaining history (Activity change log).
  Future<List<Map<String, dynamic>>> listPhysicalCountsRecent({
    required String businessId,
    int limit = 50,
    String? dateFrom,
    String? dateTo,
  }) async {
    final capped = limit.clamp(1, HexaApi.stockAuditRecentMaxLimit);
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/stock/physical-counts/recent',
      queryParameters: {
        'limit': capped,
        if (dateFrom != null && dateFrom.isNotEmpty) 'from': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'to': dateTo,
      },
    );
    final data = res.data;
    if (data is! List) return [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>)
          e
        else if (e is Map)
          Map<String, dynamic>.from(e),
    ];
  }

  /// Per-item physical remaining history.

  /// Per-item physical remaining history.
  Future<List<Map<String, dynamic>>> listPhysicalCountsForItem({
    required String businessId,
    required String itemId,
    int limit = 50,
  }) async {
    final capped = limit.clamp(1, 200);
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/stock/physical-counts/by-item/$itemId',
      queryParameters: {'limit': capped},
    );
    final data = res.data;
    if (data is! List) return [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>)
          e
        else if (e is Map)
          Map<String, dynamic>.from(e),
    ];
  }

  /// Today's stock count variances (purchase qty vs verification).

  /// Today's stock count variances (purchase qty vs verification).
  Future<List<Map<String, dynamic>>> listStockVariancesToday({
    required String businessId,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/stock/variances/today',
    );
    final data = res.data;
    if (data is! List) return [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>)
          e
        else if (e is Map)
          Map<String, dynamic>.from(e),
    ];
  }


  Future<List<Map<String, dynamic>>> listActiveSessions({
    required String businessId,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/users/active-sessions',
    );
    final data = res.data;
    if (data is! List) return [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>)
          e
        else if (e is Map)
          Map<String, dynamic>.from(e),
    ];
  }

  /// Resolve catalog item by barcode / item code.

  /// Stock + recent purchases for one item.
  Future<Map<String, dynamic>> getStockItem({
    required String businessId,
    required String itemId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId',
    );
    return res.data ?? {};
  }


  Future<int?> _freshStockVersion({
    required String businessId,
    required String itemId,
  }) async {
    final fresh = await getStockItem(businessId: businessId, itemId: itemId);
    return stockVersionFromItem(fresh);
  }

  /// Alert owners/managers about a catalog item (in-app notifications).

  /// Alert owners/managers about a catalog item (in-app notifications).
  Future<void> notifyOwnerStockItem({
    required String businessId,
    required String itemId,
    String alert = 'reorder',
  }) async {
    await _dio.post<void>(
      '/v1/businesses/$businessId/stock/$itemId/notify-owner',
      queryParameters: {'alert': alert},
    );
  }

  /// Add item to business reorder list (pending).

  /// Add item to business reorder list (pending).
  Future<void> addItemToReorderList({
    required String businessId,
    required String itemId,
  }) async {
    await _dio.post<void>(
      '/v1/businesses/$businessId/stock/$itemId/reorder',
    );
  }


  Future<List<Map<String, dynamic>>> listReorderEntries({
    required String businessId,
    String status = 'pending',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/reorder',
      queryParameters: {'status': status},
    );
    final data = res.data;
    final items = data?['items'];
    if (items is! List) return [];
    return [
      for (final e in items)
        if (e is Map) Map<String, dynamic>.from(e)
    ];
  }


  Future<Map<String, dynamic>> patchReorderEntry({
    required String businessId,
    required String entryId,
    required String status,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/reorder/$entryId',
      data: {'status': status},
    );
    return Map<String, dynamic>.from(res.data ?? {});
  }


  Future<void> deleteReorderEntry({
    required String businessId,
    required String entryId,
  }) async {
    await _dio.delete<void>(
      '/v1/businesses/$businessId/stock/reorder/$entryId',
    );
  }

  /// Authoritative stock adjustment (audit logged on server).

  /// Authoritative stock adjustment (audit logged on server).
  Future<List<Map<String, dynamic>>> listStockAuditForItem({
    required String businessId,
    required String itemId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/v1/businesses/$businessId/stock/audit/$itemId',
    );
    return _parseJsonMapList(res.data);
  }


  Future<Map<String, dynamic>> patchStockItem({
    required String businessId,
    required String itemId,
    required num newQty,
    String adjustmentType = 'verification',
    String? reason,
    int? lastSeenStockVersion,
    String? idempotencyKey,
    bool force = false,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId',
      queryParameters: force ? {'force': 'true'} : null,
      data: {
        'new_qty': newQty,
        'adjustment_type': adjustmentType,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (lastSeenStockVersion != null)
          'last_seen_stock_version': lastSeenStockVersion,
        if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
          'idempotency_key': idempotencyKey.trim(),
      },
      options: _stockWriteOptions.copyWith(extra: {'idempotentWrite': true}),
    );
    return res.data ?? {};
  }

  /// PATCH stock with one silent retry on `STALE_STOCK_VERSION` (409).

  /// PATCH stock with one silent retry on `STALE_STOCK_VERSION` (409).
  Future<Map<String, dynamic>> patchStockItemWithRetry({
    required String businessId,
    required String itemId,
    required num newQty,
    String adjustmentType = 'verification',
    String? reason,
    int? initialStockVersion,
    String? idempotencyKey,
  }) {
    return runWithStockVersionRetry(
      initialVersion: initialStockVersion,
      refreshVersion: () => _freshStockVersion(
        businessId: businessId,
        itemId: itemId,
      ),
      operation: (version, {force = false}) => patchStockItem(
        businessId: businessId,
        itemId: itemId,
        newQty: newQty,
        adjustmentType: adjustmentType,
        reason: reason,
        lastSeenStockVersion: version,
        idempotencyKey: idempotencyKey,
        force: force,
      ),
    );
  }


  Future<Map<String, dynamic>> updatePhysicalStock({
    required String businessId,
    required String itemId,
    required num countedQty,
    required String adjustmentType,
    required String reason,
    String? notes,
    int? lastSeenStockVersion,
    String? idempotencyKey,
    String? periodStart,
    String? periodEnd,
    bool force = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/physical-update',
      queryParameters: force ? {'force': 'true'} : null,
      data: {
        'counted_qty': countedQty,
        'adjustment_type': adjustmentType,
        'reason': reason.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (lastSeenStockVersion != null)
          'last_seen_stock_version': lastSeenStockVersion,
        if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
          'idempotency_key': idempotencyKey.trim(),
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
        if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      },
      options: _stockWriteOptions.copyWith(extra: {'idempotentWrite': true}),
    );
    return res.data ?? {};
  }

  /// POST physical-update with one silent retry on `STALE_STOCK_VERSION` (409).

  /// POST physical-update with one silent retry on `STALE_STOCK_VERSION` (409).
  Future<Map<String, dynamic>> updatePhysicalStockWithRetry({
    required String businessId,
    required String itemId,
    required num countedQty,
    required String adjustmentType,
    required String reason,
    String? notes,
    int? initialStockVersion,
    String? idempotencyKey,
    String? periodStart,
    String? periodEnd,
  }) {
    return runWithStockVersionRetry(
      initialVersion: initialStockVersion,
      refreshVersion: () => _freshStockVersion(
        businessId: businessId,
        itemId: itemId,
      ),
      operation: (version, {force = false}) => updatePhysicalStock(
        businessId: businessId,
        itemId: itemId,
        countedQty: countedQty,
        adjustmentType: adjustmentType,
        reason: reason,
        notes: notes,
        lastSeenStockVersion: version,
        idempotencyKey: idempotencyKey,
        periodStart: periodStart,
        periodEnd: periodEnd,
        force: force,
      ),
    );
  }

  /// Physical count from barcode scan (mandatory reason when variance).

  /// Physical count from barcode scan (mandatory reason when variance).
  Future<Map<String, dynamic>> verifyStockCount({
    required String businessId,
    required String itemId,
    required num countedQty,
    required String reason,
    String adjustmentType = 'verification',
    String? notes,
    String? idempotencyKey,
  }) async {
    final body = <String, dynamic>{
      'counted_qty': countedQty,
      'adjustment_type': adjustmentType,
      'reason': reason.trim(),
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
    final idem = (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
        ? idempotencyKey.trim()
        : _idempotencyKeyFor(body);
    body['idempotency_key'] = idem;
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/verify-count',
      data: body,
      options: _stockWriteOptions.copyWith(extra: {'idempotentWrite': true}),
    );
    return res.data ?? {};
  }

  /// verify-count with retry when server returns stale version (rare concurrent edit).

  /// verify-count with retry when server returns stale version (rare concurrent edit).
  Future<Map<String, dynamic>> verifyStockCountWithRetry({
    required String businessId,
    required String itemId,
    required num countedQty,
    required String reason,
    String adjustmentType = 'verification',
    String? notes,
    int? initialStockVersion,
  }) {
    return runWithStockVersionRetry(
      initialVersion: initialStockVersion,
      refreshVersion: () => _freshStockVersion(
        businessId: businessId,
        itemId: itemId,
      ),
      operation: (_, {force = false}) => verifyStockCount(
        businessId: businessId,
        itemId: itemId,
        countedQty: countedQty,
        reason: reason,
        adjustmentType: adjustmentType,
        notes: notes,
      ),
    );
  }


  Future<Map<String, dynamic>> recordPhysicalStockCount({
    required String businessId,
    required String itemId,
    required num countedQty,
    String? periodStart,
    String? periodEnd,
    String? notes,
    String? idempotencyKey,
  }) async {
    final body = <String, dynamic>{
      'counted_qty': countedQty,
      if (periodStart != null && periodStart.isNotEmpty)
        'period_start': periodStart,
      if (periodEnd != null && periodEnd.isNotEmpty) 'period_end': periodEnd,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
    final idem = (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
        ? idempotencyKey.trim()
        : _idempotencyKeyFor(body);
    body['idempotency_key'] = idem;
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/physical-count',
      data: body,
      options: _stockWriteOptions.copyWith(extra: {'idempotentWrite': true}),
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getMissingOpeningStock({
    required String businessId,
    int limit = 100,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/opening/missing',
      queryParameters: {'limit': limit},
    );
    return res.data ?? {'items': <Map<String, dynamic>>[], 'missing_count': 0};
  }


  Future<Map<String, dynamic>> listOpeningStockSetup({
    required String businessId,
    int page = 1,
    int perPage = 50,
    String q = '',
    String status = 'all',
    String stockStatus = 'all',
    bool missingBarcode = false,
    bool missingItemCode = false,
    String category = '',
    String subcategory = '',
    String? supplierId,
    String unit = '',
    bool updatedToday = false,
    String updatedBy = '',
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/opening/setup',
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (q.trim().isNotEmpty) 'q': q.trim(),
        if (status.isNotEmpty && status != 'all') 'status': status,
        if (stockStatus.isNotEmpty && stockStatus != 'all')
          'stock_status': stockStatus,
        if (missingBarcode) 'missing_barcode': true,
        if (missingItemCode) 'missing_item_code': true,
        if (category.trim().isNotEmpty) 'category': category.trim(),
        if (subcategory.trim().isNotEmpty) 'subcategory': subcategory.trim(),
        if (supplierId != null && supplierId.isNotEmpty) 'supplier_id': supplierId,
        if (unit.trim().isNotEmpty) 'unit': unit.trim(),
        if (updatedToday) 'updated_today': true,
        if (updatedBy.trim().isNotEmpty) 'updated_by': updatedBy.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> setOpeningStock({
    required String businessId,
    required String itemId,
    required num qty,
    bool override = false,
    String? reason,
    String? notes,
    String? idempotencyKey,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/opening-stock',
      data: {
        'qty': qty,
        'override': override,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
          'idempotency_key': idempotencyKey.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<List<Map<String, dynamic>>> listStaffPurchaseLogs({
    required String businessId,
    String? itemId,
    int limit = 100,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/stock/staff-purchases',
      queryParameters: {
        if (itemId != null && itemId.isNotEmpty) 'item_id': itemId,
        'limit': limit,
      },
    );
    return _parseJsonMapList(res.data);
  }


  Future<Map<String, dynamic>> createStaffPurchaseLog({
    required String businessId,
    required String itemId,
    required num qty,
    num? amount,
    String? supplierName,
    String? notes,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/staff-purchases',
      data: {
        'item_id': itemId,
        'qty': qty,
        if (amount != null) 'amount': amount,
        if (supplierName != null && supplierName.trim().isNotEmpty)
          'supplier_name': supplierName.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> createStockQuickPurchase({
    required String businessId,
    required String itemId,
    required num qty,
    required String supplierId,
    String? brokerId,
    String? notes,
    String? idempotencyKey,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/quick-purchase',
      data: {
        'qty': qty,
        'supplier_id': supplierId,
        if (brokerId != null && brokerId.isNotEmpty) 'broker_id': brokerId,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty)
          'idempotency_key': idempotencyKey.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getStockItemActivity({
    required String businessId,
    required String itemId,
    int limit = 50,
    int offset = 0,
    String? kind,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/activity',
      queryParameters: {
        'limit': limit,
        if (offset > 0) 'offset': offset,
        if (kind != null && kind.trim().isNotEmpty) 'kind': kind.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> compareSalesLines({
    required String businessId,
    required List<Map<String, dynamic>> lines,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/reports/sales-comparison',
      data: {'lines': lines},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>?> getActiveStockAudit({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>?>(
      '/v1/businesses/$businessId/stock-audits/active',
    );
    return res.data;
  }


  Future<Map<String, dynamic>> createStockAudit({
    required String businessId,
    String? notes,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock-audits',
      data: {'notes': notes, 'items': []},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> upsertStockAuditLine({
    required String businessId,
    required String auditId,
    required String itemId,
    required num countedQty,
    String? adjustmentType,
    String? reason,
    String? notes,
    bool applyImmediately = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock-audits/$auditId/lines',
      data: {
        'item_id': itemId,
        'counted_qty': countedQty,
        if (adjustmentType != null) 'adjustment_type': adjustmentType,
        if (reason != null) 'reason': reason,
        if (notes != null) 'notes': notes,
        'apply_immediately': applyImmediately,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> completeStockAudit({
    required String businessId,
    required String auditId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock-audits/$auditId/complete',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getStockAudit({
    required String businessId,
    required String auditId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock-audits/$auditId',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getStockAuditKpis({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock-audits/kpis',
    );
    return res.data ?? {};
  }

  /// Owner/manager view: pending stock-audit lines for one item.

  /// Owner/manager view: pending stock-audit lines for one item.
  Future<List<Map<String, dynamic>>> listPendingStockAuditLinesForItem({
    required String businessId,
    required String itemId,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/stock-audits/pending-lines',
      queryParameters: {'item_id': itemId},
    );

    final data = res.data;
    if (data is! List) return [];
    return [
      for (final e in data)
        if (e is Map<String, dynamic>) e
        else if (e is Map) Map<String, dynamic>.from(e)
    ];
  }


  Future<Map<String, dynamic>> approveStockAuditLine({
    required String businessId,
    required String auditId,
    required String lineId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock-audits/$auditId/lines/$lineId/approve',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getStockAlertsSummary({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/alerts/summary',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getWarehouseAlertsSummary({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/warehouse/alerts-summary',
    );
    return res.data ?? {};
  }


  Future<List<Map<String, dynamic>>> listStockAuditFeed({
    required String businessId,
    int limit = 50,
    String? onDate,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/v1/businesses/$businessId/stock/audit/feed',
      queryParameters: {
        'limit': limit,
        if (onDate != null && onDate.isNotEmpty) 'on': onDate,
      },
    );
    return _parseJsonMapList(res.data);
  }


  Future<Map<String, dynamic>> undoLastStockChange({
    required String businessId,
    required String itemId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/stock/$itemId/undo-last',
    );
    return res.data ?? {};
  }

}
