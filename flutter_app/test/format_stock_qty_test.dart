import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/utils/unit_utils.dart';

void main() {
  test('formatStockQtyNumber strips near-integer decimals', () {
    expect(formatStockQtyNumber(101.0004), '101');
    expect(formatStockQtyNumber(100.9996), '101');
  });

  test('formatStockQtyNumber keeps meaningful fractions', () {
    expect(formatStockQtyNumber(101.25), '101.25');
    expect(formatStockQtyNumber(101.5), '101.5');
  });

  test('formatStockQtyNumber adds comma thousands', () {
    expect(formatStockQtyNumber(1234), '1,234');
  });
}
