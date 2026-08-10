import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/staff/presentation/widgets/staff_gallery_subcategory_filter_chips.dart';

void main() {
  testWidgets('staff gallery subcategory filters use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return StaffGallerySubcategoryFilterChips(
                subs: const ['Rice', 'Oil', 'Sugar', 'Flour', 'Spices'],
                selected: selected,
                onSelected: (sub) => setState(() => selected = sub),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Spices'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );

    await tester.tap(find.text('Oil'));
    await tester.pumpAndSettle();
    expect(selected, 'Oil');
  });
}
