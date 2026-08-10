import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/trade_purchases_provider.dart';
import 'package:harisree_warehouse/features/catalog/presentation/widgets/item_purchase_history_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty range shows HexaEmptyState + Show all time',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tradePurchasesForItemProvider('item-1').overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ItemPurchaseHistorySection(
                itemId: 'item-1',
                itemName: 'Sugar',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchases in this range'), findsOneWidget);
    expect(find.text('No purchases found in this range.'), findsNothing);
    expect(find.text('Show all time'), findsOneWidget);

    await tester.tap(find.text('Show all time'));
    await tester.pumpAndSettle();

    expect(find.text('New purchase'), findsOneWidget);
    expect(find.text('Show all time'), findsNothing);
  });

  testWidgets('all-time empty New purchase navigates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              child: ItemPurchaseHistorySection(
                itemId: 'item-1',
                itemName: 'Sugar',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/purchase/new',
          builder: (_, __) => const Scaffold(body: Text('new-purchase')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tradePurchasesForItemProvider('item-1').overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show all time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New purchase'));
    await tester.pumpAndSettle();
    expect(find.text('new-purchase'), findsOneWidget);
  });
}
