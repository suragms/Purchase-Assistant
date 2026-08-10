import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/reports_provider.dart';
import 'package:harisree_warehouse/features/reports/reports_bi_tab.dart';

void main() {
  test('API-DUP-R-001 only Items/Purchases tabs need purchase rows', () {
    expect(reportsTabNeedsPurchaseRows(ReportsBiTab.overview), isFalse);
    expect(reportsTabNeedsPurchaseRows(ReportsBiTab.stock), isFalse);
    expect(reportsTabNeedsPurchaseRows(ReportsBiTab.items), isTrue);
    expect(reportsTabNeedsPurchaseRows(ReportsBiTab.purchases), isTrue);
  });
}
