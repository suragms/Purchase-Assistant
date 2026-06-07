import 'package:flutter/material.dart';

import '../../core/design_system/hexa_responsive.dart';

/// Centers page content on wide screens with a max readable width.
///
/// On phone/tablet (< [minWidth]), [child] is full width. Use [fullWidth] for
/// pages that already implement their own master-detail layout on desktop.
class DesktopPageShell extends StatelessWidget {
  const DesktopPageShell({
    super.key,
    required this.child,
    this.maxContentWidth = 900,
    this.minWidth = kDesktopMin,
    this.padding,
    this.fullWidth = false,
  });

  final Widget child;
  final double maxContentWidth;
  final double minWidth;
  final EdgeInsetsGeometry? padding;

  /// When true, never constrain — for stock/purchase/reports split layouts.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    if (fullWidth) return child;

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minWidth) {
          return content;
        }
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: content,
          ),
        );
      },
    );
  }
}
