import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/stock_providers.dart';
import 'package:harisree_warehouse/features/stock/presentation/stock_missing_labels_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('missing barcode tab empty shows HexaEmptyState + Open stock',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StockMissingLabelsPage(),
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
          bulkStockListProvider.overrideWith(
            (ref) async => <String, dynamic>{
              'items': <dynamic>[],
            },
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('All items have packaging barcodes'), findsOneWidget);
    expect(find.text('Open stock'), findsOneWidget);

    await tester.tap(find.text('Open stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });

  testWidgets('missing item code tab empty shows HexaEmptyState', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bulkStockListProvider.overrideWith(
            (ref) async => <String, dynamic>{
              'items': <dynamic>[],
            },
          ),
        ],
        child: const MaterialApp(home: StockMissingLabelsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Missing item code'));
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('All items have internal codes'), findsOneWidget);
    expect(find.text('Open stock'), findsOneWidget);
  });
}
