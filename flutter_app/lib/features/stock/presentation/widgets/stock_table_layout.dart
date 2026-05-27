import 'package:flutter/material.dart';

/// Shared column geometry for warehouse stock table.
abstract final class StockTableLayout {
  static const double metricColWidth = 50;
  static const double stockColWidth = 72;
  static const double desktopMetricColWidth = 86;
  static const double statusColWidth = 56;
  static const double rowMinHeight = 72;
  static const double cellHPadding = 6;
  static const double metricWidth = 44;
  static const double metricGap = 4;
  static const double actionsWidth = 84;
  static const Color borderColor = Color(0xFFD8D5D0);
  static const Color headerFill = Color(0xFFE8E6E1);
  static const Color rowFill = Colors.white;

  static const BorderSide cellBorder = BorderSide(color: borderColor, width: 1);

  static BoxDecoration rowDecoration({bool isFirst = false}) {
    return BoxDecoration(
      color: rowFill,
      border: Border(
        left: cellBorder,
        right: cellBorder,
        top: isFirst ? cellBorder : BorderSide.none,
        bottom: cellBorder,
      ),
    );
  }

  static BoxDecoration cellDecoration() {
    return const BoxDecoration(
      border: Border(
        right: cellBorder,
      ),
    );
  }
}
