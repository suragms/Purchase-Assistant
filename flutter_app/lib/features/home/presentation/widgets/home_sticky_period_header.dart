import 'package:flutter/material.dart';

import '../../../../core/theme/hexa_colors.dart';
import 'home_period_filter_row.dart';

/// Sticky period chips for owner dashboard scroll.
class HomeStickyPeriodHeader extends SliverPersistentHeaderDelegate {
  HomeStickyPeriodHeader();

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: HexaColors.brandBackground,
      elevation: overlapsContent ? 1 : 0,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: HomePeriodFilterRow(),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeStickyPeriodHeader oldDelegate) => false;
}
