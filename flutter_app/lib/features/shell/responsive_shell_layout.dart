import 'package:flutter/material.dart';

/// Desktop/tablet: NavigationRail + content. Mobile: content only (bottom nav outside).
class ResponsiveShellLayout extends StatelessWidget {
  const ResponsiveShellLayout({
    super.key,
    required this.rail,
    required this.body,
    this.breakpoint = 900,
  });

  final Widget rail;
  final Widget body;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= breakpoint;
        if (!wide) return body;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            rail,
            Expanded(child: body),
          ],
        );
      },
    );
  }
}
