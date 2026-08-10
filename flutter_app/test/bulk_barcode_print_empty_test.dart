import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/barcode/presentation/bulk_barcode_print_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('bulk print empty list shows HexaEmptyState + Open catalog',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BulkBarcodePrintListEmpty(
            filtersActive: false,
            onClearFilters: () {},
            onOpenCatalog: () => opened = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No items to print'), findsOneWidget);
    expect(find.text('Open catalog'), findsOneWidget);

    await tester.tap(find.text('Open catalog'));
    await tester.pump();
    expect(opened, isTrue);
  });

  testWidgets('bulk print filter miss shows Clear filters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BulkBarcodePrintListEmpty(
            filtersActive: true,
            onClearFilters: () => cleared = true,
            onOpenCatalog: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No items match filters'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    expect(cleared, isTrue);
  });
}
