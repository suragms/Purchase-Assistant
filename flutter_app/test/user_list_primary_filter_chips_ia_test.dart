import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/settings/users/user_list_filters.dart';

void main() {
  testWidgets('user list primary filters use Wrap not horizontal scroll',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final rows = <Map<String, dynamic>>[
      {'name': 'A', 'is_active': true, 'is_blocked': false, 'role': 'staff'},
      {'name': 'B', 'is_active': false, 'is_blocked': false, 'role': 'manager'},
      {'name': 'C', 'is_active': true, 'is_blocked': true, 'role': 'staff'},
    ];

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: UserListPrimaryFilterBar(rows: rows),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('All users'), findsOneWidget);
    expect(find.textContaining('Blocked'), findsOneWidget);
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
