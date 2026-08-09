part of 'hexa_api.dart';

mixin HexaApiUsersMethods on HexaApiBase {

  Future<List<Map<String, dynamic>>> listActivityLog({
    required String businessId,
    String period = 'today',
    int page = 1,
    int perPage = 50,
    String? userId,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/activity-log',
      queryParameters: {
        'period': period,
        'page': page,
        'per_page': perPage,
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      },
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<Map<String, dynamic>> postActivityLog({
    required String businessId,
    required String actionType,
    String? itemId,
    String? itemName,
    Map<String, dynamic>? details,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/activity-log',
      data: {
        'action_type': actionType,
        if (itemId != null && itemId.isNotEmpty) 'item_id': itemId,
        if (itemName != null && itemName.isNotEmpty) 'item_name': itemName,
        if (details != null && details.isNotEmpty) 'details': details,
      },
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<List<Map<String, dynamic>>> listBusinessUsers({
    required String businessId,
    bool includeInactive = false,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/users',
      queryParameters: {
        if (includeInactive) 'include_inactive': true,
      },
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Creates staff/manager login. Response may include `generated_password`.

  /// Creates staff/manager login. Response may include `generated_password`.
  Future<Map<String, dynamic>> createBusinessUser({
    required String businessId,
    required String fullName,
    required String email,
    required String phone,
    required String role,
    String? password,
    String? notes,
    bool isActive = true,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users',
      data: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': role,
        'is_active': isActive,
        if (password != null && password.trim().isNotEmpty)
          'password': password.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    return res.data ?? {};
  }


  Future<Map<String, dynamic>> patchBusinessUser({
    required String businessId,
    required String userId,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    bool? isBlocked,
    String? notes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId',
      data: {
        if (fullName != null) 'full_name': fullName.trim(),
        if (email != null) 'email': email.trim().toLowerCase(),
        if (phone != null) 'phone': phone.trim(),
        if (role != null) 'role': role,
        if (isActive != null) 'is_active': isActive,
        if (isBlocked != null) 'is_blocked': isBlocked,
        if (notes != null) 'notes': notes.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<void> deleteBusinessUser({
    required String businessId,
    required String userId,
  }) async {
    await _dio.delete<void>('/v1/businesses/$businessId/users/$userId');
  }


  Future<Map<String, dynamic>> bulkBusinessUsers({
    required String businessId,
    required List<String> userIds,
    required String action,
    String? role,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/bulk',
      data: {
        'user_ids': userIds,
        'action': action,
        if (role != null) 'role': role,
      },
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<Map<String, dynamic>> getUserCredentials({
    required String businessId,
    required String userId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId/credentials',
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<List<Map<String, dynamic>>> listUserActivity({
    required String businessId,
    required String userId,
    int days = 30,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/activity-log',
      queryParameters: {'user_id': userId, 'days': days, 'per_page': 100},
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<List<Map<String, dynamic>>> listUserStockAdjustments({
    required String businessId,
    required String userId,
    int limit = 50,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/users/$userId/stock-adjustments',
      queryParameters: {'limit': limit},
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<List<Map<String, dynamic>>> listUserPurchases({
    required String businessId,
    required String userId,
    int limit = 50,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/users/$userId/purchases',
      queryParameters: {'limit': limit},
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<List<Map<String, dynamic>>> listUserLedger({
    required String businessId,
    required String userId,
    int limit = 80,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/users/$userId/ledger',
      queryParameters: {'limit': limit},
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<Map<String, dynamic>> listUserLedgerGrouped({
    required String businessId,
    required String userId,
    int limit = 80,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId/ledger',
      queryParameters: {'limit': limit, 'grouped': true},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<List<Map<String, dynamic>>> listUserCreatedItems({
    required String businessId,
    required String userId,
    int limit = 50,
  }) async {
    final res = await _dio.get<dynamic>(
      '/v1/businesses/$businessId/users/$userId/created-items',
      queryParameters: {'limit': limit},
    );
    final data = res.data;
    if (data is! List) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }


  Future<Map<String, dynamic>> getUserPermissions({
    required String businessId,
    required String userId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId/permissions',
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<Map<String, dynamic>> patchUserPermissions({
    required String businessId,
    required String userId,
    required Map<String, bool> permissions,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId/permissions',
      data: {'permissions': permissions},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<Map<String, dynamic>> getBusinessUser({
    required String businessId,
    required String userId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId',
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<Map<String, dynamic>> resetBusinessUserPassword({
    required String businessId,
    required String userId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/users/$userId/reset-password',
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<Map<String, dynamic>> superAdminHealth() async {
    final res = await _dio.get<Map<String, dynamic>>('/v1/admin/health');
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<Map<String, dynamic>> superAdminBusinessesOverview(
      {int limit = 100}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/admin/businesses-overview',
      queryParameters: {'limit': limit},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  /// Idempotent: ensure default workspace + catalog/supplier seed (single-tenant).
  /// Returns body JSON: `business_id`, `created_business`, `seeded`, optional `seed_stats`.
  /// Returns null when the server has no route (older API: 404/501) so session boot can continue.

  /// Idempotent: ensure default workspace + catalog/supplier seed (single-tenant).
  /// Returns body JSON: `business_id`, `created_business`, `seeded`, optional `seed_stats`.
  /// Returns null when the server has no route (older API: 404/501) so session boot can continue.
  Future<Map<String, dynamic>?> bootstrapWorkspace() async {
    try {
      final res =
          await _dio.post<Map<String, dynamic>>('/v1/me/bootstrap-workspace');
      final d = res.data;
      if (d is Map) return Map<String, dynamic>.from(d as Map);
      return null;
    } on DioException catch (e) {
      final sc = e.response?.statusCode;
      if (sc == 404 || sc == 501) {
        debugPrint(
            'hexa: bootstrap-workspace not available (HTTP $sc) — continuing without server seed');
        return null;
      }
      rethrow;
    }
  }

  /// Owner: optional in-app title + logo URL (HTTPS recommended).

  /// Owner: optional in-app title + logo URL (HTTPS recommended).
  Future<Map<String, dynamic>> patchBusinessBranding({
    required String businessId,
    String? name,
    String? brandingTitle,
    String? brandingLogoUrl,
    String? gstNumber,
    String? address,
    String? phone,

    /// When true, always sends [contactEmail] (use empty string to clear).
    bool includeContactEmail = false,
    String? contactEmail,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/me/businesses/$businessId/branding',
      data: {
        if (name != null) 'name': name,
        if (brandingTitle != null) 'branding_title': brandingTitle,
        if (brandingLogoUrl != null) 'branding_logo_url': brandingLogoUrl,
        if (gstNumber != null) 'gst_number': gstNumber,
        if (address != null) 'address': address,
        if (phone != null) 'phone': phone,
        if (includeContactEmail) 'contact_email': (contactEmail ?? '').trim(),
      },
    );
    return res.data ?? {};
  }

  /// Owner: multipart logo upload (JPEG/PNG/WebP).

  /// Owner: multipart logo upload (JPEG/PNG/WebP).
  Future<Map<String, dynamic>> uploadBusinessLogo({
    required String businessId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/me/businesses/$businessId/branding/logo',
      data: formData,
    );
    return res.data ?? {};
  }

  /// Same as [uploadBusinessLogo] but from bytes (web-friendly).

  /// Same as [uploadBusinessLogo] but from bytes (web-friendly).
  Future<Map<String, dynamic>> uploadBusinessLogoBytes({
    required String businessId,
    required List<int> bytes,
    String filename = 'logo.jpg',
  }) async {
    final lower = filename.toLowerCase();
    final MediaType ct;
    if (lower.endsWith('.png')) {
      ct = MediaType('image', 'png');
    } else if (lower.endsWith('.webp')) {
      ct = MediaType('image', 'webp');
    } else {
      ct = MediaType('image', 'jpeg');
    }
    final formData = FormData.fromMap({
      'file':
          MultipartFile.fromBytes(bytes, filename: filename, contentType: ct),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/me/businesses/$businessId/branding/logo',
      data: formData,
    );
    return res.data ?? {};
  }

}
