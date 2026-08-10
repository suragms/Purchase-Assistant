import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/contacts/presentation/supplier_create_wizard_page.dart';

void main() {
  test('optional steps are 1–3; review is index 4', () {
    expect(supplierWizardStepIsOptional(0), isFalse);
    expect(supplierWizardStepIsOptional(1), isTrue);
    expect(supplierWizardStepIsOptional(2), isTrue);
    expect(supplierWizardStepIsOptional(3), isTrue);
    expect(supplierWizardStepIsOptional(4), isFalse);
    expect(kSupplierWizardReviewStep, 4);
    expect(kSupplierWizardStepTitles.length, 5);
  });

  testWidgets('step rail Wrap exposes all steps without horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SupplierWizardStepRail(
                currentStep: selected,
                onStepSelected: (i) => setState(() => selected = i),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('1. Basic details'), findsOneWidget);
    expect(find.text('5. Review'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SupplierWizardStepRail),
        matching: find.byType(SingleChildScrollView),
      ),
      findsNothing,
    );
    expect(find.byType(Wrap), findsOneWidget);

    await tester.tap(find.text('5. Review'));
    await tester.pumpAndSettle();
    expect(selected, kSupplierWizardReviewStep);
  });
}
