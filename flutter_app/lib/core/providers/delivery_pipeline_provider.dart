import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';

/// Owner dashboard: counts per delivery_status from API.
final deliveryPipelineProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return {};
  return ref.read(hexaApiProvider).fetchDeliveryPipeline(
        businessId: session.primaryBusiness.id,
      );
});
