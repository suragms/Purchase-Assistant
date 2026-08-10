import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/trade_purchases_list_inflight.dart';

void main() {
  test('DUP-F-005 trade purchase dedupe keys match for identical pages', () {
    final a = tradePurchasesListDedupeKey(
      businessId: 'b1',
      limit: 50,
      offset: 0,
    );
    final b = tradePurchasesListDedupeKey(
      businessId: 'b1',
      limit: 50,
      offset: 0,
    );
    expect(a, b);
    expect(
      tradePurchasesListDedupeKey(
        businessId: 'b1',
        limit: 50,
        offset: 50,
      ),
      isNot(a),
    );
  });
}
