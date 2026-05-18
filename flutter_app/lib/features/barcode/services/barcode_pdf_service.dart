import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum LabelSize { small, medium, large }

class BarcodeLabelData {
  const BarcodeLabelData({
    required this.itemCode,
    required this.itemName,
    this.unit,
    this.currentStock,
    this.lastPurchaseDate,
    this.lastPurchaseQty,
    this.lastPurchaseUnit,
    this.lastPurchaseRate,
  });

  final String itemCode;
  final String itemName;
  final String? unit;
  final double? currentStock;
  final DateTime? lastPurchaseDate;
  final double? lastPurchaseQty;
  final String? lastPurchaseUnit;
  final double? lastPurchaseRate;
}

class BarcodePdfService {
  static Future<Uint8List> generateSingleLabel({
    required BarcodeLabelData data,
    LabelSize size = LabelSize.medium,
    int copies = 1,
    bool showLastPurchase = true,
  }) async {
    final doc = pw.Document();
    final code = data.itemCode.trim().isEmpty ? data.itemName : data.itemCode;
    final bc = Barcode.code128();

    PdfPageFormat fmt;
    double titleSize;
    double codeSize;
    switch (size) {
      case LabelSize.small:
        fmt = const PdfPageFormat(38 * PdfPageFormat.mm, 19 * PdfPageFormat.mm);
        titleSize = 7;
        codeSize = 6;
      case LabelSize.large:
        fmt = const PdfPageFormat(100 * PdfPageFormat.mm, 50 * PdfPageFormat.mm);
        titleSize = 10;
        codeSize = 8;
      case LabelSize.medium:
        fmt = const PdfPageFormat(57 * PdfPageFormat.mm, 32 * PdfPageFormat.mm);
        titleSize = 8;
        codeSize = 7;
    }

    String? lastLine;
    if (showLastPurchase && size != LabelSize.small) {
      if (data.lastPurchaseDate != null) {
        final d = data.lastPurchaseDate!;
        final ds =
            '${d.day.toString().padLeft(2, '0')} ${_month(d.month)} ${d.year % 100}';
        final qty = data.lastPurchaseQty?.toStringAsFixed(0) ?? '';
        final u = data.lastPurchaseUnit ?? data.unit ?? '';
        final rate = data.lastPurchaseRate != null
            ? '₹${data.lastPurchaseRate!.toStringAsFixed(0)}'
            : '';
        lastLine = 'Last: $ds  $qty $u  $rate'.trim();
      } else {
        lastLine = 'No purchase yet';
      }
    }

    for (var c = 0; c < copies; c++) {
      doc.addPage(
        pw.Page(
          pageFormat: fmt,
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                data.itemName,
                maxLines: 2,
                style: pw.TextStyle(fontSize: titleSize, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.BarcodeWidget(
                barcode: bc,
                data: code,
                drawText: false,
                height: size == LabelSize.small ? 28 : 40,
              ),
              pw.Text(code, style: pw.TextStyle(fontSize: codeSize)),
              if (lastLine != null)
                pw.Text(lastLine, style: pw.TextStyle(fontSize: codeSize - 1)),
              if (size == LabelSize.large && data.currentStock != null)
                pw.Text(
                  'Stock: ${data.currentStock!.toStringAsFixed(0)} ${data.unit ?? ''}',
                  style: pw.TextStyle(fontSize: codeSize - 1),
                ),
            ],
          ),
        ),
      );
    }
    return doc.save();
  }

  static String _month(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[m - 1];
  }

  static Future<Uint8List> generateBatch({
    required List<BarcodeLabelData> items,
    LabelSize size = LabelSize.medium,
    int copiesPerItem = 1,
  }) async {
    final doc = pw.Document();
    for (final data in items) {
      final code = data.itemCode.trim().isEmpty ? data.itemName : data.itemCode;
      final bc = Barcode.code128();
      PdfPageFormat fmt;
      double titleSize;
      double codeSize;
      switch (size) {
        case LabelSize.small:
          fmt = const PdfPageFormat(38 * PdfPageFormat.mm, 19 * PdfPageFormat.mm);
          titleSize = 7;
          codeSize = 6;
        case LabelSize.large:
          fmt = const PdfPageFormat(100 * PdfPageFormat.mm, 50 * PdfPageFormat.mm);
          titleSize = 10;
          codeSize = 8;
        case LabelSize.medium:
          fmt = const PdfPageFormat(57 * PdfPageFormat.mm, 32 * PdfPageFormat.mm);
          titleSize = 8;
          codeSize = 7;
      }
      for (var c = 0; c < copiesPerItem; c++) {
        doc.addPage(
          pw.Page(
            pageFormat: fmt,
            build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  data.itemName,
                  maxLines: 2,
                  style: pw.TextStyle(fontSize: titleSize, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.BarcodeWidget(
                  barcode: bc,
                  data: code,
                  drawText: false,
                  height: size == LabelSize.small ? 28 : 40,
                ),
                pw.Text(code, style: pw.TextStyle(fontSize: codeSize)),
              ],
            ),
          ),
        );
      }
    }
    return doc.save();
  }
}
