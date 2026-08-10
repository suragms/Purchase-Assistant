import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/features/contacts/presentation/category_items_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty category items shows HexaEmptyState + Back to Contacts',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const CategoryItemsPage(category: 'Grains'),
        ),
        GoRoute(
          path: '/contacts',
          builder: (_, __) => const Scaffold(body: Text('contacts-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsCategoryItemsProvider('Grains').overrideWith(
            (ref) async => const [],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No line items in this period'), findsOneWidget);
    expect(find.text('Back to Contacts'), findsOneWidget);
    expect(
      find.text(
        'No purchase lines in this category for the last 90 days.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'No line items in this category for the last 90 days.',
      ),
      findsNothing,
    );

    await tester.tap(find.text('Back to Contacts'));
    await tester.pumpAndSettle();
    expect(find.text('contacts-page'), findsOneWidget);
  });
}
