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

/// Trips after several business API 401s in a short window — stops refetch storms
/// before refresh/logout async work finishes.
class Auth401BurstGuard {
  Auth401BurstGuard({
    this.threshold = 4,
    this.window = const Duration(seconds: 10),
  });

  final int threshold;
  final Duration window;
  int _count = 0;
  DateTime? _since;
  bool _tripped = false;

  bool get tripped => _tripped;

  /// Returns true when the circuit opens (threshold reached).
  bool record401() {
    if (_tripped) return true;
    final now = DateTime.now();
    if (_since == null || now.difference(_since!) > window) {
      _since = now;
      _count = 0;
    }
    _count++;
    if (_count >= threshold) {
      _tripped = true;
      return true;
    }
    return false;
  }

  void reset() {
    _count = 0;
    _since = null;
    _tripped = false;
  }
}

final auth401BurstGuardProvider = Provider<Auth401BurstGuard>(
  (_) => Auth401BurstGuard(),
);

/// True after a burst of 401s — providers must skip API until sign-in again.
final auth401CircuitOpenProvider = Provider<bool>((ref) {
  if (ref.watch(authSessionExpiredProvider)) return true;
  return ref.watch(auth401BurstGuardProvider).tripped;
});

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
