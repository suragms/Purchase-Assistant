import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_item_timeline_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('timeline empty shows HexaEmptyState + Back to item',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: CatalogItemTimelineEmpty(
              onBackToItem: () => context.go('/catalog/item/item-1'),
            ),
          ),
        ),
        GoRoute(
          path: '/catalog/item/item-1',
          builder: (_, __) => const Scaffold(body: Text('item-page')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No events recorded yet'), findsOneWidget);
    expect(find.text('Back to item'), findsOneWidget);

    await tester.tap(find.text('Back to item'));
    await tester.pumpAndSettle();
    expect(find.text('item-page'), findsOneWidget);
  });
}
