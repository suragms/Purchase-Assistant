import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/errors/user_facing_errors.dart';
import '../../../core/json_coerce.dart';
import '../../../core/providers/business_aggregates_invalidation.dart';
import '../../../core/notifications/local_notifications_service.dart';
import '../../../core/providers/home_owner_dashboard_providers.dart';
import '../../../core/providers/staff_home_providers.dart';
import '../../../core/providers/stock_providers.dart';
import '../../../core/providers/notification_center_provider.dart';
import '../../../core/providers/server_notifications_provider.dart';
import '../../../core/utils/unit_utils.dart';
import '../../../core/design_system/hexa_responsive.dart';
import 'widgets/stock_update_mode_toggle.dart';

const _kReasonChips = <(String label, String type)>[
  ('Physical count', 'verification'),
  ('Sale', 'sale'),
  ('Damage', 'damaged'),
  ('Correction', 'correction'),
  ('Wastage', 'damaged'),
];

/// Quick physical stock update (patch / compact update).
Future<bool> showQuickStockActionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, dynamic> item,
  StockUpdateMode initialMode = StockUpdateMode.physical,
}) async {
  final result = await showHexaBottomSheet<bool>(
    context: context,
    compact: true,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: _QuickStockActionBody(
      item: item,
      parentRef: ref,
      initialMode: initialMode,
    ),
  );
  return result == true;
}

class _QuickStockActionBody extends ConsumerStatefulWidget {
  const _QuickStockActionBody({
    required this.item,
    required this.parentRef,
    this.initialMode = StockUpdateMode.physical,
  });

  final Map<String, dynamic> item;
  final WidgetRef parentRef;
  final StockUpdateMode initialMode;

  @override
  ConsumerState<_QuickStockActionBody> createState() =>
      _QuickStockActionBodyState();
}

