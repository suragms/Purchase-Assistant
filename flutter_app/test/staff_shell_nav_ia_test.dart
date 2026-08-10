import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/features/staff/staff_shell_branch_provider.dart';
import 'package:harisree_warehouse/features/staff/staff_shell_nav.dart';

void main() {
  test('phone primary nav is Home Stock Scan Deliveries', () {
    expect(
      staffShellBottomPrimaryBranches,
      [
        StaffShellBranch.home,
        StaffShellBranch.stock,
        StaffShellBranch.scan,
        StaffShellBranch.deliveries,
      ],
    );
    expect(staffShellNavLabel(StaffShellBranch.deliveries), 'Deliveries');
    expect(staffShellBottomPrimaryBranches, isNot(contains(StaffShellBranch.search)));
    expect(staffShellBottomPrimaryBranches, isNot(contains(StaffShellBranch.tasks)));
  });

  test('Search and Tasks live under More', () {
    expect(staffShellBranchIsInMoreMenu(StaffShellBranch.search), isTrue);
    expect(staffShellBranchIsInMoreMenu(StaffShellBranch.tasks), isTrue);
    expect(staffShellBranchIsInMoreMenu(StaffShellBranch.home), isFalse);
    expect(staffShellMoreMenuBranches.length, 2);
  });

  testWidgets('More sheet lists Search and Tasks', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    showStaffShellMoreNavSheet(
                      context: context,
                      currentBranch: StaffShellBranch.home,
                      onBranchSelected: (b) => picked = b,
                    );
                  },
                  child: const Text('Open more'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open more'));
    await tester.pumpAndSettle();

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Deliveries'), findsNothing);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(picked, StaffShellBranch.search);
  });
}
