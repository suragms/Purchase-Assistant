import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/design_system/hexa_responsive.dart';
import '../../../core/providers/notification_center_provider.dart'
    show notificationCenterCoordinatorProvider;
import '../../../core/providers/notifications_provider.dart';
import '../../../core/providers/api_degraded_provider.dart';
import '../../../core/providers/staff_home_providers.dart'
    show staffPendingDeliveryCountProvider;
import '../../../core/theme/hexa_colors.dart';
import '../../../core/widgets/hexa_count_badge.dart';
import '../../shell/app_shell.dart';
import '../../shell/business_write_stock_listener.dart';
import '../../shell/shell_realtime_listener.dart';
import '../../shell/web_compact_side_nav.dart';
import 'widgets/staff_shell_auto_refresh_listener.dart';
import '../staff_shell_branch_provider.dart';
import '../staff_shell_nav.dart';

/// Staff shell: Home | Stock | Scan | Search — same offline banner pattern as [ShellScreen].
class StaffShellScreen extends ConsumerStatefulWidget {
  const StaffShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<StaffShellScreen> createState() => _StaffShellScreenState();
}

class _StaffShellScreenState extends ConsumerState<StaffShellScreen> {
  @override
  void initState() {
    super.initState();
    _syncStaffBranch(widget.navigationShell.currentIndex);
  }

  @override
  void didUpdateWidget(StaffShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idx = widget.navigationShell.currentIndex;
    if (oldWidget.navigationShell.currentIndex != idx) {
      _syncStaffBranch(idx);
    }
  }

  void _syncStaffBranch(int idx) {
    if (!mounted) return;
    if (ref.read(staffShellCurrentBranchProvider) == idx) return;
    // Branch index only — do not invalidate providers here (caused full
    // reload/skeleton flash every time staff switched Home ↔ Stock).
    ref.read(staffShellCurrentBranchProvider.notifier).state = idx;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationCenterCoordinatorProvider);
    final navigationShell = widget.navigationShell;
    final idx = navigationShell.currentIndex;
    if (ref.read(staffShellCurrentBranchProvider) != idx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncStaffBranch(idx);
      });
    }
    final routePath = GoRouter.maybeOf(context)?.state.uri.path ?? '/staff/home';
    final pathBranch = staffShellBranchIndexForPath(routePath);
    if (pathBranch != null && pathBranch != idx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(staffShellCurrentBranchProvider.notifier).state = pathBranch;
        navigationShell.goBranch(pathBranch);
      });
    } else if (routePath == '/staff/home' && idx != StaffShellBranch.home) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(staffShellCurrentBranchProvider.notifier).state =
            StaffShellBranch.home;
        navigationShell.goBranch(StaffShellBranch.home);
      });
    }

    final sessionHint = ref.watch(apiDegradedProvider);
    final width = MediaQuery.sizeOf(context).width;
    // width==0 (web first frame): keep bottom bar so chrome is not fully blank.
    // Phone/desktop thresholds unchanged once MediaQuery has a real size.
    final showRail = width > 0 && width >= kShellRailMin;
    final showBottomBar = width <= 0 || width < kShellBottomNavMax;
    final notifN = ref.watch(notificationsUnreadCountProvider);
    final pendingDel = ref.watch(staffPendingDeliveryCountProvider);

    void go(int branch) {
      HapticFeedback.selectionClick();
      _syncStaffBranch(branch);
      navigationShell.goBranch(branch);
    }

    // NavigationRail asserts selectedIndex is in [0, destinations.length).
    final navSelectedIndex =
        idx.clamp(StaffShellBranch.home, StaffShellBranch.tasks);

    final staffRail = WebCompactSideNav(
      selectedIndex: navSelectedIndex,
      onDestinationSelected: go,
      showLabels: width >= kDesktopMin,
      destinations: [
        for (var branch = StaffShellBranch.home;
            branch <= StaffShellBranch.tasks;
            branch++)
          WebCompactSideNavItem(
            icon: staffShellNavIcon(branch, selected: false),
            selectedIcon: staffShellNavIcon(branch, selected: true),
            label: staffShellNavLabel(branch),
            badgeCount:
                branch == StaffShellBranch.deliveries ? pendingDel : 0,
          ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Notifications',
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: notifN > 0
                  ? Badge(
                      label: Text(notifN > 99 ? '99+' : '$notifN'),
                      child: const Icon(Icons.notifications_outlined),
                    )
                  : const Icon(Icons.notifications_outlined),
            ),
          ),
          Tooltip(
            message: 'Help & guide',
            child: IconButton(
              onPressed: () => context.push('/settings/help'),
              icon: const Icon(Icons.help_outline_rounded),
            ),
          ),
        ],
      ),
    );

    return BusinessWriteStockListener(
      child: ShellRealtimeListener(
        child: StaffShellAutoRefreshListener(
          child: SizedBox.expand(
        child: Material(
          key: const ValueKey<String>('staff_shell'),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showRail)
                  SizedBox(
                    width: width >= kDesktopMin
                        ? kShellLabeledRailWidth
                        : kShellCompactRailWidth,
                    child: staffRail,
                  ),
                Expanded(
                  child: AppShellBody(
                    navigationShell: navigationShell,
                    topBanners: [
                      if (sessionHint != null)
                        Material(
                          color: const Color(0xFFFFEBEE),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: HexaDsLayout.pageGutter,
                              vertical: HexaDsSpace.xs + 2,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_reset_rounded,
                                    size: 18, color: HexaColors.materialRed),
                                const SizedBox(width: HexaDsLayout.inlineGap),
                                Expanded(
                                  child: Text(
                                    sessionHint,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: const Color(0xFF7F1D1D),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          height: 1.25,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    bottomBar: showBottomBar
                        ? _StaffShellBottomBar(
                            selectedIndex: navSelectedIndex,
                            pendingDeliveryCount: pendingDel,
                            onDestinationSelected: go,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            if (idx != StaffShellBranch.home &&
                idx != StaffShellBranch.scan &&
                idx != StaffShellBranch.search &&
                idx != StaffShellBranch.stock &&
                routePath != '/notifications' &&
                !routePath.startsWith('/catalog/item/'))
              Positioned(
                right: 16,
                bottom: 68 + MediaQuery.viewPaddingOf(context).bottom,
                child: FloatingActionButton.small(
                  heroTag: 'staff_scan_fab',
                  tooltip: 'Scan barcode',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    navigationShell.goBranch(StaffShellBranch.scan);
                  },
                  child: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                ),
              ),
          ],
        ),
      ),
        ),
      ),
      ),
    );
  }
}

