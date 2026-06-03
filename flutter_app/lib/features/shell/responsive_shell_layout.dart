import 'package:flutter/material.dart';

/// Desktop/tablet: NavigationRail + content. Mobile: content only (bottom nav outside).
class ResponsiveShellLayout extends StatefulWidget {
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
  State<ResponsiveShellLayout> createState() => _ResponsiveShellLayoutState();
}

class _ResponsiveShellLayoutState extends State<ResponsiveShellLayout> {
  bool _scheduledConstraintsRetry = false;

  bool _hasUsableWidth(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    return w.isFinite && w > 0;
  }

  void _retryAfterConstraints() {
    if (_scheduledConstraintsRetry || !mounted) return;
    _scheduledConstraintsRetry = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledConstraintsRetry = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_hasUsableWidth(constraints)) {
          _retryAfterConstraints();
          return const SizedBox.shrink();
        }
        final wide = constraints.maxWidth >= widget.breakpoint;
        if (!wide) return widget.body;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.rail,
            Expanded(child: widget.body),
          ],
        );
      },
    );
  }
}
