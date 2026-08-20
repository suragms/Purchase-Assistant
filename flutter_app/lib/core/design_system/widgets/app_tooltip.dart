import 'package:flutter/material.dart';

/// Canonical tooltip — wait before show so dense ERP chrome is not noisy.
class AppTooltip extends StatelessWidget {
  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.wait = const Duration(milliseconds: 400),
  });

  final String message;
  final Widget child;
  final Duration wait;

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) return child;
    return Tooltip(
      message: message,
      waitDuration: wait,
      child: child,
    );
  }
}
