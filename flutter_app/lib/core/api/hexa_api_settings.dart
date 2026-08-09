part of 'hexa_api.dart';

mixin HexaApiSettingsMethods on HexaApiBase {

  /// Unified catalog items + suppliers + entries (server-side substring match).
  Future<Map<String, dynamic>> unifiedSearch({
    required String businessId,
    required String q,

    /// Boosts catalog rows bought from this supplier (trade history + last_supplier_id).
    String? supplierId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/search',
      queryParameters: {
        'q': q,
        if (supplierId != null && supplierId.trim().isNotEmpty)
          'supplier_id': supplierId.trim(),
      },
    );
    return res.data ?? {};
  }

  /// GET `/trade-purchases` caps `limit` at 50; larger values are fetched in pages.

  /// JSON bundle: catalog, suppliers, 90-day purchases, stock audits.
  Future<Uint8List> downloadBusinessBackupJson({
    required String businessId,
  }) async {
    final res = await _dio.get<List<int>>(
      '/v1/businesses/$businessId/exports/backup/export',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    final raw = res.data;
    if (raw == null) return Uint8List(0);
    return Uint8List.fromList(raw);
  }


  Future<Map<String, dynamic>> listServerBackupLogs({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/exports/backup/logs',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> runServerBackupNow({
    required String businessId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/exports/backup/run',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> listProviderCredentials({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/settings/credentials',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> putProviderCredential({
    required String businessId,
    required String credentialType,
    required String value,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/v1/businesses/$businessId/settings/credentials/$credentialType',
      data: {'value': value},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> fetchOwnerDashboard({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/owner/dashboard',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> listStaffTasks({
    required String businessId,
    String? status,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/staff/tasks',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status_filter': status,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> createStaffTask({
    required String businessId,
    required String staffId,
    String taskType = 'general',
    String? referenceId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/staff/tasks',
      data: {
        'staff_id': staffId,
        'task_type': taskType,
        if (referenceId != null && referenceId.isNotEmpty)
          'reference_id': referenceId,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> acceptStaffTask({
    required String businessId,
    required String taskId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/staff/tasks/$taskId/accept',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> completeStaffTask({
    required String businessId,
    required String taskId,
    bool rejected = false,
    String? correctionNote,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/staff/tasks/$taskId/complete',
      data: {
        'rejected': rejected,
        if (correctionNote != null && correctionNote.isNotEmpty)
          'correction_note': correctionNote,
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> listBackupLogs({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/exports/backup/logs',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> runServerBackup({
    required String businessId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/exports/backup/run',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> restoreDryRun({
    required String businessId,
    required Map<String, dynamic> payload,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/exports/restore/dry-run',
      data: {'payload': payload},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> listWhatsappDeliveries({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/owner/whatsapp-deliveries',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> resendWhatsappDelivery({
    required String businessId,
    required String poId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/owner/whatsapp-deliveries/$poId/resend',
    );
    return res.data ?? {};
  }

  /// ZIP: purchase summary PDF, per-bill PDFs, supplier ledger PDFs, stock Excel.

  /// ZIP: purchase summary PDF, per-bill PDFs, supplier ledger PDFs, stock Excel.
  Future<Uint8List> downloadBusinessBackup({
    required String businessId,
    String rangePreset = 'month',
  }) async {
    final res = await _dio.post<List<int>>(
      '/v1/businesses/$businessId/exports/backup',
      data: {'range_preset': rangePreset},
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    final raw = res.data;
    if (raw == null) return Uint8List(0);
    return Uint8List.fromList(raw);
  }

  /// Server-built stock inventory Excel (all catalog items).

  /// Server-built PDF of trade purchases for the current calendar month.
  Future<Uint8List> downloadPurchasesMonthPdf({
    required String businessId,
  }) async {
    final res = await _dio.get<List<int>>(
      '/v1/businesses/$businessId/exports/purchases-month.pdf',
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    final raw = res.data;
    if (raw == null) return Uint8List(0);
    return Uint8List.fromList(raw);
  }


  Future<Map<String, dynamic>> getChecklistToday({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/operations/checklist/today',
    );
    return res.data ?? {};
  }


  Future<List<Map<String, dynamic>>> getChecklistTemplates({
    required String businessId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/v1/businesses/$businessId/operations/checklist/templates',
    );
    return _parseJsonMapList(res.data);
  }


  Future<List<Map<String, dynamic>>> putChecklistTemplates({
    required String businessId,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final res = await _dio.put<List<dynamic>>(
      '/v1/businesses/$businessId/operations/checklist/templates',
      data: {'tasks': tasks},
    );
    return _parseJsonMapList(res.data);
  }


  Future<void> completeChecklistTask({
    required String businessId,
    required String slot,
    required String taskKey,
    String? notes,
  }) async {
    await _dio.post<void>(
      '/v1/businesses/$businessId/operations/checklist/$slot/complete',
      data: {'task_key': taskKey, if (notes != null) 'notes': notes},
    );
  }


  Future<Map<String, dynamic>> getUsageToday({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/operations/usage/today',
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> submitUsageToday({
    required String businessId,
    required List<Map<String, dynamic>> lines,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/operations/usage/today',
      data: {'lines': lines},
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> getChecklistSummary({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/operations/checklist/summary',
    );
    return res.data ?? {};
  }


  Future<List<Map<String, dynamic>>> listDailySnapshots({
    required String businessId,
    String? fromDate,
    String? toDate,
    String? itemId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/v1/businesses/$businessId/operations/snapshots',
      queryParameters: {
        if (fromDate != null) 'from_date': fromDate,
        if (toDate != null) 'to_date': toDate,
        if (itemId != null) 'item_id': itemId,
      },
    );
    return _parseJsonMapList(res.data);
  }

}
