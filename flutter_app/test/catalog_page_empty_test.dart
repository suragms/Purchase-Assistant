import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/catalog_providers.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty catalog shows HexaEmptyState + Add category',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemCategoriesListProvider.overrideWith((ref) async => const []),
          catalogItemsListProvider.overrideWith((ref) async => const []),
          categoryTypesIndexProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No categories yet'), findsOneWidget);
    // FAB + empty CTA share the label.
    expect(find.text('Add category'), findsNWidgets(2));
  });

  testWidgets('catalog search miss shows Clear search', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemCategoriesListProvider.overrideWith(
            (ref) async => [
              {'id': 'c1', 'name': 'Grains'},
            ],
          ),
          catalogItemsListProvider.overrideWith((ref) async => const []),
          categoryTypesIndexProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: CatalogPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Grains'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzzznomatch');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('No matches'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Grains'), findsOneWidget);
  });
}
