import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/barcode/presentation/bulk_barcode_print_preview_panel.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('bulk barcode preview empty uses HexaEmptyState', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BulkBarcodePrintPreviewEmpty(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Tap preview on a row'), findsOneWidget);
    expect(
      find.text('Choose an item on the left to see its label here.'),
      findsOneWidget,
    );
  });
}
