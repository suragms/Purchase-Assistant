import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/design_system/hexa_desktop_layout.dart'
    show DesktopSideNavFooter;
import 'package:harisree_warehouse/core/router/shell_navigation.dart';
import 'package:harisree_warehouse/features/shell/owner_shell_nav.dart';
import 'package:harisree_warehouse/features/shell/web_compact_side_nav.dart';

void main() {
  test('secondary destinations are the 6 owner features in order', () {
    expect(
      ownerShellSecondaryDestinations.map((d) => d.label).toList(),
      [
        'Catalog',
        'Contacts',
        'Barcode tools',
        'Notifications',
        'Settings',
        'Help & guide',
      ],
    );
  });

  test('secondary routes resolve in index order', () {
    expect(ownerShellSecondaryRouteForIndex(0), '/catalog');
    expect(ownerShellSecondaryRouteForIndex(1), '/contacts');
    expect(ownerShellSecondaryRouteForIndex(2), '/barcode/scan');
    expect(ownerShellSecondaryRouteForIndex(3), '/notifications');
    expect(ownerShellSecondaryRouteForIndex(4), '/settings');
    expect(ownerShellSecondaryRouteForIndex(5), '/settings/help');
  });

  test('caption is Manage', () {
    expect(ownerShellSecondaryCaption, 'Manage');
  });

  test('Notifications entry is at the badge index', () {
    expect(
      ownerShellSecondaryDestinations[ownerShellSecondaryNotificationsIndex]
          .label,
      'Notifications',
    );
  });

  test('secondary destinations are overlays, never shell branches', () {
    for (final d in ownerShellSecondaryDestinations) {
      expect(shellIsPushedModalPath(d.route), isTrue,
          reason: '${d.route} must stay a pushed overlay');
      expect(shellBranchIndexForPath(d.route), isNull,
          reason: '${d.route} must never join the primary branch list');
    }
  });

  testWidgets('labeled rail renders secondary group, badge, and fires callback',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WebCompactSideNav(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            showLabels: true,
            destinations: const [
              WebCompactSideNavItem(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
                label: 'Home',
              ),
            ],
            secondaryLabel: ownerShellSecondaryCaption,
            secondaryDestinations: [
              for (var i = 0;
                  i < ownerShellSecondaryDestinations.length;
                  i++)
                WebCompactSideNavItem(
                  icon: ownerShellSecondaryDestinations[i].icon,
                  selectedIcon: ownerShellSecondaryDestinations[i].selectedIcon,
                  label: ownerShellSecondaryDestinations[i].label,
                  badgeCount:
                      i == ownerShellSecondaryNotificationsIndex ? 5 : 0,
                ),
            ],
            onSecondaryDestinationSelected: (i) => tapped = i,
          ),
        ),
      ),
    );

    expect(find.text('Manage'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Barcode tools'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    // Live badge from the notifications index — exactly one badge renders
    // (only index == ownerShellSecondaryNotificationsIndex carries a count).
    expect(find.text('5'), findsOneWidget);
    expect(find.byType(Badge), findsOneWidget);

    await tester.tap(find.text('Contacts'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('compact rail hides caption but keeps secondary icons',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WebCompactSideNav(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            showLabels: false,
            destinations: const [
              WebCompactSideNavItem(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
                label: 'Home',
              ),
            ],
            secondaryLabel: ownerShellSecondaryCaption,
            secondaryDestinations: const [
              WebCompactSideNavItem(
                icon: Icons.category_outlined,
                selectedIcon: Icons.category_rounded,
                label: 'Catalog',
              ),
            ],
            onSecondaryDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Manage'), findsNothing);
    // Secondary items are never selected, so they show their outlined icon.
    expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    // Primary destination 0 is selected here, so it renders its selected icon.
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });

  testWidgets('showLabels auto-resolves from width when not provided',
      (tester) async {
    // Pin the test view to DPR 1.0 so the logical width equals the asserted
    // breakpoint (the default test DPR of 3.0 would turn 1440px into 480px).
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget build() => MaterialApp(
          home: Scaffold(
            body: WebCompactSideNav(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                WebCompactSideNavItem(
                  icon: Icons.grid_view_outlined,
                  selectedIcon: Icons.grid_view_rounded,
                  label: 'Home',
                ),
              ],
            ),
          ),
        );

    // No showLabels passed → labeled rail at desktop width (reads as a menu).
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpWidget(build());
    expect(find.text('Home'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

    // Same widget at compact width → icon-only, no label text. Primary is
    // still selected (index 0), so it renders its rounded selected icon.
    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpWidget(build());
    expect(find.text('Home'), findsNothing);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });

  testWidgets('footer renders business and role context', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WebCompactSideNav(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            showLabels: true,
            destinations: const [
              WebCompactSideNavItem(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view_rounded,
                label: 'Home',
              ),
            ],
            secondaryLabel: ownerShellSecondaryCaption,
            secondaryDestinations: const [
              WebCompactSideNavItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'Settings',
              ),
            ],
            onSecondaryDestinationSelected: (_) {},
            footer: const DesktopSideNavFooter(
              businessName: 'Hexa Warehouse',
              roleLabel: 'Owner',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hexa Warehouse'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    // The footer owns no icons here (they moved into the group) — only the
    // secondary Settings item renders its outlined icon.
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
  });
}
