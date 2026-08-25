import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/pricing/tax_mode.dart';
import 'package:harisree_warehouse/features/purchase/domain/purchase_draft.dart';
import 'package:harisree_warehouse/features/purchase/presentation/widgets/item_entry/purchase_inline_line_builder.dart';

void main() {
  test('buildInlinePurchaseLineMap rejects empty catalog pick', () {
    final r = buildInlinePurchaseLineMap(
      catalogItemId: null,
      itemName: 'Rice',
      qtyText: '2',
      unit: 'kg',
      buyRateText: '84',
      sellRateText: '',
      taxMode: TaxMode.none,
      taxPercent: 0,
    );
    expect(r.ok, isFalse);
    expect(r.errors.item, isNotNull);
  });

  test('buildInlinePurchaseLineMap builds flat kg line', () {
    final r = buildInlinePurchaseLineMap(
      catalogItemId: 'c1',
      itemName: 'Rice',
      qtyText: '2',
      unit: 'kg',
      buyRateText: '84',
      sellRateText: '176',
      taxMode: TaxMode.none,
      taxPercent: 0,
    );
    expect(r.ok, isTrue);
    final line = PurchaseLineDraft.fromLineMap(r.line!);
    expect(line.catalogItemId, 'c1');
    expect(line.qty, 2);
    expect(line.unit, 'kg');
    expect(line.landingCost, 84);
    expect(line.sellingPrice, 176);
    expect(line.taxPercent ?? 0, 0);
  });

  test('buildInlinePurchaseLineMap applies exclusive GST', () {
    final r = buildInlinePurchaseLineMap(
      catalogItemId: 'c1',
      itemName: 'Oil',
      qtyText: '1',
      unit: 'tin',
      buyRateText: '100',
      sellRateText: '',
      taxMode: TaxMode.exclusive,
      taxPercent: 5,
    );
    expect(r.ok, isTrue);
    expect(r.line!['tax_percent'], 5.0);
    expect(r.line!['tax_mode'], 'exclusive');
  });

  test('inlineLineTotalPreview exclusive tax', () {
    final t = inlineLineTotalPreview(
      qty: 2,
      landingCost: 84,
      taxPercent: 0,
      taxMode: TaxMode.none,
    );
    expect(t, closeTo(168, 0.01));
  });
}
