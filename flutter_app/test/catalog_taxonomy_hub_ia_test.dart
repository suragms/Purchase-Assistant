import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/catalog/catalog_taxonomy_utils.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_taxonomy_hub_page.dart';

void main() {
  test('typesForCategory scopes index to one category', () {
    final index = [
      {'id': 't1', 'name': 'Biriyani', 'category_id': 'c1'},
      {'id': 't2', 'name': 'Matta', 'category_id': 'c1'},
      {'id': 't3', 'name': 'Sunflower', 'category_id': 'c2'},
    ];
    final types = typesForCategory(index, 'c1');
    expect(types.length, 2);
    expect(types.map((t) => t['name']), ['Biriyani', 'Matta']);
  });

  testWidgets('category tile expands to show subcategory types inline',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? openedType;
    var addTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogTaxonomyCategoryTile(
            categoryId: 'c1',
            categoryName: 'Rice',
            subcategoryCount: 2,
            showOpenDetail: true,
            types: const [
              {'id': 't1', 'name': 'Biriyani rice'},
              {'id': 't2', 'name': 'Matta rice'},
            ],
            onAddSubcategory: () => addTaps++,
            onOpenDetail: () {},
            onOpenType: (id) => openedType = id,
          ),
        ),
      ),
    );

    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('How categories work'), findsNothing);
    expect(find.text('Biriyani rice'), findsNothing);

    await tester.tap(find.text('Rice'));
    await tester.pumpAndSettle();

    expect(find.text('Biriyani rice'), findsOneWidget);
    expect(find.text('Matta rice'), findsOneWidget);

    await tester.tap(find.text('Biriyani rice'));
    await tester.pumpAndSettle();
    expect(openedType, 't1');

    await tester.tap(find.byTooltip('Add subcategory'));
    expect(addTaps, 1);
  });

  testWidgets('staff tile hides open-detail affordance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogTaxonomyCategoryTile(
            categoryId: 'c1',
            categoryName: 'Oil',
            subcategoryCount: 0,
            showOpenDetail: false,
            types: const [],
            onAddSubcategory: () {},
            onOpenDetail: null,
            onOpenType: (_) {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Open category'), findsNothing);
    expect(find.byTooltip('Add subcategory'), findsOneWidget);
  });
}