class _StaffShellBottomBar extends StatelessWidget {
  const _StaffShellBottomBar({
    required this.selectedIndex,
    required this.pendingDeliveryCount,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final int pendingDeliveryCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad =
        6.0 + math.max(0.0, MediaQuery.viewPaddingOf(context).bottom * 0.2);
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPad),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            color: cs.surface.withValues(alpha: 0.90),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
                child: Row(
                  children: [
                    for (final branch in staffShellBottomPrimaryBranches)
                      Expanded(
                        child: _StaffNavTile(
                          selected: selectedIndex == branch,
                          icon: staffShellNavIcon(branch, selected: false),
                          selectedIcon:
                              staffShellNavIcon(branch, selected: true),
                          label: staffShellNavLabel(branch),
                          badge: branch == StaffShellBranch.deliveries
                              ? pendingDeliveryCount
                              : null,
                          badgeColor: branch == StaffShellBranch.deliveries
                              ? HexaColors.accentOrangeMid
                              : null,
                          onTap: () => onDestinationSelected(branch),
                        ),
                      ),
                    Expanded(
                      child: _StaffNavTile(
                        selected: staffShellBranchIsInMoreMenu(selectedIndex),
                        icon: Icons.more_horiz_rounded,
                        selectedIcon: Icons.more_horiz_rounded,
                        label: 'More',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showStaffShellMoreNavSheet(
                            context: context,
                            currentBranch: selectedIndex,
                            onBranchSelected: onDestinationSelected,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StaffNavTile extends StatelessWidget {
  const _StaffNavTile({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
    this.badge,
    this.badgeColor,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;
  final int? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ic = selected ? selectedIcon : icon;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: HexaResponsive.minTouchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? HexaColors.brandPrimary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: HexaCountBadge(
                  count: badge,
                  backgroundColor: badgeColor ?? HexaDsColors.error,
                  child: Icon(
                    ic,
                    size: 24,
                    color:
                        selected ? HexaColors.brandPrimary : cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      selected ? HexaColors.brandPrimary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
