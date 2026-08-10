// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

html.EventListener? _resizeListener;
html.EventListener? _vvListener;

/// CSS pixels from visualViewport (preferred) or window.inner*.
({double width, double height})? readBrowserCssViewport() {
  final vv = html.window.visualViewport;
  if (vv != null) {
    final w = vv.width?.toDouble();
    final h = vv.height?.toDouble();
    if (w != null && h != null && w.isFinite && h.isFinite && w > 0 && h > 0) {
      return (width: w, height: h);
    }
  }
  final w = html.window.innerWidth?.toDouble();
  final h = html.window.innerHeight?.toDouble();
  if (w == null || h == null || !w.isFinite || !h.isFinite || w <= 0 || h <= 0) {
    return null;
  }
  return (width: w, height: h);
}

void listenBrowserCssViewport(void Function() onChange) {
  unlistenBrowserCssViewport();
  _resizeListener = (_) => onChange();
  html.window.addEventListener('resize', _resizeListener);
  final vv = html.window.visualViewport;
  if (vv != null) {
    _vvListener = (_) => onChange();
    vv.addEventListener('resize', _vvListener);
    vv.addEventListener('scroll', _vvListener);
  }
}

void unlistenBrowserCssViewport() {
  if (_resizeListener != null) {
    html.window.removeEventListener('resize', _resizeListener);
    _resizeListener = null;
  }
  final vv = html.window.visualViewport;
  if (vv != null && _vvListener != null) {
    vv.removeEventListener('resize', _vvListener);
    vv.removeEventListener('scroll', _vvListener);
  }
  _vvListener = null;
}
