import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system/hexa_responsive.dart';
import '../../core/theme/hexa_colors.dart';
import 'staff_shell_branch_provider.dart';

/// Phone primary tabs (Search + Tasks live under More). Desktop rail keeps all six.
const List<int> staffShellBottomPrimaryBranches = <int>[
  StaffShellBranch.home,
  StaffShellBranch.stock,
  StaffShellBranch.scan,
  StaffShellBranch.deliveries,
];

/// Branches opened from the phone More sheet.
const List<int> staffShellMoreMenuBranches = <int>[
  StaffShellBranch.search,
  StaffShellBranch.tasks,
];

bool staffShellBranchIsInMoreMenu(int branch) =>
    staffShellMoreMenuBranches.contains(branch);

String staffShellNavLabel(int branch) => switch (branch) {
      StaffShellBranch.home => 'Home',
      StaffShellBranch.stock => 'Stock',
      StaffShellBranch.scan => 'Scan',
      StaffShellBranch.search => 'Search',
      StaffShellBranch.deliveries => 'Deliveries',
      StaffShellBranch.tasks => 'Tasks',
      _ => 'Tab',
    };

IconData staffShellNavIcon(int branch, {required bool selected}) =>
    switch (branch) {
      StaffShellBranch.home =>
        selected ? Icons.home_rounded : Icons.home_outlined,
      StaffShellBranch.stock => selected
          ? Icons.inventory_2_rounded
          : Icons.inventory_2_outlined,
      StaffShellBranch.scan => selected
          ? Icons.qr_code_scanner_rounded
          : Icons.qr_code_scanner_outlined,
      StaffShellBranch.search => selected
          ? Icons.manage_search_rounded
          : Icons.search_rounded,
      StaffShellBranch.deliveries => selected
          ? Icons.local_shipping_rounded
          : Icons.local_shipping_outlined,
      StaffShellBranch.tasks => selected
          ? Icons.checklist_rounded
          : Icons.checklist_outlined,
      _ => Icons.circle_outlined,
    };

/// Compact sheet for secondary staff destinations (phone bottom nav).
Future<void> showStaffShellMoreNavSheet({
  required BuildContext context,
  required int currentBranch,
  required ValueChanged<int> onBranchSelected,
}) {
  return showHexaBottomSheet<void>(
    context: context,
    compact: true,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'More',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Secondary staff tools',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HexaColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            for (final branch in staffShellMoreMenuBranches)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  staffShellNavIcon(
                    branch,
                    selected: branch == currentBranch,
                  ),
                  color: branch == currentBranch
                      ? HexaColors.brandPrimary
                      : null,
                ),
                title: Text(
                  staffShellNavLabel(branch),
                  style: TextStyle(
                    fontWeight: branch == currentBranch
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
                trailing: branch == currentBranch
                    ? const Icon(Icons.check_rounded,
                        color: HexaColors.brandPrimary)
                    : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop();
                  onBranchSelected(branch);
                },
              ),
          ],
        ),
      ),
    ),
  );
}
