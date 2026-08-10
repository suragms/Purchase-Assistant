import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/stock_desktop_detail_pane.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('StockDesktopDetailPane empty selection uses HexaEmptyState',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: StockDesktopDetailPane(item: null),
          ),
        ),
      ),
    );

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.byType(StockDesktopDetailEmptySelection), findsOneWidget);
    expect(find.text('Select an item'), findsOneWidget);
    expect(
      find.text(
        'Choose a row on the left to see stock metrics and recent activity.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('StockDesktopDetailPane shows 2x2 stats and More at 1280px',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final item = <String, dynamic>{
      'id': 'item-1',
      'name': 'SUGAR 50 KG',
      'unit': 'BAG',
      'current_stock': 50,
      'physical_stock_qty': 20,
      'pending_delivery_qty': 52,
      'opening_stock': 10,
      'purchased_qty': 40,
    };

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 800,
              child: StockDesktopDetailPane(item: item),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SUGAR 50 KG'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Diff'), findsOneWidget);
    expect(find.text('Verify physical'), findsOneWidget);
    expect(find.text('New purchase'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
  });

  testWidgets('stock desktop activity empty uses HexaEmptyState',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StockDesktopDetailActivityEmpty(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No recent activity'), findsOneWidget);
    expect(
      find.text('Stock updates and purchases for this item will show here.'),
      findsOneWidget,
    );
  });

  testWidgets('stock desktop activity error uses HexaEmptyState + Retry',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockDesktopDetailActivityError(
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Could not load activity'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(retried, isTrue);
  });
}