class _QuickStockActionBodyState extends ConsumerState<_QuickStockActionBody> {
  bool _saving = false;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _notesCtrl;
  late double _current;
  String? _reasonType = 'verification';
  String _reasonLabel = 'Physical count';
  late StockUpdateMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _current = _seedQtyForMode(_mode);
    _qtyCtrl = TextEditingController(
      text: formatStockQtyForUnit(_unit, _current),
    );
    _notesCtrl = TextEditingController();
  }

  double _seedQtyForMode(StockUpdateMode mode) {
    if (mode == StockUpdateMode.physical) {
      final phys = coerceToDoubleNullable(widget.item['physical_stock_qty']);
      if (phys != null && phys.isFinite && phys >= 0) return phys;
    }
    final sys = coerceToDouble(widget.item['current_stock']);
    return sys.isFinite ? sys : 0;
  }

  void _onModeChanged(StockUpdateMode mode) {
    setState(() {
      _mode = mode;
      _current = _seedQtyForMode(mode);
      _qtyCtrl.text = formatStockQtyForUnit(_unit, _current);
      if (mode == StockUpdateMode.physical) {
        _reasonType = 'verification';
        _reasonLabel = 'Physical count';
      } else {
        _reasonType = 'correction';
        _reasonLabel = 'Correction';
      }
    });
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String get _itemId => widget.item['id']?.toString() ?? '';

  String get _name => widget.item['name']?.toString() ?? 'Item';

  String get _unit =>
      widget.item['stock_unit']?.toString() ??
      widget.item['unit']?.toString() ??
      'piece';

  String get _unitLabel => _unit.isNotEmpty ? _unit.toUpperCase() : '';

  String? get _lastPhysicalLabel {
    if (widget.item['physical_stock_qty'] == null) return null;
    final qty = coerceToDouble(widget.item['physical_stock_qty']);
    if (!qty.isFinite) return null;
    final diff = coerceToDouble(widget.item['physical_stock_difference_qty']);
    final sign = diff >= 0 ? '+' : '';
    return 'Last physical: ${formatStockQtyForUnit(_unit, qty)} $_unitLabel'
        '${diff.abs() > 0.001 ? ' ($sign${formatStockQtyForUnit(_unit, diff)} diff)' : ''}';
  }

  Future<void> _save() async {
    if (_mode == StockUpdateMode.system && _reasonType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a reason')),
      );
      return;
    }
    final parsed = double.tryParse(_qtyCtrl.text.trim().replaceAll(',', ''));
    if (parsed == null || !parsed.isFinite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity')),
      );
      return;
    }
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final session = ref.read(sessionProvider);
      if (session == null) return;
      final note = _notesCtrl.text.trim();
      final reasonLabel = _reasonLabel;
      if (_mode == StockUpdateMode.system) {
        await ref.read(hexaApiProvider).patchStockItem(
              businessId: session.primaryBusiness.id,
              itemId: _itemId,
              newQty: parsed,
              adjustmentType: _reasonType ?? 'correction',
              reason: note.isNotEmpty ? '$reasonLabel — $note' : reasonLabel,
            );
        ref.invalidate(appNotificationsListProvider);
        ref.invalidate(notificationCenterCoordinatorProvider);
      } else {
        final listQ = ref.read(stockListQueryProvider);
        await ref.read(hexaApiProvider).recordPhysicalStockCount(
              businessId: session.primaryBusiness.id,
              itemId: _itemId,
              countedQty: parsed,
              notes: note.isNotEmpty ? '$reasonLabel — $note' : reasonLabel,
              periodStart: listQ.periodStart,
              periodEnd: listQ.periodEnd,
            );
      }
      invalidateWarehouseSurfaces(ref, itemId: _itemId);
      ref.invalidate(stockAuditPeriodProvider);
      ref.invalidate(stockChangesFeedProvider);
      ref.invalidate(staffTodayActivityProvider);
      ref.invalidate(staffTodaySummaryProvider);
      final reorder = coerceToDouble(widget.item['reorder_level']);
      if (reorder > 0 && parsed <= reorder) {
        final unitLabel = _unit.isNotEmpty ? _unit.toUpperCase() : '';
        await LocalNotificationsService.instance.showLowStockItem(
          itemName: _name,
          detail:
              '${formatStockQtyForUnit(_unit, parsed)} $unitLabel (reorder ${formatStockQtyForUnit(_unit, reorder)})',
        );
      }
      if (context.mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = !_saving &&
        (_mode == StockUpdateMode.physical || _reasonType != null);
    final stockLabel = stockDisplayPrimary(_current, _unit);
    final lastPhysical = _lastPhysicalLabel;
    final systemQty = coerceToDouble(widget.item['current_stock']);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              children: [
                TextSpan(
                  text: _mode == StockUpdateMode.physical
                      ? 'Editing: '
                      : 'System now: ',
                ),
                TextSpan(
                  text: stockLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _mode == StockUpdateMode.physical
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF2563EB),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (_mode == StockUpdateMode.physical) ...[
            const SizedBox(height: 3),
            Text(
              'System ledger: ${formatStockQtyForUnit(_unit, systemQty)} $_unitLabel (unchanged until owner syncs)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
          if (lastPhysical != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                lastPhysical,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D6B5E),
                ),
              ),
            ),
          if (widget.item['last_stock_updated_by'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last system edit: ${widget.item['last_stock_updated_by']}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ],
          const SizedBox(height: 10),
          StockUpdateModeToggle(
            mode: _mode,
            onChanged: _onModeChanged,
          ),
          const SizedBox(height: 4),
          Text(
            stockUpdateModeHint(_mode),
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const Divider(height: 20),
          Text(
            _mode == StockUpdateMode.system ? 'System stock' : 'Physical stock',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          if (_mode == StockUpdateMode.system) ...[
            const SizedBox(height: 14),
            const Text(
              'Reason',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final chip in _kReasonChips)
                  HexaAccessibleFilterChip(
                    label: chip.$1,
                    selected: _reasonLabel == chip.$1,
                    onSelected: (_) => setState(() {
                      _reasonType = chip.$2;
                      _reasonLabel = chip.$1;
                    }),
                    compact: true,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Notes (optional)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: canSave ? _save : null,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _mode == StockUpdateMode.system
                          ? 'SAVE SYSTEM STOCK'
                          : 'SAVE PHYSICAL COUNT',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ),
        ],
      );
  }
}
