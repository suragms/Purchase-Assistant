import 'package:flutter/material.dart';

import '../../../../core/design_system/hexa_ds_tokens.dart';
import '../../../../core/design_system/hexa_operational_tokens.dart';
import 'stock_table_layout.dart';

/// Warehouse table header: ITEM | STOCK | STATUS.
class StockListColumnHeader extends StatelessWidget {
  const StockListColumnHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1024;
    final hdr = HexaDsType.label(10).copyWith(
      fontWeight: FontWeight.w800,
      color: const Color(0xFF475569),
      letterSpacing: 0.3,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HexaOp.pageGutter),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: StockTableLayout.headerFill,
          border: Border.all(color: StockTableLayout.borderColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StockTableLayout.cellHPadding,
                    vertical: 6,
                  ),
                  child: Text('ITEM', style: hdr),
                ),
              ),
              Container(
                width: StockTableLayout.stockColWidth,
                decoration: StockTableLayout.cellDecoration(),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('STOCK', style: hdr),
              ),
              if (desktop) ...[
                _metricHeader('PHYSICAL', hdr),
                _metricHeader('PURCHASED', hdr),
                _metricHeader('DIFF', hdr),
              ],
              SizedBox(
                width: StockTableLayout.statusColWidth,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('STATUS', style: hdr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricHeader(String label, TextStyle style) {
    return Container(
      width: StockTableLayout.desktopMetricColWidth,
      decoration: StockTableLayout.cellDecoration(),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(label, style: style, textAlign: TextAlign.center),
    );
  }
}
