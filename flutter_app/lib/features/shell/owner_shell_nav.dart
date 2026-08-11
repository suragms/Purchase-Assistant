import 'package:flutter/material.dart';

/// Owner-rail secondary destinations (UX-196).
///
/// These are full-screen overlay PUSHES — NOT shell branches. They must never
/// be added to the primary [WebCompactSideNav] destinations list: the owner
/// shell clamps its selectedIndex to [ShellBranch.home..ShellBranch.search]
/// and `shellBranchIndexForPath` deliberately returns null for these routes.
typedef OwnerShellSecondaryDestination = ({
  String label,
  String route,
  IconData icon,
  IconData selectedIcon,
});

/// Caption above the owner-rail secondary group (shown only on the labeled
/// desktop rail, ≥ [kDesktopMin]).
const String ownerShellSecondaryCaption = 'Library';

/// Catalog, Contacts, Barcode — the owner features with routes that had no
/// rail/menu entry point on desktop before UX-196.
const List<OwnerShellSecondaryDestination> ownerShellSecondaryDestinations = [
  (
    label: 'Catalog',
    route: '/catalog',
    icon: Icons.category_outlined,
    selectedIcon: Icons.category_rounded,
  ),
  (
    label: 'Contacts',
    route: '/contacts',
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups_rounded,
  ),
  (
    label: 'Barcode',
    route: '/barcode/scan',
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner_rounded,
  ),
];

/// Route pushed for the 0-based index into [ownerShellSecondaryDestinations].
String ownerShellSecondaryRouteForIndex(int index) =>
    ownerShellSecondaryDestinations[index].route;
