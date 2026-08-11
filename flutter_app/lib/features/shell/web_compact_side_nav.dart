import 'package:flutter/material.dart';

import '../../core/design_system/hexa_responsive.dart';
import '../../core/theme/hexa_colors.dart';

/// Fixed-width side nav for Flutter **web**.
///
/// [NavigationRail] has repeatedly blanked the shell body on wide viewports
/// (unconstrained / overflow width → [Expanded] content at 0×). This widget
/// never grows past a hard-capped width ([kShellCompactRailWidth] or
/// [kShellLabeledRailWidth]).
///
/// At ≥ [kDesktopMin] shows icon + label; below that, icon-only with tooltip.
class WebCompactSideNav extends StatelessWidget {
  const WebCompactSideNav({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
    this.footer,
    this.showLabels,
    this.secondaryLabel,
    this.secondaryDestinations = const [],
    this.onSecondaryDestinationSelected,
  });

  final int selectedIndex;
  final List<WebCompactSideNavItem> destinations;
  final ValueChanged<int> onDestinationSelected;
  final Widget? footer;

  /// When null, auto-resolve from [MediaQuery]: labels render at ≥ [kDesktopMin]
  /// so the rail reads as a real menu, not icon-only. Callers may pass an
  /// explicit value to override (both the owner and staff shells do).
  final bool? showLabels;

  /// Caption above the optional secondary group (only shown when [showLabels]).
  final String? secondaryLabel;

  /// Optional secondary items rendered below the primary destinations.
  /// These are overlay PUSHES, not shell branches — never given a selection
  /// index, and never counted toward the primary [selectedIndex] clamp.
  final List<WebCompactSideNavItem> secondaryDestinations;

  /// Fires with the 0-based index into [secondaryDestinations].
  final ValueChanged<int>? onSecondaryDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // UX-196/UX-197 (the user's "UX-192"): labels auto-on at ≥ [kDesktopMin] so
    // the rail reads as a menu; callers may still pass an explicit override.
    final showLabels =
        this.showLabels ?? MediaQuery.sizeOf(context).width >= kDesktopMin;
    final width = showLabels ? kShellLabeledRailWidth : kShellCompactRailWidth;
    return Material(
      color: cs.surface,
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // [Flexible] (loose): the primaries take their natural height and
              // any leftover space becomes a gap ABOVE the secondary group —
              // bottom-anchoring the group + footer on tall windows. On short
              // windows the primaries shrink and scroll instead of overflowing.
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        _NavIconButton(
                          item: destinations[i],
                          selected: selectedIndex == i,
                          showLabel: showLabels,
                          width: width,
                          onTap: () => onDestinationSelected(i),
                        ),
                    ],
                  ),
                ),
              ),
              if (secondaryDestinations.isNotEmpty) ...[
                if (showLabels) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        secondaryLabel ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: cs.outlineVariant,
                  ),
                  const SizedBox(height: 4),
                ] else
                  const SizedBox(height: 12),
                for (var i = 0; i < secondaryDestinations.length; i++)
                  _NavIconButton(
                    item: secondaryDestinations[i],
                    selected: false,
                    showLabel: showLabels,
                    width: width,
                    onTap: () => onSecondaryDestinationSelected?.call(i),
                  ),
              ],
              if (footer != null) footer!,
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class WebCompactSideNavItem {
  const WebCompactSideNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.width,
    required this.onTap,
  });

  final WebCompactSideNavItem item;
  final bool selected;
  final bool showLabel;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? HexaColors.brandPrimary : cs.onSurfaceVariant;
    final icon = Icon(
      selected ? item.selectedIcon : item.icon,
      color: color,
    );
    final iconChild = item.badgeCount > 0
        ? Badge(
            label: Text(
              item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
            ),
            child: icon,
          )
        : icon;

    final content = showLabel
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                iconChild,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Center(child: iconChild);

    final button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: 56,
        child: content,
      ),
    );

    if (showLabel) return button;
    return Tooltip(message: item.label, child: button);
  }
}
