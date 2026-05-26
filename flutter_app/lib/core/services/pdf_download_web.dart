// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

Future<bool> downloadPdfBytes(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  try {
    html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none'
      ..click();
    return true;
  } finally {
    html.Url.revokeObjectUrl(url);
  }
}
