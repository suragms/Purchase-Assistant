import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/operations_providers.dart';
import 'package:harisree_warehouse/features/reports/stock/reports_stock_providers.dart';
import 'package:harisree_warehouse/features/reports/stock/reports_stock_status.dart';
import 'package:harisree_warehouse/features/reports/tabs/reports_stock_tab.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('stock empty all filter shows HexaEmptyState + Open stock',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: ReportsStockEmpty(filter: ReportsStockChipFilter.all),
          ),
        ),
        GoRoute(
          path: '/stock',
          builder: (_, __) => const Scaffold(body: Text('stock-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No stock items match'), findsOneWidget);
    expect(find.text('Open stock'), findsOneWidget);
    expect(find.text('No stock items match your search.'), findsNothing);

    await tester.tap(find.text('Open stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });

  testWidgets('stock empty dead filter clears chip on Clear filter',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          operationalReportsProvider.overrideWith(
            (ref) async => {
              'items': <dynamic>[],
              'summary': <String, dynamic>{},
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(
                body: ReportsStockEmpty(filter: ReportsStockChipFilter.dead),
              ),
            );
          },
        ),
      ),
    );

    container.read(reportsStockChipFilterProvider.notifier).state =
        ReportsStockChipFilter.dead;
    await tester.pumpAndSettle();

    expect(find.text('No dead stock found'), findsOneWidget);
    expect(find.text('Clear filter'), findsOneWidget);

    await tester.tap(find.text('Clear filter'));
    await tester.pumpAndSettle();
    expect(
      container.read(reportsStockChipFilterProvider),
      ReportsStockChipFilter.all,
    );
  });
}
