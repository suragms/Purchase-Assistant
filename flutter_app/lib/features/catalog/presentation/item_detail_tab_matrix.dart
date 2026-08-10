/// Shared item-detail tab IA for mobile + desktop (UX-014).
enum ItemDetailTabId { overview, purchases, activity }

class ItemDetailTabSpec {
  const ItemDetailTabSpec(this.id, this.label);

  final ItemDetailTabId id;
  final String label;
}

/// Staff: Overview | Activity. Non-staff: Overview | Purchases | Activity.
List<ItemDetailTabSpec> itemDetailTabsForRole({required bool isStaff}) {
  if (isStaff) {
    return const [
      ItemDetailTabSpec(ItemDetailTabId.overview, 'Overview'),
      ItemDetailTabSpec(ItemDetailTabId.activity, 'Activity'),
    ];
  }
  return const [
    ItemDetailTabSpec(ItemDetailTabId.overview, 'Overview'),
    ItemDetailTabSpec(ItemDetailTabId.purchases, 'Purchases'),
    ItemDetailTabSpec(ItemDetailTabId.activity, 'Activity'),
  ];
}

/// Maps `?tab=` deep links onto the role-specific tab list.
int itemDetailInitialTabIndex(
  String? tabQuery, {
  required bool isStaff,
}) {
  final tab = tabQuery?.trim().toLowerCase();
  final tabs = itemDetailTabsForRole(isStaff: isStaff);

  ItemDetailTabId target;
  if (isStaff) {
    if (tab == 'history' ||
        tab == 'stock-history' ||
        tab == 'activity' ||
        tab == 'ledger') {
      target = ItemDetailTabId.activity;
    } else {
      target = ItemDetailTabId.overview;
    }
  } else if (tab == 'purchases' ||
      tab == 'purchase' ||
      tab == 'ledger' ||
      tab == 'analytics' ||
      tab == 'price') {
    // Ledger/analytics fold into Purchases on the unified matrix.
    target = (tab == 'analytics' || tab == 'price')
        ? ItemDetailTabId.overview
        : ItemDetailTabId.purchases;
  } else if (tab == 'history' || tab == 'stock-history' || tab == 'activity') {
    target = ItemDetailTabId.activity;
  } else {
    target = ItemDetailTabId.overview;
  }

  final idx = tabs.indexWhere((t) => t.id == target);
  return idx < 0 ? 0 : idx;
}
