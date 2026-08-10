import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/errors/barcode_operation_errors.dart';
import 'package:harisree_warehouse/features/barcode/services/barcode_pdf_service.dart';

void main() {
  test('sanitizeBarcodeErrorForLog strips uuid and quoted names', () {
    final msg = sanitizeBarcodeErrorForLog(
      BarcodeOperationException(
        'Barcode image missing for "916 RAVA 30 KG".',
        kind: BarcodeOperationKind.barcodeRender,
      ),
    );
    expect(msg, contains('barcodeRender'));
    expect(msg, isNot(contains('RAVA')));
    expect(msg, contains('<redacted>'));

    final withId = sanitizeBarcodeErrorForLog(
      StateError('fail 550e8400-e29b-41d4-a716-446655440000'),
    );
    expect(withId, contains('<id>'));
    expect(withId, isNot(contains('550e8400')));
  });

  test('UX-192 reproduce: single healthy Code128 A4 dense PDF builds', () async {
    final label = BarcodeLabelData(
      itemCode: '2095',
      itemName: '916 RAVA 30 KG',
      barcode: '2095',
      unit: 'KG',
      currentStock: 1000,
    );
    final bytes = await BarcodePdfService.generateBatchA4Dense(
      items: [label],
      size: LabelSize.small,
      copiesPerItem: 1,
      symbol: BarcodeSymbolMode.code128,
      targetLabelsPerPage: 50,
    );
    expect(bytes.length, greaterThan(100));
  });
}
