import 'package:flutter/material.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';

/// Aligns with [StockQtyMetricTriple] columns on stock rows.
class StockListColumnHeader extends StatelessWidget {
  const StockListColumnHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(HexaOp.pageGutter, 2, 56, 4),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Item',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              'Buy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.black38,
              ),
            ),
          ),
          SizedBox(width: 2),
          SizedBox(
            width: 40,
            child: Text(
              'Now',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.black38,
              ),
            ),
          ),
          SizedBox(width: 2),
          SizedBox(
            width: 40,
            child: Text(
              'Δ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
