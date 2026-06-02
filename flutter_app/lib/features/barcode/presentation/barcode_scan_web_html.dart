import 'dart:html' as html;

import 'barcode_scan_web_stub.dart' as stub;

/// On web, [MobileScanner.analyzeImage] is the primary photo decode path.
bool get barcodeDetectorAvailable => true;

bool get isSafariBrowser {
  final ua = html.window.navigator.userAgent;
  return ua.contains('Safari') &&
      !ua.contains('Chrome') &&
      !ua.contains('Chromium') &&
      !ua.contains('Edg');
}

bool get preferUploadBarcodeOnWeb => isSafariBrowser;

Future<String?> decodeBarcodeFromImageBytes(List<int> bytes) async {
  return stub.decodeBarcodeFromImageBytes(bytes);
}
