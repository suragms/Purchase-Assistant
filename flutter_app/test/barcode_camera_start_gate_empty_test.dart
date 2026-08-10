import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/barcode/presentation/barcode_mobile_scanner_view.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('barcode camera start gate uses HexaEmptyState + Start camera',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var started = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarcodeCameraStartGate(
            busy: false,
            onStart: () => started = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Tap to start camera'), findsOneWidget);
    expect(find.text('Start camera'), findsOneWidget);

    await tester.tap(find.text('Start camera'));
    await tester.pumpAndSettle();
    expect(started, isTrue);
  });
}
