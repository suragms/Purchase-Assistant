import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/item_detail_providers.dart';
import 'package:harisree_warehouse/core/providers/stock_detail_providers.dart';
import 'package:harisree_warehouse/features/catalog/presentation/widgets/item_ledger_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('ledger empty shows HexaEmptyState + View all time',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: SingleChildScrollView(
              child: ItemLedgerSection(itemId: 'item-1'),
            ),
          ),
        ),
        GoRoute(
          path: '/catalog/item/:id/ledger',
          builder: (_, __) => const Scaffold(body: Text('full-ledger')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockItemActivityProvider('item-1').overrideWith(
            (ref) async => <String, dynamic>{
              'activity': <dynamic>[],
            },
          ),
          itemDetailStockProvider('item-1').overrideWithValue(null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No ledger entries in this range'), findsOneWidget);
    expect(find.text('No ledger entries in this range.'), findsNothing);
    expect(find.text('View all time'), findsOneWidget);

    await tester.tap(find.text('View all time'));
    await tester.pumpAndSettle();

    expect(find.text('No ledger entries'), findsOneWidget);
    expect(find.text('Full statement'), findsWidgets);

    await tester.tap(find.text('Full statement').last);
    await tester.pumpAndSettle();
    expect(find.text('full-ledger'), findsOneWidget);
  });
}
