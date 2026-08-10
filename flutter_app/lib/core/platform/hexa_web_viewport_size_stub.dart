/// Non-web: browser CSS viewport is unused; Flutter [MediaQuery] is authoritative.
({double width, double height})? readBrowserCssViewport() => null;

void listenBrowserCssViewport(void Function() onChange) {}

void unlistenBrowserCssViewport() {}
