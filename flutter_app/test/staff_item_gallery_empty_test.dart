import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/features/staff/presentation/staff_item_gallery_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty staff gallery shows HexaEmptyState + Scan barcode',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const StaffItemGalleryPage(),
        ),
        GoRoute(
          path: '/staff/scan',
          builder: (_, __) => const Scaffold(body: Text('scan-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffGalleryStockProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No items yet'), findsOneWidget);
    expect(find.text('Scan barcode'), findsOneWidget);
    // 5 filter chips use Wrap, not a horizontal ListView shell.
    expect(find.byType(Wrap), findsWidgets);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Opening'), findsOneWidget);

    await tester.tap(find.text('Scan barcode'));
    await tester.pumpAndSettle();
    expect(find.text('scan-page'), findsOneWidget);
  });

  testWidgets('filtered empty gallery offers Clear filters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffGalleryStockProvider.overrideWith(
            (ref) async => [
              {
                'id': '1',
                'name': 'Rice bag',
                'item_code': 'R1',
                'missing_barcode': false,
                'current_stock': 10,
                'reorder_level': 1,
                'stock_status': 'ok',
                'opening_stock_set': true,
                'category_name': 'Grains',
                'subcategory_name': 'Rice',
              },
            ],
          ),
        ],
        child: const MaterialApp(
          home: StaffItemGalleryPage(initialFilter: 'missing_barcode'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No items match'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsNothing);
    expect(find.text('Grains'), findsOneWidget);
    expect(find.text('1 items · 1 categories'), findsOneWidget);
  });
}
