import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/reorder_list_provider.dart';
import 'package:harisree_warehouse/features/stock/presentation/reorder_list_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty pending reorder list shows HexaEmptyState + Open stock',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const ReorderListPage(),
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
          reorderListProvider('pending').overrideWith((ref) async => const []),
          reorderListProvider('ordered').overrideWith((ref) async => const []),
          reorderListProvider('done').overrideWith((ref) async => const []),
          reorderPendingCountProvider.overrideWith((ref) async => 0),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsWidgets);
    expect(find.text('No pending reorders'), findsOneWidget);
    expect(find.text('Open stock'), findsOneWidget);
    expect(find.text('Add items from stock or item detail'), findsNothing);

    await tester.tap(find.text('Open stock'));
    await tester.pumpAndSettle();
    expect(find.text('stock-page'), findsOneWidget);
  });

  testWidgets('reorder search miss shows Clear search', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reorderListProvider('pending').overrideWith(
            (ref) async => [
              {
                'id': 'r1',
                'item_id': 'i1',
                'item_name': 'Basmati 25kg',
                'supplier_name': 'Acme',
                'added_by_name': 'Owner',
              },
            ],
          ),
          reorderListProvider('ordered').overrideWith((ref) async => const []),
          reorderListProvider('done').overrideWith((ref) async => const []),
          reorderPendingCountProvider.overrideWith((ref) async => 1),
        ],
        child: const MaterialApp(home: ReorderListPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Basmati 25kg'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzzznomatch');
    await tester.pumpAndSettle();

    expect(find.text('No items match search'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Basmati 25kg'), findsOneWidget);
  });
}
