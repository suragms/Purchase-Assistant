import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/shared/widgets/operational_ui.dart';

void main() {
  testWidgets('OperationalPillRow wraps — no horizontal ListView', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = 'Today';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return OperationalPillRow(
                labels: const [
                  'Today',
                  'Week',
                  'Month',
                  'Year',
                  'All time',
                  'Custom',
                ],
                selected: selected,
                onSelected: (v) => setState(() => selected = v),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(selected, 'Week');
  });
}
