import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/catalog/presentation/item_detail_tab_matrix.dart';

void main() {
  test('staff matrix is Overview | Activity only', () {
    final tabs = itemDetailTabsForRole(isStaff: true);
    expect(tabs.map((t) => t.label).toList(), ['Overview', 'Activity']);
    expect(tabs.any((t) => t.id == ItemDetailTabId.purchases), isFalse);
  });

  test('owner/manager matrix is Overview | Purchases | Activity', () {
    final tabs = itemDetailTabsForRole(isStaff: false);
    expect(tabs.map((t) => t.label).toList(),
        ['Overview', 'Purchases', 'Activity']);
  });

  test('deep links map onto unified matrix', () {
    expect(itemDetailInitialTabIndex(null, isStaff: false), 0);
    expect(itemDetailInitialTabIndex('purchases', isStaff: false), 1);
    expect(itemDetailInitialTabIndex('ledger', isStaff: false), 1);
    expect(itemDetailInitialTabIndex('analytics', isStaff: false), 0);
    expect(itemDetailInitialTabIndex('activity', isStaff: false), 2);

    expect(itemDetailInitialTabIndex('purchases', isStaff: true), 0);
    expect(itemDetailInitialTabIndex('activity', isStaff: true), 1);
    expect(itemDetailInitialTabIndex('ledger', isStaff: true), 1);
  });
}
