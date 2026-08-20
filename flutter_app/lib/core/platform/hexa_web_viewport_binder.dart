import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design_system/hexa_responsive.dart';
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
    _browser = _readBrowser(null);
    browser_vp.listenBrowserCssViewport(_onBrowserViewportChanged);
  }

  ({double width, double height})? _readBrowser(double? flutterWidth) {
    if (flutterWidth != null && flutterWidth > 0) {
      return browser_vp.readBrowserCssViewportForBinder(
        flutterWidth: flutterWidth,
        desktopMinWidth: kDesktopMin,
      );
    }
    return browser_vp.readBrowserCssViewport();
  }

  @override
  void dispose() {
    if (kIsWeb) browser_vp.unlistenBrowserCssViewport();
    super.dispose();
  }

  void _onBrowserViewportChanged() {
    final mq = MediaQuery.maybeOf(context);
    final flutterW = mq?.size.width ?? 0;
    final next = _readBrowser(flutterW > 0 ? flutterW : null);
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

    final mq = MediaQuery.of(context);
    final browser = _browser ??
        _readBrowser(mq.size.width > 0 ? mq.size.width : null);
    if (browser == null) return widget.child;

    final flutterW = mq.size.width;
    final flutterH = mq.size.height;
    final mismatchW = (flutterW - browser.width).abs() >= _mismatchPx;
    final mismatchH = (flutterH - browser.height).abs() >= _mismatchPx;
    final desktopWide = browser.width >= kDesktopMin;
    final stripIme = desktopWide || !context.isMobileLayout;

    if (!mismatchW && !mismatchH && !stripIme) return widget.child;

    return MediaQuery(
      data: mq.copyWith(
        size: Size(
          mismatchW ? browser.width : flutterW,
          mismatchH ? browser.height : flutterH,
        ),
        viewInsets: stripIme ? EdgeInsets.zero : mq.viewInsets,
      ),
      child: widget.child,
    );
  }
}
