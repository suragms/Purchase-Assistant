import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/stock_providers.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_setup_reorder_levels_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('all levels set shows HexaEmptyState + Done', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var popped = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bulkStockListProvider.overrideWith(
            (ref) async => {
              'items': [
                {
                  'id': 'i1',
                  'name': 'Rice',
                  'reorder_level': 5,
                  'category_name': 'Grains',
                },
              ],
            },
          ),
        ],
        child: MaterialApp(
          home: Navigator(
            onDidRemovePage: (_) {
              popped = true;
            },
            pages: const [
              MaterialPage(child: CatalogSetupReorderLevelsPage()),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('All reorder levels set'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('No items match your search'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(popped, isTrue);
  });

  testWidgets('search miss shows Clear search', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bulkStockListProvider.overrideWith(
            (ref) async => {
              'items': [
                {
                  'id': 'i1',
                  'name': 'Basmati',
                  'reorder_level': 0,
                  'category_name': 'Grains',
                  'subcategory_name': 'Rice',
                },
              ],
            },
          ),
        ],
        child: const MaterialApp(home: CatalogSetupReorderLevelsPage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Basmati'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'zzzzznomatch');
    await tester.pumpAndSettle();

    expect(find.text('No items match search'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Basmati'), findsOneWidget);
  });
}
