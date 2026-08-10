import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/search/presentation/widgets/search_section_filter_chips.dart';

void main() {
  testWidgets('search section filters use Wrap not horizontal ListView',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = 'all';
    const sections = <(String, String)>[
      ('all', 'All'),
      ('bills', 'Purchases'),
      ('items', 'Items'),
      ('suppliers', 'Suppliers'),
      ('brokers', 'Brokers'),
      ('types', 'Types'),
      ('contacts', 'Contacts'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SearchSectionFilterChips(
                sections: sections,
                selected: selected,
                onSelected: (id) => setState(() => selected = id),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );

    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();
    expect(selected, 'items');
  });
}
