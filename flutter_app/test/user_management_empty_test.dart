import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/providers/business_users_provider.dart';
import 'package:harisree_warehouse/features/settings/presentation/user_management_page.dart';
import 'package:harisree_warehouse/features/settings/users/user_list_filters.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

void main() {
  testWidgets('empty user list shows HexaEmptyState + Refresh', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          businessUsersListProvider.overrideWith((ref) async => const []),
        ],
        child: const MaterialApp(home: UserManagementPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No users yet'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.text('No users match your filters.'), findsNothing);
  });

  testWidgets('filtered empty users shows Clear filters', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          businessUsersListProvider.overrideWith(
            (ref) async => [
              {
                'id': 'u1',
                'name': 'Anand',
                'email': 'a@example.com',
                'phone': '9999999999',
                'role': 'staff',
                'is_active': true,
                'is_blocked': false,
              },
            ],
          ),
          userListFilterProvider.overrideWith(
            (ref) => const UserListFilterState(search: 'zzzzznomatch'),
          ),
        ],
        child: const MaterialApp(home: UserManagementPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('No users match filters'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
    expect(find.text('No users match your filters.'), findsNothing);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('Anand'), findsOneWidget);
  });
}
