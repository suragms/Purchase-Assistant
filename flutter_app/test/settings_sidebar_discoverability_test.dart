import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/settings/presentation/settings_page.dart';

void main() {
  test('owner/admin sidebar includes credentials and command center', () {
    final tiles = settingsSidebarShortcuts(
      showBackup: true,
      isOwnerOrAdmin: true,
      canManageUsers: true,
    );
    final routes = tiles.map((t) => t.route).toList();
    expect(routes, contains('/settings/business'));
    expect(routes, contains('/settings/users'));
    expect(routes, contains('/settings/backup'));
    expect(routes, contains('/settings/credentials'));
    expect(routes, contains('/settings/owner-dashboard'));
    expect(routes.first, '/settings/help');
    expect(tiles.map((t) => t.label), contains('API credentials'));
    expect(tiles.map((t) => t.label), contains('Command center'));
  });

  test('staff-facing sidebar omits owner tools', () {
    final tiles = settingsSidebarShortcuts(
      showBackup: false,
      isOwnerOrAdmin: false,
      canManageUsers: false,
    );
    final routes = tiles.map((t) => t.route).toList();
    expect(routes.first, '/settings/help');
    expect(routes, contains('/settings/business'));
    expect(routes, isNot(contains('/settings/credentials')));
    expect(routes, isNot(contains('/settings/owner-dashboard')));
    expect(routes, isNot(contains('/settings/backup')));
    expect(routes, isNot(contains('/settings/users')));
  });
}
