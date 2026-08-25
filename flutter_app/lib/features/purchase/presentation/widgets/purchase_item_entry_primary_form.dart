import 'package:flutter/material.dart';

/// Primary (always-visible) item entry field block for embedded/desktop editor.
///
/// Host: [PurchaseItemEntrySheet] when `embedded: true`. Keeps the common
/// warehouse path compact: search → qty/unit → rates → tax → line total.
/// Advanced fields stay in the sheet's collapsible section.
class PurchaseItemEntryPrimaryForm extends StatelessWidget {
  const PurchaseItemEntryPrimaryForm({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
