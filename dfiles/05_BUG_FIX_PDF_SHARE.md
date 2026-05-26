# AGENT PROMPT 05 — FIX PDF DOWNLOAD / SHARE / PRINT
**Priority:** HIGH — Share button and PDF download show no result or silent fail.

---

## ROOT CAUSE ANALYSIS

**File:** `flutter_app/lib/core/services/purchase_pdf.dart`

### Root Cause 1: Logo download failure silently kills PDF generation
The `_tryLogo()` function fetches the business logo URL over HTTP. If:
- The logo URL is expired/broken, OR
- There is no internet, OR
- The logo server times out

...the Dio call throws, but the outer catch swallows it and returns `null`. However, some callers pass the result directly to `pw.Image(...)` without checking for null, which crashes the PDF build silently.

### Root Cause 2: `share_plus` on web uses `XFile` which fails on some browsers
The `sharePurchasePdf()` function uses `Share.shareXFiles(...)` which is not supported in all web browsers. On Chrome mobile/desktop it may silently fail.

### Root Cause 3: Download button on web triggers browser print dialog instead of save
`printing` package's `Printing.layoutPdf()` opens the print dialog on web. Users expect a direct file download, not a print dialog.

### Root Cause 4: `Uint8List.fromList(data)` when `data` is null
In some error paths, the PDF bytes are null or empty, causing an unhandled exception.

---

## FIX 1: Robust logo loading

In `purchase_pdf.dart`, find `_tryLogo()` and ensure it handles all failure cases:

```dart
Future<pw.ImageProvider?> _tryLogo(String? url) async {
  final u = url?.trim();
  if (u == null || u.isEmpty) return null;
  try {
    final r = await Dio().get<List<int>>(
      u,
      options: Options(
        responseType: ResponseType.bytes,
        receiveTimeout: const Duration(seconds: 5),   // Reduced from 8 to 5
        sendTimeout: const Duration(seconds: 5),
      ),
    );
    final data = r.data;
    if (data == null || data.isEmpty) return null;
    final bytes = Uint8List.fromList(data);
    if (bytes.isEmpty) return null;
    return pw.MemoryImage(bytes);
  } catch (_) {
    return null;  // Always return null on any failure — PDF will just have no logo
  }
}
```

Find every call site that uses the result of `_tryLogo()` and ensure they handle `null`:
```dart
// BEFORE (might crash):
final logo = await _tryLogo(biz.logoUrl);
pw.Image(logo!)  // ← if null, this crashes

// AFTER:
final logo = await _tryLogo(biz.logoUrl);
if (logo != null) pw.Image(logo)
// OR use:
logo != null ? pw.Image(logo) : pw.SizedBox(),
```

---

## FIX 2: Platform-aware PDF save/share

Create a new utility function that picks the right method per platform:

```dart
/// flutter_app/lib/core/services/pdf_save_util.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Saves PDF bytes to a temp file and shares it (mobile) or downloads it (web).
/// Returns true on success, false on failure.
Future<bool> savePdfToDevice({
  required Uint8List pdfBytes,
  required String filename,
}) async {
  if (pdfBytes.isEmpty) return false;
  
  try {
    if (kIsWeb) {
      // Web: trigger browser download directly
      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
      return true;
    }
    
    // Mobile: save to temp then share
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdfBytes, flush: true);
    
    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      text: filename.replaceAll('_', ' ').replaceAll('.pdf', ''),
    );
    
    return result.status == ShareResultStatus.success ||
           result.status == ShareResultStatus.dismissed;
  } catch (e) {
    debugPrint('PDF save error: $e');
    return false;
  }
}

/// Opens print dialog (all platforms).
Future<bool> printPdfBytes({
  required Uint8List pdfBytes,
  required String filename,
}) async {
  if (pdfBytes.isEmpty) return false;
  try {
    return await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: filename,
    );
  } catch (e) {
    debugPrint('PDF print error: $e');
    return false;
  }
}

/// Downloads PDF as a file to Downloads folder (Android/iOS).
Future<bool> downloadPdfToDownloads({
  required Uint8List pdfBytes,
  required String filename,
}) async {
  if (pdfBytes.isEmpty) return false;
  if (kIsWeb) {
    return savePdfToDevice(pdfBytes: pdfBytes, filename: filename);
  }
  try {
    Directory? dir;
    if (Platform.isAndroid) {
      // Save to Downloads folder on Android
      dir = Directory('/storage/emulated/0/Download/HarisreeWarehouse');
      if (!await dir.exists()) await dir.create(recursive: true);
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getTemporaryDirectory();
    }
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdfBytes, flush: true);
    return true;
  } catch (e) {
    debugPrint('PDF download error: $e');
    return false;
  }
}
```

---

## FIX 3: Update purchase_pdf.dart functions to use the new utility

**File:** `flutter_app/lib/core/services/purchase_pdf.dart`

