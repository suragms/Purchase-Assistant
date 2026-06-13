import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/app_foreground_provider.dart';
import 'auth_failure_policy.dart';
import 'session_notifier.dart' show activeSessionProvider;

/// Skip network fetches when logged out or after terminal 401 (stops request storms).
/// Accepts provider [Ref] and widget [WidgetRef] (different types in Riverpod 2.6).
bool providerSkipApi(dynamic ref) {
  if (ref.read(authBlockApiRequestsProvider)) return true;
  if (ref.read(auth401CircuitOpenProvider)) return true;
  if (!ref.read(appForegroundProvider)) return true;
  if (ref.read(activeSessionProvider) == null) return true;
  return false;
}

/// Wait for resume JWT / 401 gate to clear before item-detail fetches (avoids false "load failed").
Future<void> awaitProviderApiReady(
  dynamic ref, {
  Duration maxWait = const Duration(seconds: 3),
}) async {
  if (!providerSkipApi(ref)) return;
  final deadline = DateTime.now().add(maxWait);
  while (providerSkipApi(ref)) {
    if (DateTime.now().isAfter(deadline)) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }
}
