import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/design_system/widgets/app_text_field.dart';

void main() {
  testWidgets('UX-195 filled AppTextField floating label clears value text',
      (tester) async {
    final ctrl = TextEditingController(text: '916 RAVA 30 KG');
    addTearDown(ctrl.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: ctrl,
              label: 'Name *',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Unfocused filled — floating label must sit above the value glyph box.
    final label = tester.getTopLeft(find.text('Name *'));
    final value = tester.getTopLeft(find.text('916 RAVA 30 KG'));
    expect(label.dy, lessThan(value.dy - 2));
  });
}
