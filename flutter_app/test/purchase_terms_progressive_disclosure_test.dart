import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/purchase/presentation/wizard/purchase_terms_only_step.dart';

void main() {
  testWidgets(
      'empty Discount & narration stay collapsed until ExpansionTile opened',
      (tester) async {
    final paymentDays = TextEditingController();
    final commission = TextEditingController();
    final headerDisc = TextEditingController();
    final narration = TextEditingController();
    final paymentFocus = FocusNode();

    addTearDown(() {
      paymentDays.dispose();
      commission.dispose();
      headerDisc.dispose();
      narration.dispose();
      paymentFocus.dispose();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PurchaseTermsOnlyStep(
                paymentDaysFocus: paymentFocus,
                paymentDaysCtrl: paymentDays,
                commissionCtrl: commission,
                headerDiscCtrl: headerDisc,
                narrationCtrl: narration,
                onDraftChanged: () {},
                embeddedInOuterScroll: true,
                desktop: false,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Payment days'), findsOneWidget);
    expect(find.text('Discount & narration'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    // Collapsed: discount / narration labels not in tree until expand.
    expect(find.text('Discount %'), findsNothing);
    expect(find.text('Narration / ref (optional)'), findsNothing);

    await tester.tap(find.text('Discount & narration'));
    await tester.pumpAndSettle();

    expect(find.text('Discount %'), findsOneWidget);
    expect(find.text('Narration / ref (optional)'), findsOneWidget);
  });

  testWidgets(
      'Discount & narration auto-expand when discount already has a value',
      (tester) async {
    final paymentDays = TextEditingController();
    final commission = TextEditingController();
    final headerDisc = TextEditingController(text: '2');
    final narration = TextEditingController();
    final paymentFocus = FocusNode();

    addTearDown(() {
      paymentDays.dispose();
      commission.dispose();
      headerDisc.dispose();
      narration.dispose();
      paymentFocus.dispose();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PurchaseTermsOnlyStep(
                paymentDaysFocus: paymentFocus,
                paymentDaysCtrl: paymentDays,
                commissionCtrl: commission,
                headerDiscCtrl: headerDisc,
                narrationCtrl: narration,
                onDraftChanged: () {},
                embeddedInOuterScroll: true,
                desktop: false,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Discount %'), findsOneWidget);
    expect(find.text('Narration / ref (optional)'), findsOneWidget);
  });
}
