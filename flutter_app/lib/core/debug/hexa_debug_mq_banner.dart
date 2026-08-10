import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design_system/hexa_responsive.dart';

/// Debug-only floating chip: MediaQuery width + desktop/phone classification.
///
/// Use during viewport repair (Phase 0/1): compare DevTools device frame vs
/// this value. Remove or leave gated behind [kDebugMode] only.
class HexaDebugMqBanner extends StatelessWidget {
  const HexaDebugMqBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
    final desktop = context.isDesktopLayout;
    final label =
        'mqW ${w.toStringAsFixed(0)} · ${h.toStringAsFixed(0)} · '
        '${desktop ? 'DESKTOP' : (w >= kTabletMin ? 'TABLET' : 'PHONE')}';
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          right: 8,
          bottom: 8,
          child: IgnorePointer(
            child: Material(
              elevation: 2,
              color: const Color(0xCC14523E),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
