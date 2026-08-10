import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/reports/filters/reports_filter_search_section.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('reports filter search empty uses HexaEmptyState', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsFilterSearchEmpty(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No matches'), findsOneWidget);
    expect(
      find.text('Try another search term or clear the field.'),
      findsOneWidget,
    );
  });
}
