import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/operations_providers.dart';
import 'package:harisree_warehouse/features/reports/widgets/reports_stock_filter_sort_bar.dart';

void main() {
  testWidgets('reports stock filters use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          operationalReportsProvider.overrideWith(
            (ref) async => {
              'items': <dynamic>[],
              'summary': <String, dynamic>{
                'all': 0,
                'active': 0,
                'slow': 0,
                'dead': 0,
                'fast': 0,
              },
            },
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReportsStockFilterSortBar()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('All'), findsWidgets);
    expect(find.textContaining('Dead'), findsOneWidget);
    expect(find.textContaining('Fast'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
  });
}
