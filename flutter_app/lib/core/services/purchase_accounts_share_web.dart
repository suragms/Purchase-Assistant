// Web-only module (conditional import). VM analyzer cannot resolve dart:js helpers.
// ignore_for_file: undefined_function, undefined_shown_name, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js' show allowInterop;
import 'dart:typed_data';

/// PWA: share PDF + text via navigator.share when supported.
Future<bool> tryWebSharePurchasePdf({
  required Uint8List bytes,
  required String filename,
  required String text,
  required String title,
}) async {
  final navigator = js.context['navigator'];
  if (navigator is! js.JsObject) return false;
  if (!navigator.hasProperty('share')) return false;

  final blob = html.Blob([bytes], 'application/pdf');
  // dart:html File: third arg is options map (not named `type`) on dart2js.
  final file = html.File(
    [blob],
    filename,
    <String, dynamic>{'type': 'application/pdf'},
  );

  final shareData = js.JsObject.jsify({
    'files': [file],
    'text': text,
    'title': title,
  });

  if (navigator.hasProperty('canShare')) {
    final can = navigator.callMethod('canShare', [shareData]);
    if (can == false) return false;
  }

  try {
    final promise = navigator.callMethod('share', [shareData]);
    if (promise is js.JsObject) {
      await _jsPromiseToFuture(promise);
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _jsPromiseToFuture(js.JsObject promise) {
  final c = Completer<void>();
  promise.callMethod('then', [
    allowInterop((_) {
      if (!c.isCompleted) c.complete();
    }),
    allowInterop((Object e) {
      if (!c.isCompleted) c.completeError(e);
    }),
  ]);
  return c.future;
}
