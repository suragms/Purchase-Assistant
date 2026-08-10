import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/trade_purchases_provider.dart';
import 'package:harisree_warehouse/features/catalog/presentation/widgets/item_supplier_intelligence_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('supplier intel empty shows HexaEmptyState + New purchase',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              child: ItemSupplierIntelligenceSection(
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

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchases recorded yet'), findsOneWidget);
    expect(find.text('No purchases recorded yet.'), findsNothing);
    expect(find.text('New purchase'), findsOneWidget);

    await tester.tap(find.text('New purchase'));
    await tester.pumpAndSettle();
    expect(find.text('new-purchase'), findsOneWidget);
  });
}
