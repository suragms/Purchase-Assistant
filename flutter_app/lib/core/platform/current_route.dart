/// Lightweight global route tracker — updated by GoRouter [redirect] so
/// error-reporting sinks can read the current route without a [BuildContext].
class CurrentRoute {
  CurrentRoute._();

  static String _path = '/(unknown)';

  /// Latest path reported by GoRouter [redirect].
  static String get path => _path;

  /// Called from [GoRouter.redirect] on every navigation.
  static void update(String path) {
    _path = path.isEmpty ? '/(empty)' : path;
  }
}
