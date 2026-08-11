import 'package:flutter/material.dart';

/// Owner-rail secondary destinations (UX-196, UX-197).
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
/// desktop rail, ≥ [kDesktopMin]). UX-197 renamed it from "Library" because the
/// group now spans settings/notifications, not just catalog content.
const String ownerShellSecondaryCaption = 'Manage';

/// Catalog, Contacts, Barcode tools, Notifications, Settings, Help & guide —
/// the owner features with routes that had no labeled rail/menu entry before
/// UX-196/UX-197. They are overlay pushes, never shell branches.
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
    label: 'Barcode tools',
    route: '/barcode/scan',
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner_rounded,
  ),
  (
    label: 'Notifications',
    route: '/notifications',
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications_rounded,
  ),
  (
    label: 'Settings',
    route: '/settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
  ),
  (
    label: 'Help & guide',
    route: '/settings/help',
    icon: Icons.help_outline_rounded,
    selectedIcon: Icons.help_rounded,
  ),
];

/// 0-based index of the Notifications entry in [ownerShellSecondaryDestinations].
/// The shell uses it to attach the live unread-count badge to that one item.
const int ownerShellSecondaryNotificationsIndex = 3;

/// Route pushed for the 0-based index into [ownerShellSecondaryDestinations].
String ownerShellSecondaryRouteForIndex(int index) =>
    ownerShellSecondaryDestinations[index].route;
