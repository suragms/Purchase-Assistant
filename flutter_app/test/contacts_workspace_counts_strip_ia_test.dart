import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/contacts/presentation/widgets/contacts_workspace_counts_strip.dart';

void main() {
  testWidgets('contacts workspace counts use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContactsWorkspaceCountsStrip(
            loading: false,
            suppliers: 2,
            brokers: 1,
            categories: 3,
            typesInUse: 4,
            items: 10,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Suppliers 2'), findsOneWidget);
    expect(find.text('Items 10'), findsOneWidget);
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
