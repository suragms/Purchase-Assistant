import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/catalog/presentation/catalog_setup_reorder_levels_page.dart';

void main() {
  testWidgets('reorder controllers persist across rebuilds without orphans',
      (tester) async {
    final values = <String, TextEditingController>{};
    addTearDown(() {
      for (final c in values.values) {
        c.dispose();
      }
    });

    final first = catalogReorderControllerFor(values, 'item-a');
    first.text = '12';
    expect(identical(first, catalogReorderControllerFor(values, 'item-a')), isTrue);
    expect(values.length, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              final ctrl = catalogReorderControllerFor(values, 'item-a');
              return Column(
                children: [
                  TextField(controller: ctrl),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Rebuild'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('12'), findsOneWidget);
    await tester.tap(find.text('Rebuild'));
    await tester.pump();
    expect(find.text('12'), findsOneWidget);
    expect(values.length, 1);
    expect(values['item-a']!.text, '12');
  });
}
