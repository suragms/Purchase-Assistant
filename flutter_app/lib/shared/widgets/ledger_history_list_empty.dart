import 'package:flutter/material.dart';

import 'hexa_empty_state.dart';

/// Empty list for flattened trade-line history (item / broker / supplier).
class LedgerHistoryListEmpty extends StatelessWidget {
  const LedgerHistoryListEmpty({
    super.key,
    required this.searchActive,
    this.onClearSearch,
  });

  final bool searchActive;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    if (searchActive) {
      return HexaEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No matching lines',
        subtitle: 'Try another search or clear the filter.',
        primaryActionLabel: onClearSearch != null ? 'Clear search' : null,
        onPrimaryAction: onClearSearch,
      );
    }
    return const HexaEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No purchase lines yet',
      subtitle: 'Matching trade purchases will list here.',
    );
  }
}
