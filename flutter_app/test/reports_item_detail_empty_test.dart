import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/core/providers/reports_item_bundle_provider.dart';
import 'package:harisree_warehouse/core/providers/reports_provider.dart';
import 'package:harisree_warehouse/features/reports/drill/reports_item_report_page.dart';
import 'package:harisree_warehouse/features/reports/presentation/reports_item_detail_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('item detail empty lines shows HexaEmptyState + Back to Reports',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const ReportsItemDetailPage(
            itemKey: 'k1',
            itemName: 'Basmati',
          ),
        ),
        GoRoute(
          path: '/reports',
          builder: (_, __) => const Scaffold(body: Text('reports-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportsPurchasesMergedProvider.overrideWith((ref) => const []),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No lines in this period'), findsOneWidget);
    expect(find.text('Back to Reports'), findsWidgets);
    expect(
      find.text('No classified lines for this item in the selected period.'),
      findsNothing,
    );

    await tester.tap(find.text('Back to Reports').first);
    await tester.pumpAndSettle();
    expect(find.text('reports-page'), findsOneWidget);
  });

  testWidgets('item report empty lines shows HexaEmptyState + Back to Reports',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const ReportsItemReportPage(
            catalogItemId: 'item-1',
            itemName: 'Basmati',
          ),
        ),
        GoRoute(
          path: '/reports',
          builder: (_, __) => const Scaffold(body: Text('reports-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportsItemBundleProvider('item-1').overrideWith(
            (ref) async => {
              'item_name': 'Basmati',
              'item': {'id': 'item-1', 'name': 'Basmati', 'unit': 'kg'},
              'summary': <String, dynamic>{},
              'lines': <dynamic>[],
            },
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No purchases in this period'), findsOneWidget);
    expect(find.text('Back to Reports'), findsOneWidget);
    expect(
      find.textContaining('No purchases for this item in the selected period'),
      findsNothing,
    );

    await tester.tap(find.text('Back to Reports'));
    await tester.pumpAndSettle();
    expect(find.text('reports-page'), findsOneWidget);
  });
}
