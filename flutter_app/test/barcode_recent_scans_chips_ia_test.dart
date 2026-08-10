import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/barcode_recent_scans.dart';
import 'package:harisree_warehouse/features/barcode/presentation/widgets/barcode_recent_scans_chips.dart';

void main() {
  testWidgets('barcode recent scans use Wrap not horizontal ListView',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarcodeRecentScansChips(
            scans: const [
              BarcodeRecentScan(id: '1', name: 'Rice bag long name', code: 'R1'),
              BarcodeRecentScan(id: '2', name: 'Oil', code: 'O1'),
              BarcodeRecentScan(id: '3', name: 'Sugar', code: 'S1'),
              BarcodeRecentScan(id: '4', name: 'Flour', code: 'F1'),
              BarcodeRecentScan(id: '5', name: 'Spices', code: 'SP1'),
            ],
            enabled: true,
            onCodeSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Rice'), findsOneWidget);
    expect(find.text('Spices'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
  });
}
