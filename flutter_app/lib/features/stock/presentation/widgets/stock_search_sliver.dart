import 'package:flutter/material.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import 'stock_table_layout.dart';

/// Sticky collapsible search row for stock list.
class StockSearchSliverDelegate extends SliverPersistentHeaderDelegate {
  StockSearchSliverDelegate({
    required this.expanded,
    required this.searchController,
    required this.onClearSearch,
    required this.onOpenFilters,
    required this.filterCount,
  });

  final bool expanded;
  final TextEditingController searchController;
  final VoidCallback onClearSearch;
  final VoidCallback onOpenFilters;
  final int filterCount;

  static const double _collapsed = 0;
  static const double _expanded = 44;

  @override
  double get minExtent => expanded ? _expanded : _collapsed;

  @override
  double get maxExtent => expanded ? _expanded : _collapsed;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (!expanded) return const SizedBox.shrink();
    final hasSearch = searchController.text.trim().isNotEmpty;
    return ColoredBox(
      color: const Color(0xFFF5F3EE),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          HexaOp.pageGutter,
          2,
          HexaOp.pageGutter,
          4,
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search item…',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: hasSearch
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: onClearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: StockTableLayout.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: StockTableLayout.borderColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Badge(
                isLabelVisible: filterCount > 0,
                label: Text('$filterCount'),
                child: const Icon(Icons.tune_rounded, size: 20),
              ),
              tooltip: 'Filters',
              onPressed: onOpenFilters,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StockSearchSliverDelegate old) {
    return old.expanded != expanded ||
        old.filterCount != filterCount ||
        old.searchController != searchController;
  }
}
