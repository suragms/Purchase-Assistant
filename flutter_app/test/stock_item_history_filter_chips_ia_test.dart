import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/stock/presentation/widgets/stock_item_history_filter_chips.dart';

void main() {
  testWidgets('stock item history filters use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = StockItemHistoryFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return StockItemHistoryFilterChips(
                selected: selected,
                onSelected: (f) => setState(() => selected = f),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All time'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );

    await tester.tap(find.text('This week'));
    await tester.pumpAndSettle();
    expect(selected, StockItemHistoryFilter.week);
  });
}
