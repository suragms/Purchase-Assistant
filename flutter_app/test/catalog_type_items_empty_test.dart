import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/catalog_providers.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_type_items_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty type items shows HexaEmptyState + Add item',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const CatalogTypeItemsPage(
            categoryId: 'cat-1',
            typeId: 'type-1',
          ),
        ),
        GoRoute(
          path: '/catalog/category/:cid/type/:tid/add-item',
          builder: (_, __) => const Scaffold(body: Text('add-item-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryTypesIndexProvider.overrideWith(
            (ref) async => [
              {
                'id': 'type-1',
                'name': 'Basmati',
                'category_id': 'cat-1',
              },
            ],
          ),
          catalogItemsListProvider.overrideWith((ref) async => const []),
          categoryTradeSummaryProvider('cat-1').overrideWith(
            (ref) async => const {'items': <dynamic>[]},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);
    // FAB + empty CTA share the label.
    expect(find.text('Add item'), findsNWidgets(2));
    expect(find.text('No items yet — tap Add item.'), findsNothing);

    await tester.tap(find.text('Add item').last);
    await tester.pumpAndSettle();
    expect(find.text('add-item-page'), findsOneWidget);
  });

  testWidgets('filtered empty type items offers Clear filter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryTypesIndexProvider.overrideWith(
            (ref) async => [
              {
                'id': 'type-1',
                'name': 'Basmati',
                'category_id': 'cat-1',
              },
            ],
          ),
          catalogItemsListProvider.overrideWith(
            (ref) async => [
              {
                'id': 'item-1',
                'name': 'India Gate',
                'type_id': 'type-1',
                'category_id': 'cat-1',
              },
            ],
          ),
          categoryTradeSummaryProvider('cat-1').overrideWith(
            (ref) async => const {'items': <dynamic>[]},
          ),
        ],
        child: const MaterialApp(
          home: CatalogTypeItemsPage(
            categoryId: 'cat-1',
            typeId: 'type-1',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('India Gate'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzzzzzzzz');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
    expect(find.text('Clear filter'), findsOneWidget);
    expect(find.text('No matches.'), findsNothing);

    await tester.tap(find.text('Clear filter'));
    await tester.pumpAndSettle();
    expect(find.text('India Gate'), findsOneWidget);
  });
}
