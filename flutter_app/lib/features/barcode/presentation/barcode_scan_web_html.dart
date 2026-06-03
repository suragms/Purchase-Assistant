// Web-only module (conditional import). VM analyzer cannot resolve dart:js helpers.
// ignore_for_file: undefined_function, undefined_shown_name, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js' show allowInterop;
import 'dart:typed_data';

bool get barcodeDetectorAvailable =>
    js.context.hasProperty('BarcodeDetector');

bool get isSafariBrowser {
  final ua = html.window.navigator.userAgent;
  return ua.contains('Safari') &&
      !ua.contains('Chrome') &&
      !ua.contains('Chromium') &&
      !ua.contains('Edg');
}

bool get preferUploadBarcodeOnWeb => isSafariBrowser;

Future<String?> decodeBarcodeFromImageBytes(List<int> bytes) async {
  if (!barcodeDetectorAvailable) return null;
  final blob = html.Blob([Uint8List.fromList(bytes)]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  try {
    final img = html.ImageElement()..src = url;
    await img.onLoad.first.timeout(const Duration(seconds: 8));
    final formats = js.JsArray.from(['code_128', 'ean_13', 'qr_code']);
    final options = js.JsObject.jsify({'formats': formats});
    final ctor = js.context['BarcodeDetector'];
    if (ctor is! js.JsFunction) return null;
    final detector = js.JsObject(ctor, [options]);
    final promise = detector.callMethod('detect', [img]);
    final results = await _promiseToList(promise);
    if (results.isEmpty) return null;
    final first = results.first as js.JsObject;
    final raw = first['rawValue'];
    if (raw == null) return null;
    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  } finally {
    html.Url.revokeObjectUrl(url);
  }
}

Future<List<dynamic>> _promiseToList(dynamic promise) {
  final completer = Completer<List<dynamic>>();
  final then = allowInterop((dynamic value) {
    if (value is List) {
      completer.complete(value);
    } else if (value is js.JsArray) {
      completer.complete(value.toList());
    } else {
      completer.complete(const []);
    }
  });
  final catchErr = allowInterop((dynamic _) {
    completer.complete(const []);
  });
  final p = promise as js.JsObject;
  p.callMethod('then', [then]).callMethod('catch', [catchErr]);
  return completer.future;
}
