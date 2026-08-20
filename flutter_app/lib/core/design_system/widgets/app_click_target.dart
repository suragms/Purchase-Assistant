import 'package:flutter/material.dart';

import '../hexa_responsive.dart';

/// Desktop click cursor + min 48dp touch target for list/card rows.
class AppClickTarget extends StatelessWidget {
  const AppClickTarget({
    super.key,
    required this.onTap,
    required this.child,
    this.enabled = true,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled && onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(minHeight: HexaResponsive.minTouchTarget),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: child,
        ),
      ),
    );
  }
}
