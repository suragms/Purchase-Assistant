import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/barcode_recent_scans.dart';
import 'package:harisree_warehouse/core/providers/staff_home_providers.dart';
import 'package:harisree_warehouse/features/staff/presentation/widgets/staff_home_dashboard_widgets.dart';

void main() {
  testWidgets('staff home recent scans use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffRecentScansProvider.overrideWith(
            (ref) async => const [
              BarcodeRecentScan(id: '1', name: 'Rice', code: 'R1'),
              BarcodeRecentScan(id: '2', name: 'Oil', code: 'O1'),
              BarcodeRecentScan(id: '3', name: 'Sugar', code: 'S1'),
              BarcodeRecentScan(id: '4', name: 'Flour', code: 'F1'),
              BarcodeRecentScan(id: '5', name: 'Spices', code: 'SP1'),
            ],
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StaffHomeRecentScansStrip(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent scans'), findsOneWidget);
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Spices'), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
      ),
      findsNothing,
    );
  });
}
