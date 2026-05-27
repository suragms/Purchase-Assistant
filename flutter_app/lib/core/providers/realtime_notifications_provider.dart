import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_notifier.dart';
import 'business_aggregates_invalidation.dart';
import 'realtime_events_provider.dart';

/// Faster refresh while notifications surfaces are watched (SSE fallback).
final realtimeNotificationsBoostProvider =
    Provider.autoDispose<void>((ref) {
  ref.watch(realtimeInvalidationProvider);
  final session = ref.watch(sessionProvider);
  if (session == null) return;

  final timer = Timer.periodic(const Duration(seconds: 15), (_) {
    invalidateNotificationSurfaces(ref);
  });
  ref.onDispose(timer.cancel);
});
