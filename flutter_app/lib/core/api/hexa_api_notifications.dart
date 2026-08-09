part of 'hexa_api.dart';

mixin HexaApiNotificationsMethods on HexaApiBase {

  Future<List<Map<String, dynamic>>> listAppNotifications({
    required String businessId,
    int page = 1,
    int perPage = 50,
    bool fetchAllPages = true,
    String? kind,
  }) async {
    final out = <Map<String, dynamic>>[];
    var p = page;
    const maxPages = 20;
    while (p <= maxPages) {
      final res = await _dio.get<dynamic>(
        '/v1/businesses/$businessId/notifications',
        queryParameters: {
          'page': p,
          'per_page': perPage,
          if (kind != null && kind.trim().isNotEmpty) 'kind': kind.trim(),
        },
      );
      final chunk = _parseNotificationListPayload(res.data);
      if (chunk.isEmpty) break;
      out.addAll(chunk);
      if (!fetchAllPages || chunk.length < perPage) break;
      p++;
    }
    return out;
  }


  static List<Map<String, dynamic>> _parseNotificationListPayload(
      dynamic data) {
    if (data is List) {
      return [
        for (final e in data)
          if (e is Map) Map<String, dynamic>.from(e),
      ];
    }
    if (data is Map) {
      for (final key in ['items', 'notifications', 'data', 'results']) {
        final raw = data[key];
        if (raw is List) {
          return [
            for (final e in raw)
              if (e is Map) Map<String, dynamic>.from(e),
          ];
        }
      }
    }
    return [];
  }


  Future<int> appNotificationUnreadCount({required String businessId}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/notifications/unread-count',
    );
    final u = res.data?['unread'];
    if (u is int) return u;
    if (u is num) return u.round();
    return 0;
  }


  Future<Map<String, dynamic>> patchAppNotificationRead({
    required String businessId,
    required String notificationId,
    bool read = true,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/v1/businesses/$businessId/notifications/$notificationId',
      data: {'read': read},
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<int> markAllAppNotificationsRead({
    required String businessId,
    String? kind,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/notifications/mark-all-read',
      queryParameters: {
        if (kind != null && kind.trim().isNotEmpty) 'kind': kind.trim(),
      },
    );
    final v = res.data?['updated'];
    return v is num ? v.toInt() : 0;
  }


  Future<int> clearAllAppNotifications({
    required String businessId,
    String? kind,
  }) async {
    final res = await _dio.delete<Map<String, dynamic>>(
      '/v1/businesses/$businessId/notifications/clear-all',
      queryParameters: {
        if (kind != null && kind.trim().isNotEmpty) 'kind': kind.trim(),
      },
    );
    final v = res.data?['updated'];
    return v is num ? v.toInt() : 0;
  }


  Future<Map<String, dynamic>> appNotificationsSummary({
    required String businessId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/businesses/$businessId/notifications/summary',
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }


  Future<int> postClientNotificationEvent({
    required String businessId,
    required String kind,
    required String title,
    String? body,
    String? priority,
    String? category,
    String? actionRoute,
    String? dedupeKey,
    String? relatedPurchaseId,
    String? relatedItemId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/businesses/$businessId/notifications/client-event',
      data: {
        'kind': kind,
        'title': title,
        if (body != null) 'body': body,
        if (priority != null) 'priority': priority,
        if (category != null) 'category': category,
        if (actionRoute != null) 'action_route': actionRoute,
        if (dedupeKey != null) 'dedupe_key': dedupeKey,
        if (relatedPurchaseId != null) 'related_purchase_id': relatedPurchaseId,
        if (relatedItemId != null) 'related_item_id': relatedItemId,
      },
    );
    final v = res.data?['updated'];
    return v is num ? v.toInt() : 0;
  }

}
