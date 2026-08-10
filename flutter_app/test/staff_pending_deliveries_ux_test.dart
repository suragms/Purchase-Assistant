import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/models/trade_purchase_models.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/core/providers/trade_purchases_provider.dart';
import 'package:harisree_warehouse/features/staff/presentation/staff_pending_deliveries_page.dart';

TradePurchase _samplePurchase() {
  return TradePurchase(
    id: 'p1',
    humanId: 'PUR-100',
    purchaseDate: DateTime(2026, 8, 1),
    paidAmount: 0,
    totalAmount: 1000,
    storedStatus: 'confirmed',
    derivedStatus: 'confirmed',
    remaining: 1000,
    supplierName: 'Test Supplier',
    deliveryStatus: 'dispatched',
    lines: const [],
  );
}

void main() {
  testWidgets('pending delivery tile shows Receive affordance', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffPendingDeliveryTile(
            index: 1,
            purchase: _samplePurchase(),
          ),
        ),
      ),
    );

    expect(find.text('Receive'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    expect(find.text('Test Supplier'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty deliveries shows icon message and scan action',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StaffPendingDeliveriesPage(),
        ),
        GoRoute(
          path: '/barcode/scan',
          builder: (_, __) => const Scaffold(body: Text('scan')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffDeliverySectionsProvider.overrideWithValue(
            const StaffDeliverySections(),
          ),
          staffTradePurchasesForAlertsProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('No pending deliveries'), findsOneWidget);
    expect(find.text('Scan barcode'), findsOneWidget);
    expect(find.text('Dispatched'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('partial sections hide empty headers', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffDeliverySectionsProvider.overrideWithValue(
            StaffDeliverySections(dispatched: [_samplePurchase()]),
          ),
          staffTradePurchasesForAlertsProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: const MaterialApp(
          home: StaffPendingDeliveriesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dispatched (1)'), findsOneWidget);
    expect(find.text('Arrived'), findsNothing);
    expect(find.text('Pending verification'), findsNothing);
    expect(find.text('No dispatches in transit.'), findsNothing);
    expect(find.text('Nothing waiting at the warehouse.'), findsNothing);
  });
}
