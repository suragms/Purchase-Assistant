import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/router/shell_navigation.dart';
import 'package:harisree_warehouse/features/shell/owner_shell_nav.dart';
import 'package:harisree_warehouse/features/shell/web_compact_side_nav.dart';

void main() {
  test('secondary destinations are exactly Catalog, Contacts, Barcode', () {
    expect(ownerShellSecondaryDestinations.length, 3);
    expect(
      ownerShellSecondaryDestinations.map((d) => d.label).toList(),
      ['Catalog', 'Contacts', 'Barcode'],
    );
  });

  test('secondary routes resolve in index order', () {
    expect(ownerShellSecondaryRouteForIndex(0), '/catalog');
    expect(ownerShellSecondaryRouteForIndex(1), '/contacts');
    expect(ownerShellSecondaryRouteForIndex(2), '/barcode/scan');
  });

  test('caption is Library', () {
    expect(ownerShellSecondaryCaption, 'Library');
  });

  test('secondary destinations are overlays, never shell branches', () {
    for (final d in ownerShellSecondaryDestinations) {
      expect(shellIsPushedModalPath(d.route), isTrue,
          reason: '${d.route} must stay a pushed overlay');
      expect(shellBranchIndexForPath(d.route), isNull,
          reason: '${d.route} must never join the primary branch list');
    }
  });

  testWidgets('labeled rail renders secondary group and fires callback',
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
            secondaryDestinations: const [
              WebCompactSideNavItem(
                icon: Icons.category_outlined,
                selectedIcon: Icons.category_rounded,
                label: 'Catalog',
              ),
              WebCompactSideNavItem(
                icon: Icons.groups_outlined,
                selectedIcon: Icons.groups_rounded,
                label: 'Contacts',
              ),
              WebCompactSideNavItem(
                icon: Icons.qr_code_scanner_outlined,
                selectedIcon: Icons.qr_code_scanner_rounded,
                label: 'Barcode',
              ),
            ],
            onSecondaryDestinationSelected: (i) => tapped = i,
          ),
        ),
      ),
    );

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Barcode'), findsOneWidget);

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

    expect(find.text('Library'), findsNothing);
    // Secondary items are never selected, so they show their outlined icon.
    expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    // Primary destination 0 is selected here, so it renders its selected icon.
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });
}
