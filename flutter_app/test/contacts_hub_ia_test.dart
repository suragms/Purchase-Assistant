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
  test('contactsTabIndexFromQuery maps deep links', () {
    expect(contactsTabIndexFromQuery(null), 0);
    expect(contactsTabIndexFromQuery('brokers'), 1);
    expect(contactsTabIndexFromQuery('categories'), 2);
    expect(contactsTabIndexFromQuery('types'), 3);
    expect(contactsTabIndexFromQuery('items'), 4);
  });

  test('contactsHubForTabIndex splits people vs catalog', () {
    expect(contactsHubForTabIndex(0), ContactsHubSection.people);
    expect(contactsHubForTabIndex(1), ContactsHubSection.people);
    expect(contactsHubForTabIndex(2), ContactsHubSection.catalog);
    expect(contactsHubForTabIndex(4), ContactsHubSection.catalog);
    expect(contactsLocalIndexForTab(3), 1);
  });

  testWidgets('Contacts people hub shows two tabs not five', (tester) async {
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
          itemCategoriesListProvider.overrideWith((ref) async => const []),
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
          home: ContactsPage(initialTab: 0),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('People'), findsOneWidget);
    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Suppliers'), findsWidgets);
    expect(find.text('Brokers'), findsWidgets);
    expect(find.text('Categories'), findsNothing);
    expect(find.text('Types'), findsNothing);
    expect(find.text('Items'), findsNothing);
    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No suppliers yet'), findsOneWidget);
    expect(find.text('Add supplier'), findsOneWidget);

    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Types'), findsWidgets);
    expect(find.text('Items'), findsWidgets);
    expect(find.text('Suppliers'), findsNothing);
    expect(find.text('Brokers'), findsNothing);
    expect(find.text('No categories yet'), findsOneWidget);
    expect(find.text('Add category'), findsOneWidget);
  });

  testWidgets('Contacts deep link to categories opens Catalog hub',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsSuppliersEnrichedProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          contactsBrokersEnrichedProvider.overrideWith(
            (ref) async => const <Map<String, dynamic>>[],
          ),
          itemCategoriesListProvider.overrideWith((ref) async => const []),
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

    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Suppliers'), findsNothing);
  });
}
