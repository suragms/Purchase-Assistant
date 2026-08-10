import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_duplicates_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty duplicates shows HexaEmptyState + Open catalog',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const CatalogDuplicatesPage(),
        ),
        GoRoute(
          path: '/catalog',
          builder: (_, __) => const Scaffold(body: Text('catalog-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogDuplicatesProvider.overrideWith(
            (ref) async => const {'pairs': <dynamic>[]},
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No similar names found'), findsOneWidget);
    expect(find.text('Open catalog'), findsOneWidget);
    expect(
      find.text('No similar item names found. Good catalog hygiene.'),
      findsNothing,
    );

    await tester.tap(find.text('Open catalog'));
    await tester.pumpAndSettle();
    expect(find.text('catalog-page'), findsOneWidget);
  });
}
