import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/brokers_list_provider.dart';
import 'package:harisree_warehouse/core/providers/catalog_providers.dart';
import 'package:harisree_warehouse/core/providers/contacts_hub_provider.dart';
import 'package:harisree_warehouse/core/providers/suppliers_list_provider.dart';
import 'package:harisree_warehouse/features/contacts/presentation/contacts_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets(
      'Contacts catalog search miss shows HexaEmptyState + Clear search',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsSuppliersEnrichedProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          contactsBrokersEnrichedProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          itemCategoriesListProvider.overrideWith(
            (ref) async => [
              {'id': 'cat-1', 'name': 'Grains'},
            ],
          ),
          catalogItemsListProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          suppliersListProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          brokersListProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
        ],
        child: const MaterialApp(
          home: ContactsPage(initialTab: 2),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Grains'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzznomatch');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No category matches'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
    expect(find.text('No category matches.'), findsNothing);

    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Grains'), findsOneWidget);
    expect(find.text('No category matches'), findsNothing);
  });
}
