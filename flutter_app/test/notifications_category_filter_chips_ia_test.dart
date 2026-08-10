import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/notifications_provider.dart';
import 'package:harisree_warehouse/features/notifications/presentation/widgets/notifications_category_filter_chips.dart';

void main() {
  testWidgets('notifications category filters use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = NotificationCategoryFilter.all;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return NotificationsCategoryFilterChips(
                filters: NotificationCategoryFilter.values,
                selected: selected,
                onSelected: (f) => setState(() => selected = f),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
    expect(find.byType(ListView), findsNothing);

    await tester.tap(find.text('Critical'));
    await tester.pumpAndSettle();
    expect(selected, NotificationCategoryFilter.critical);
  });
}
