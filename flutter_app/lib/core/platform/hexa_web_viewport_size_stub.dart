/// Non-web: browser CSS viewport is unused; Flutter [MediaQuery] is authoritative.
({double width, double height})? readBrowserCssViewport() => null;

({double width, double height})? readBrowserLayoutViewport() => null;

({double width, double height})? readBrowserCssViewportForBinder({
  required double flutterWidth,
  required double desktopMinWidth,
}) =>
    null;

void listenBrowserCssViewport(void Function() onChange) {}

void unlistenBrowserCssViewport() {}
