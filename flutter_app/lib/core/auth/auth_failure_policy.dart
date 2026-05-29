import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True after terminal auth failure — forces router to `/login` even briefly
/// before [sessionProvider] clears.
final authSessionExpiredProvider =
    NotifierProvider<AuthSessionExpiredNotifier, bool>(
  AuthSessionExpiredNotifier.new,
);

class AuthSessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markExpired() => state = true;

  void clear() => state = false;
}

/// Tracks refresh failures to avoid infinite 401 polling on stale tokens.
class AuthRefreshFailureTracker {
  AuthRefreshFailureTracker({this.maxFailures = 2, this.window = const Duration(seconds: 60)});

  final int maxFailures;
  final Duration window;
  final List<DateTime> _transientFailures = [];

  void recordTransientFailure() {
    final now = DateTime.now();
    _transientFailures.removeWhere((t) => now.difference(t) > window);
    _transientFailures.add(now);
  }

  void reset() => _transientFailures.clear();

  bool shouldForceLogout() {
    final now = DateTime.now();
    _transientFailures.removeWhere((t) => now.difference(t) > window);
    return _transientFailures.length >= maxFailures;
  }
}

final authRefreshFailureTrackerProvider = Provider<AuthRefreshFailureTracker>(
  (_) => AuthRefreshFailureTracker(),
);

/// Whether authenticated API calls should run (session present + not expired).
bool authAllowsApiRequests({
  required bool hasSession,
  required bool sessionExpired,
}) =>
    hasSession && !sessionExpired;
