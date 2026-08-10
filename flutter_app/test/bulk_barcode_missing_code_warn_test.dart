import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/barcode/presentation/bulk_barcode_print_toolbar.dart';
import 'package:harisree_warehouse/features/barcode/services/bulk_pdf_chunks.dart';

void main() {
  testWidgets('UX-194 toolbar warns when selection has missing codes',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BulkBarcodePrintToolbar(
            selectedCount: 50,
            missingCodeCount: 35,
            busy: false,
            denseA4: true,
            useQr: false,
            copies: 1,
            labelsPerPdfFile: BulkLabelsPerPdfFile.n50,
            showStockOnLabel: true,
            showLastPurchaseOnLabel: true,
            showRateOnLabel: false,
            progress: null,
            statusText: null,
            onDenseA4Changed: (_) {},
            onQrChanged: (_) {},
            onCopiesChanged: (_) {},
            onLabelsPerPdfFileChanged: (_) {},
            onShowStockOnLabelChanged: (_) {},
            onShowLastPurchaseOnLabelChanged: (_) {},
            onShowRateOnLabelChanged: (_) {},
            onPreview: () async {},
            onPdf: () async {},
            onPrint: () async {},
          ),
        ),
      ),
    );

    expect(
      find.textContaining('35 of 50 selected have no barcode/item code'),
      findsOneWidget,
    );
    expect(find.textContaining('Print selected (15)'), findsOneWidget);
  });
}
