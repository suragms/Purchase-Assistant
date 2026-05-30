import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/stock_warehouse_row.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/stock_warehouse_table_header.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/stock_table_layout.dart';

void main() {
  testWidgets('owner row shows stock qty and status chip only', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: StockWarehouseRow(
                  ref: ref,
                  item: const {
                    'id': '1',
                    'name': 'Rice Premium',
                    'category_name': 'Grocery',
                    'subcategory_name': 'Rice',
                    'current_stock': 42,
                    'expected_system_qty': 99,
                    'stock_status': 'low',
                  },
                  isStaffMode: false,
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('SYSTEM'), findsNothing);
    expect(find.text('PHYS'), findsNothing);
    expect(find.text('DIFF'), findsNothing);
    expect(find.text('LOW'), findsOneWidget);
    expect(find.textContaining('42'), findsWidgets);
  });

  testWidgets('staff row shows PHYS column', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: Column(
                  children: [
                    const StockWarehouseTableHeader(isStaffMode: true),
                    StockWarehouseRow(
                      ref: ref,
                      item: const {
                        'id': '1',
                        'name': 'Rice Premium',
                        'physical_stock_qty': 10,
                        'current_stock': 12,
                      },
                      isStaffMode: true,
                      onTap: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('PHYS'), findsOneWidget);
    expect(find.text('STATUS'), findsNothing);
    expect(
      tester.getSize(find.byType(StockWarehouseRow)).height,
      StockTableLayout.rowMinHeight,
    );
  });
}
