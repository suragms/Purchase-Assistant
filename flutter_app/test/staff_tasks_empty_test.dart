import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/staff/presentation/staff_tasks_page.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('owner empty staff tasks shows HexaEmptyState + Assign task',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var assigned = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffTasksEmpty(
            canAssign: true,
            onAssign: () => assigned = true,
            onRefresh: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No tasks assigned'), findsOneWidget);
    expect(find.text('Assign task'), findsOneWidget);
    expect(find.text('No tasks assigned.'), findsNothing);

    await tester.tap(find.text('Assign task'));
    await tester.pump();
    expect(assigned, isTrue);
  });

  testWidgets('staff empty staff tasks shows HexaEmptyState + Refresh',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var refreshed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffTasksEmpty(
            canAssign: false,
            onAssign: () {},
            onRefresh: () => refreshed = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('Assign task'), findsNothing);

    await tester.tap(find.text('Refresh'));
    await tester.pump();
    expect(refreshed, isTrue);
  });
}
