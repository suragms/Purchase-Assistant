import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/features/staff/presentation/staff_purchase_history_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty today purchases shows HexaEmptyState + Refresh',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffTradePurchasesHistoryProvider(StaffPurchaseHistoryPeriod.today)
              .overrideWith((ref) async => const []),
          staffTradePurchasesHistoryProvider(StaffPurchaseHistoryPeriod.week)
              .overrideWith((ref) async => const []),
          staffTradePurchasesHistoryProvider(
                  StaffPurchaseHistoryPeriod.allTime)
              .overrideWith((ref) async => const []),
          staffLowStockAlertsProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: StaffPurchaseHistoryPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchase orders in this period'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
  });

  testWidgets('empty low stock tab shows HexaEmptyState + Open stock',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StaffPurchaseHistoryPage(),
        ),
        GoRoute(
          path: '/stock',
          builder: (_, __) => const Scaffold(body: Text('stock-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffTradePurchasesHistoryProvider(StaffPurchaseHistoryPeriod.today)
              .overrideWith((ref) async => const []),
          staffTradePurchasesHistoryProvider(StaffPurchaseHistoryPeriod.week)
              .overrideWith((ref) async => const []),
          staffTradePurchasesHistoryProvider(
                  StaffPurchaseHistoryPeriod.allTime)
              .overrideWith((ref) async => const []),
          staffLowStockAlertsProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();
    final lowTab = find.textContaining('Low stock');
    await tester.ensureVisible(lowTab);
    await tester.tap(lowTab);
    await tester.pumpAndSettle();

    expect(find.text('No low stock items'), findsOneWidget);
    expect(find.text('Open stock'), findsOneWidget);

    await tester.tap(find.text('Open stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });
}
