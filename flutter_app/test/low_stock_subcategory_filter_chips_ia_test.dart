import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/low_stock_category_tree.dart';

void main() {
  testWidgets('low-stock subcategory filters use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LowStockSubcategoryFilterChips(
                subs: const ['Rice', 'Oil', 'Sugar', 'Flour', 'Spices'],
                countsBySub: const {
                  'Rice': 2,
                  'Oil': 1,
                  'Sugar': 3,
                  'Flour': 1,
                  'Spices': 4,
                },
                selected: selected,
                onSelected: (sub) => setState(() => selected = sub),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All (11)'), findsOneWidget);
    expect(find.textContaining('Spices'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );

    await tester.tap(find.textContaining('Oil'));
    await tester.pumpAndSettle();
    expect(selected, 'Oil');
  });
}
