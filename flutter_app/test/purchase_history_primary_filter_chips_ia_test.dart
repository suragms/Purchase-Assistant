import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/purchase/presentation/widgets/purchase_history_primary_filter_chips.dart';

void main() {
  testWidgets('purchase history filters use Wrap not horizontal ListView',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var primary = 'all';
    var undeliveredSort = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PurchaseHistoryPrimaryFilterChips(
                primary: primary,
                secondary: null,
                undeliveredSort: undeliveredSort,
                onSelectPrimary: (k) => setState(() => primary = k),
                onUndeliveredSortChanged: (on) =>
                    setState(() => undeliveredSort = on),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wait ↑'), findsOneWidget);
    expect(find.text('Undelivered'), findsOneWidget);
    expect(find.text('Stuck'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );

    await tester.tap(find.text('Due'));
    await tester.pumpAndSettle();
    expect(primary, 'due');
  });
}
