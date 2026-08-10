import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/catalog_providers.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_category_detail_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty category types show HexaEmptyState + Add subcategory',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) =>
              const CatalogCategoryDetailPage(categoryId: 'cat-1'),
        ),
        GoRoute(
          path: '/catalog',
          builder: (_, __) => const Scaffold(body: Text('catalog')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemCategoriesListProvider.overrideWith(
            (ref) async => [
              {'id': 'cat-1', 'name': 'Grains'},
            ],
          ),
          catalogItemsListProvider.overrideWith((ref) async => const []),
          categoryTypesIndexProvider.overrideWith((ref) async => const []),
          categoryTradeSummaryProvider('cat-1').overrideWith(
            (ref) async => const {'item_count': 0},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No subcategories yet'), findsOneWidget);
    // FAB + empty CTA share the label.
    expect(find.text('Add subcategory'), findsNWidgets(2));
    expect(
      find.text('No subcategories yet — tap Add subcategory.'),
      findsNothing,
    );
  });

  testWidgets('filtered empty types offer Clear filter', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemCategoriesListProvider.overrideWith(
            (ref) async => [
              {'id': 'cat-1', 'name': 'Grains'},
            ],
          ),
          catalogItemsListProvider.overrideWith((ref) async => const []),
          categoryTypesIndexProvider.overrideWith(
            (ref) async => [
              {
                'id': 'type-1',
                'name': 'Basmati',
                'category_id': 'cat-1',
              },
            ],
          ),
          categoryTradeSummaryProvider('cat-1').overrideWith(
            (ref) async => const {'item_count': 0},
          ),
        ],
        child: const MaterialApp(
          home: CatalogCategoryDetailPage(categoryId: 'cat-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Basmati'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'qqqqqqqqqqqq');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
    expect(find.text('Clear filter'), findsOneWidget);

    await tester.tap(find.text('Clear filter'));
    await tester.pumpAndSettle();
    expect(find.text('Basmati'), findsOneWidget);
    expect(find.byType(HexaEmptyState), findsNothing);
  });
}
