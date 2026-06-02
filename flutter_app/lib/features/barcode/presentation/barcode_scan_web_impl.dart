import 'barcode_scan_web_stub.dart' as stub;

bool get barcodeDetectorAvailable => stub.barcodeDetectorAvailable;

bool get isSafariBrowser => stub.isSafariBrowser;

bool get preferUploadBarcodeOnWeb => stub.preferUploadBarcodeOnWeb;

Future<String?> decodeBarcodeFromImageBytes(List<int> bytes) =>
    stub.decodeBarcodeFromImageBytes(bytes);
