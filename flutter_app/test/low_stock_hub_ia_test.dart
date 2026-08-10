import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/stock/presentation/low_stock_dashboard_page.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/low_stock_category_tree.dart';

void main() {
  test('lowStockHubForTab splits attention vs pipeline', () {
    expect(lowStockHubForTab(LowStockTreeTab.allLow), LowStockHubSection.attention);
    expect(
      lowStockHubForTab(LowStockTreeTab.outOfStock),
      LowStockHubSection.attention,
    );
    expect(
      lowStockHubForTab(LowStockTreeTab.purchasedInPeriod),
      LowStockHubSection.pipeline,
    );
    expect(
      lowStockHubForTab(LowStockTreeTab.pendingOrder),
      LowStockHubSection.pipeline,
    );
    expect(
      lowStockHubForTab(LowStockTreeTab.pendingDelivery),
      LowStockHubSection.pipeline,
    );
  });

  test('lowStockTabsForHub keeps ≤3 chips per hub', () {
    expect(lowStockTabsForHub(LowStockHubSection.attention).length, 2);
    expect(lowStockTabsForHub(LowStockHubSection.pipeline).length, 3);
    expect(lowStockTabOrder.length, 5);
  });

  testWidgets('Attention hub shows All/Out only — not pipeline chips',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = LowStockTreeTab.allLow;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LowStockHubFilterBar(
                selectedTab: selected,
                counts: const {
                  LowStockTreeTab.allLow: 3,
                  LowStockTreeTab.outOfStock: 1,
                  LowStockTreeTab.purchasedInPeriod: 2,
                  LowStockTreeTab.pendingOrder: 0,
                  LowStockTreeTab.pendingDelivery: 4,
                },
                onSelected: (tab) => setState(() => selected = tab),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('Pipeline'), findsOneWidget);
    expect(find.text('All (3)'), findsOneWidget);
    expect(find.text('Out (1)'), findsOneWidget);
    expect(find.text('Bought (2)'), findsNothing);
    expect(find.text('Pending (0)'), findsNothing);
    expect(find.text('Delivery (4)'), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);

    await tester.tap(find.text('Pipeline'));
    await tester.pumpAndSettle();

    expect(find.text('Bought (2)'), findsOneWidget);
    expect(find.text('Pending (0)'), findsOneWidget);
    expect(find.text('Delivery (4)'), findsOneWidget);
    expect(find.text('All (3)'), findsNothing);
    expect(find.text('Out (1)'), findsNothing);
  });
}
