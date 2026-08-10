import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'hexa_web_viewport_size_stub.dart'
    if (dart.library.html) 'hexa_web_viewport_size_web.dart' as browser_vp;

/// On Flutter web, Chrome DevTools device mode (or odd host CSS) can leave
/// [MediaQuery] at the full browser width while the visible CSS viewport is
/// phone-sized — cascading to desktop rails / master-detail inside a 400px frame.
///
/// When browser CSS width diverges from Flutter's view size by ≥2px, override
/// [MediaQuery.size] to the browser CSS viewport. Never lowers product
/// breakpoints ([kDesktopMin]); fixes host/view mismatch only.
class HexaWebViewportBinder extends StatefulWidget {
  const HexaWebViewportBinder({super.key, required this.child});

  final Widget child;

  @override
  State<HexaWebViewportBinder> createState() => _HexaWebViewportBinderState();
}

class _HexaWebViewportBinderState extends State<HexaWebViewportBinder> {
  static const double _mismatchPx = 2;

  ({double width, double height})? _browser;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    _browser = browser_vp.readBrowserCssViewport();
    browser_vp.listenBrowserCssViewport(_onBrowserViewportChanged);
  }

  @override
  void dispose() {
    if (kIsWeb) browser_vp.unlistenBrowserCssViewport();
    super.dispose();
  }

  void _onBrowserViewportChanged() {
    final next = browser_vp.readBrowserCssViewport();
    if (next == null) return;
    final prev = _browser;
    if (prev != null &&
        (prev.width - next.width).abs() < 0.5 &&
        (prev.height - next.height).abs() < 0.5) {
      return;
    }
    if (!mounted) return;
    setState(() => _browser = next);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;
    final browser = _browser ?? browser_vp.readBrowserCssViewport();
    if (browser == null) return widget.child;

    final mq = MediaQuery.of(context);
    final flutterW = mq.size.width;
    final flutterH = mq.size.height;
    final mismatchW = (flutterW - browser.width).abs() >= _mismatchPx;
    final mismatchH = (flutterH - browser.height).abs() >= _mismatchPx;
    if (!mismatchW && !mismatchH) return widget.child;

    return MediaQuery(
      data: mq.copyWith(
        size: Size(browser.width, browser.height),
      ),
      child: widget.child,
    );
  }
}
