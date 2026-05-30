import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/reports/reports_bi_tab.dart';

void main() {
  test('ReportsBiTabX.fromQuery maps items deep link', () {
    expect(ReportsBiTabX.fromQuery('items'), ReportsBiTab.items);
    expect(ReportsBiTabX.fromQuery('purchase'), ReportsBiTab.purchases);
    expect(ReportsBiTabX.fromQuery(null), isNull);
  });
}
