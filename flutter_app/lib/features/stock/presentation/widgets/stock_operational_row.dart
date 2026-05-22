import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/hexa_operational_tokens.dart';
import '../../../../core/json_coerce.dart';
import '../../../../core/utils/operational_date_format.dart';
import '../../../../core/utils/unit_utils.dart';
import '../stock_quick_edit_sheet.dart';
import 'edit_item_code_sheet.dart';

/// Dense 72dp warehouse stock row.
class StockOperationalRow extends ConsumerWidget {
  const StockOperationalRow({
    super.key,
    required this.item,
    required this.includePeriod,
    required this.onTap,
    this.canEdit = true,
  });

  final Map<String, dynamic> item;
  final bool includePeriod;
  final VoidCallback onTap;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = item['name']?.toString() ?? '—';
    final codeRaw = item['item_code']?.toString().trim() ?? '';
    final missingCode = item['missing_item_code'] == true || codeRaw.isEmpty;
    final unit = item['unit']?.toString() ?? '';
    final cat = item['category_name']?.toString() ?? '';
    final sub = item['subcategory_name']?.toString() ?? '';
    final cur = coerceToDouble(item['current_stock']);
    final kgPerBag = coerceToDoubleNullable(item['default_kg_per_bag']) ??
        coerceToDoubleNullable(item['kg_per_bag']);

    final purchased = includePeriod
        ? coerceToDouble(item['period_purchased_qty'])
        : coerceToDouble(item['purchased_today_qty']);

    final stockPrimary = stockDisplayPrimary(cur, unit);
    final stockSecondary = stockDisplaySecondary(cur, unit, kgPerBag, null);
    final purchasedLabel = purchased > 0
        ? '+${stockDisplayPrimary(purchased, unit)}'
        : '';

    final status = (item['stock_status']?.toString() ?? 'healthy').toLowerCase();
    final badge = _statusBadge(status);
    final updateLine = formatStockRowUpdateLine(
      updatedBy: item['last_stock_updated_by']?.toString(),
      updatedAtIso: item['last_stock_updated_at']?.toString(),
    );

    final catLine = [cat, sub].where((s) => s.isNotEmpty).join(' · ');
    final itemId = item['id']?.toString() ?? '';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: HexaOp.listRowMax),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HexaOp.pageGutter,
              vertical: 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: missingCode
                                ? () => showEditItemCodeSheet(
                                      context: context,
                                      ref: ref,
                                      itemId: itemId,
                                      itemName: name,
                                      currentCode: codeRaw,
                                    )
                                : null,
                            child: Text(
                              missingCode ? 'Missing item code' : codeRaw,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: missingCode
                                    ? const Color(0xFFA32D2D)
                                    : Colors.black54,
                                fontWeight: missingCode
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (catLine.isNotEmpty)
                            Text(
                              catLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                          if (unit.toLowerCase() == 'bag' &&
                              kgPerBag != null &&
                              kgPerBag > 0)
                            Text(
                              '${kgPerBag == kgPerBag.roundToDouble() ? kgPerBag.round() : kgPerBag}kg/bag',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black38,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (purchasedLabel.isNotEmpty)
                            Text(
                              purchasedLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3B6D11),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          Text(
                            stockPrimary,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (stockSecondary != null)
                            Text(
                              stockSecondary
                                  .replaceAll('(', '')
                                  .replaceAll(')', ''),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        badge,
                        if (canEdit)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            onPressed: () => showStockQuickEditSheet(
                              context: context,
                              ref: ref,
                              item: item,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (updateLine.isNotEmpty)
                  Text(
                    updateLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    String label;
    Color bg;
    Color fg;
    switch (status) {
      case 'low':
        label = 'LOW';
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFBA7517);
        break;
      case 'critical':
        label = 'CRITICAL';
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFA32D2D);
        break;
      case 'out':
        label = 'OUT';
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFA32D2D);
        break;
      default:
        label = 'OK';
        bg = const Color(0xFFE8F5E0);
        fg = const Color(0xFF3B6D11);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