Find `sharePurchasePdf()`, `downloadPurchasePdf()`, `printPurchasePdf()` and refactor:

```dart
/// Share purchase PDF (uses share sheet on mobile, browser download on web)
Future<bool> sharePurchasePdf(TradePurchase p, BusinessProfile biz) async {
  try {
    final bytes = await buildPurchasePdfBytes(p, biz);
    if (bytes == null || bytes.isEmpty) return false;
    final filename = buildPurchaseSharePdfFileName(p);
    return savePdfToDevice(pdfBytes: bytes, filename: filename);
  } catch (e) {
    debugPrint('sharePurchasePdf error: $e');
    return false;
  }
}

/// Download purchase PDF to device storage
Future<bool> downloadPurchasePdf(TradePurchase p, BusinessProfile biz) async {
  try {
    final bytes = await buildPurchasePdfBytes(p, biz);
    if (bytes == null || bytes.isEmpty) return false;
    final filename = buildPurchaseSharePdfFileName(p);
    return downloadPdfToDownloads(pdfBytes: bytes, filename: filename);
  } catch (e) {
    debugPrint('downloadPurchasePdf error: $e');
    return false;
  }
}

/// Print purchase PDF via system print dialog
Future<bool> printPurchasePdf(TradePurchase p, BusinessProfile biz) async {
  try {
    final bytes = await buildPurchasePdfBytes(p, biz);
    if (bytes == null || bytes.isEmpty) return false;
    final filename = buildPurchaseSharePdfFileName(p);
    return printPdfBytes(pdfBytes: bytes, filename: filename);
  } catch (e) {
    debugPrint('printPurchasePdf error: $e');
    return false;
  }
}
```

---

## FIX 4: Better UI feedback in purchase_detail_page.dart

**File:** `flutter_app/lib/features/purchase/presentation/purchase_detail_page.dart`

Find the share, print, download button handlers and add proper loading + error states:

```dart
// SHARE BUTTON:
Future<void> _onSharePressed() async {
  final snack = ScaffoldMessenger.of(context);
  snack.showSnackBar(
    const SnackBar(
      content: Text('Preparing PDF...'),
      duration: Duration(seconds: 30),  // Will be replaced by success/error
    ),
  );
  try {
    final p = ref.read(currentPurchaseProvider);
    final biz = ref.read(businessProfileProvider);
    if (p == null || biz == null) {
      snack.hideCurrentSnackBar();
      snack.showSnackBar(const SnackBar(content: Text('Could not load purchase data')));
      return;
    }
    final ok = await sharePurchasePdf(p, biz);
    snack.hideCurrentSnackBar();
    if (ok) {
      snack.showSnackBar(
        const SnackBar(
          content: Text('PDF ready to share'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      snack.showSnackBar(
        const SnackBar(
          content: Text('Could not share PDF. Try the download option instead.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  } catch (e) {
    snack.hideCurrentSnackBar();
    snack.showSnackBar(
      SnackBar(content: Text('PDF error: ${e.toString().substring(0, 80)}')),
    );
  }
}

// DOWNLOAD BUTTON:
Future<void> _onDownloadPressed() async {
  // Similar pattern with loading + success/error snackbar
}

// PRINT BUTTON:
Future<void> _onPrintPressed() async {
  // Similar pattern
}
```

---

## FIX 5: Barcode label PDF — improve quality

**File:** `flutter_app/lib/features/barcode/presentation/` (wherever barcode PDF is generated)

Current issue: barcode on label is blurry/unreadable. Fix by using SVG rendering:

```dart
import 'package:barcode/barcode.dart';

// Generate barcode as SVG then render in PDF:
final barcodeValue = item['barcode'] ?? item['item_code'] ?? '';
if (barcodeValue.isNotEmpty) {
  final bc = Barcode.code128();
  final svg = bc.toSvg(
    barcodeValue,
    width: 200,
    height: 60,
    drawText: true,
    fontHeight: 12,
  );
  // Use pw.SvgImage to render:
  final svgBytes = Uint8List.fromList(utf8.encode(svg));
  pw.SvgImage(svg: svgBytes)
}
```

---

## VERIFICATION CHECKLIST

- [ ] Share button shows "Preparing PDF..." snackbar immediately
- [ ] Share button shows success snackbar when done OR error snackbar when failed
- [ ] Share never silently fails (always shows user feedback)
- [ ] Download button saves file to device Downloads folder on Android
- [ ] Print button opens system print dialog
- [ ] PDF generates even when business has no logo (logo = null handled)
- [ ] PDF generates even when device is offline (logo fetch fails gracefully)
- [ ] Barcode on printed label is sharp and scannable (SVG rendering)
- [ ] All PDF operations guarded with try/catch and user feedback

---

## ALSO ADD: `path_provider` to pubspec if not already present

```yaml
# Check pubspec.yaml — add if missing:
path_provider: ^2.1.4
```
