import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/design_system/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField keeps text, cursor, and focus after window resize',
      (tester) async {
    final ctrl = TextEditingController();
    final focus = FocusNode();
    addTearDown(ctrl.dispose);
    addTearDown(focus.dispose);

    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            controller: ctrl,
            focusNode: focus,
            label: 'Item name',
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Rava 30kg');
    ctrl.selection = const TextSelection.collapsed(offset: 4);
    focus.requestFocus();
    await tester.pump();

    expect(ctrl.text, 'Rava 30kg');
    expect(focus.hasFocus, isTrue);
    expect(ctrl.selection.baseOffset, 4);

    await tester.binding.setSurfaceSize(const Size(1100, 800));
    await tester.pump();

    expect(ctrl.text, 'Rava 30kg');
    expect(focus.hasFocus, isTrue);
    expect(ctrl.selection.baseOffset, 4);
  });
}
