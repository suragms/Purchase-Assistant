import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/barcode/presentation/barcode_print_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('no-label empty shows HexaEmptyState + Edit item code',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarcodePrintNoLabelEmpty(
            onEditItemCode: () async {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No label data'), findsOneWidget);
    expect(find.text('Edit item code'), findsOneWidget);

    await tester.tap(find.text('Edit item code'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('no-label empty without edit action has no CTA', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BarcodePrintNoLabelEmpty(),
        ),
      ),
    );

    expect(find.text('No label data'), findsOneWidget);
    expect(find.text('Edit item code'), findsNothing);
  });
}
