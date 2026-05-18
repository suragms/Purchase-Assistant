import 'package:flutter/material.dart';

/// An overlay manager using OverlayPortal to display suggestions above or below
/// the target text field depending on the screen position and keyboard height.
class KeyboardAwareSuggestionOverlay extends StatefulWidget {
  const KeyboardAwareSuggestionOverlay({
    super.key,
    required this.controller,
    required this.child,
    required this.overlayChild,
  });

  final OverlayPortalController controller;
  final Widget child;
  final Widget overlayChild;

  @override
  State<KeyboardAwareSuggestionOverlay> createState() =>
      _KeyboardAwareSuggestionOverlayState();
}

class _KeyboardAwareSuggestionOverlayState
    extends State<KeyboardAwareSuggestionOverlay> {
  final GlobalKey _fieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: widget.controller,
      overlayChildBuilder: (context) {
        final media = MediaQuery.of(context);
        final keyboardInset = media.viewInsets.bottom;
        final screenHeight = media.size.height;
        final visibleHeight = screenHeight - keyboardInset;

        final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) {
          return const SizedBox.shrink();
        }

        final size = box.size;
        final fieldOffset = box.localToGlobal(Offset.zero);
        final fieldBottom = fieldOffset.dy + size.height;
        final fieldTop = fieldOffset.dy;

        const overlayHeight = 240.0;
        const gap = 8.0;

        // Prefer above when field sits in lower half of visible viewport or keyboard covers below-field placement.
        final bool showAbove = fieldBottom > visibleHeight * 0.55 ||
            (fieldBottom + gap + overlayHeight > visibleHeight - gap);

        double topPosition = showAbove
            ? (fieldTop - overlayHeight - gap)
            : (fieldBottom + 4.0);

        // Keep overlay within visible area above keyboard.
        topPosition = topPosition.clamp(
          media.padding.top + 4.0,
          (visibleHeight - overlayHeight - 4.0).clamp(0.0, double.infinity),
        );

        return Stack(
          children: [
            // Tap outside dismiss barrier
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.controller.hide();
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: fieldOffset.dx,
              top: topPosition,
              width: size.width,
              height: overlayHeight,
              child: widget.overlayChild,
            ),
          ],
        );
      },
      child: KeyedSubtree(
        key: _fieldKey,
        child: widget.child,
      ),
    );
  }
}
