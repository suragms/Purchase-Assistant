import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/reports/reports_bi_tab.dart';
import 'package:harisree_warehouse/features/reports/shell/reports_primary_tabs.dart';

void main() {
  testWidgets('Reports primary tabs use TabBar not ChoiceChip', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = ReportsBiTab.overview;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ReportsPrimaryTabs(
                selected: selected,
                onSelected: (t) => setState(() => selected = t),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Purchases'), findsOneWidget);
    expect(find.text('Stock'), findsOneWidget);

    await tester.tap(find.text('Purchases'));
    await tester.pumpAndSettle();
    expect(selected, ReportsBiTab.purchases);
  });
}
