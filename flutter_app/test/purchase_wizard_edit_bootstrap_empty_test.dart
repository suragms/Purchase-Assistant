import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/purchase/presentation/purchase_entry_wizard.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('edit bootstrap error uses HexaEmptyState + Retry / Go back',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var retried = false;
    var wentBack = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PurchaseWizardEditBootstrapError(
            message: 'Weak signal — try again.',
            onRetry: () => retried = true,
            onGoBack: () => wentBack = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text("Couldn't load this purchase"), findsOneWidget);
    expect(find.text('Weak signal — try again.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(retried, isTrue);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();
    expect(wentBack, isTrue);
  });
}
