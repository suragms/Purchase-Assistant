import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/design_system/hexa_responsive.dart';
import '../../../../core/theme/hexa_colors.dart';
import '../auth_brand_assets.dart';

/// Blurred hero image + light scrim, keyboard-safe scroll. Max width 420.
///
/// Keyboard lift is owned by the parent [Scaffold]'s `resizeToAvoidBottomInset`
/// — do **not** add [MediaQuery.viewInsets] to scroll padding (double-lift bounce).
class AuthPageShell extends StatelessWidget {
  const AuthPageShell({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = HexaResponsive.isImeOpen(context);
    final useAuthDesktopChrome = !context.isMobileLayout;

    Widget shell = Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            AuthBrandAssets.background,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => DecoratedBox(
              decoration: BoxDecoration(gradient: HexaColors.atmosphereGradient),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: const ColoredBox(color: Color(0x00000000)),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.35),
                  HexaColors.brandBackground.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final form = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              );

              // Desktop: centered card, no scroll — avoids focus-driven scroll
              // clipping the email field and exposing the HTML body below.
              if (useAuthDesktopChrome) {
                return Center(child: form);
              }

              return Align(
                alignment: keyboardOpen
                    ? Alignment.topCenter
                    : Alignment.center,
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  // Fixed padding only — Scaffold owns IME inset.
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 420,
                      minHeight: keyboardOpen
                          ? 0
                          : (constraints.maxHeight - 40)
                              .clamp(0.0, double.infinity),
                    ),
                    child: Column(
                      mainAxisAlignment: keyboardOpen
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    // Web can inject viewInsets on text focus even without a soft keyboard.
    // Strip on desktop so descendants never shrink or top-align spuriously.
    if (useAuthDesktopChrome) {
      final mq = MediaQuery.of(context);
      shell = MediaQuery(
        data: mq.copyWith(viewInsets: EdgeInsets.zero),
        child: shell,
      );
    }

    return shell;
  }
}

/// Circular company logo; falls back to "H" if asset missing.
class AuthSmallLogo extends StatelessWidget {
  const AuthSmallLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 2),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              AuthBrandAssets.logo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: HexaColors.brandPrimary,
                alignment: Alignment.center,
                child: const Text(
                  'H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Frosted card on top of blurred hero — form stays primary focus.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
