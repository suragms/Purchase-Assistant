import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/theme/hexa_colors.dart';
import '../services/barcode_pdf_service.dart';

class BarcodePrintPage extends ConsumerStatefulWidget {
  const BarcodePrintPage({super.key, required this.itemId});

  final String itemId;

  @override
  ConsumerState<BarcodePrintPage> createState() => _BarcodePrintPageState();
}

class _BarcodePrintPageState extends ConsumerState<BarcodePrintPage> {
  LabelSize _size = LabelSize.medium;
  int _copies = 1;
  bool _showLastPurchase = true;
  bool _busy = false;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = ref.read(sessionProvider);
    if (session == null) return;
    final bid = session.primaryBusiness.id;
    final api = ref.read(hexaApiProvider);
    try {
      final j = await api.getBarcodeLabel(businessId: bid, itemId: widget.itemId);
      if (mounted) setState(() => _data = j);
    } catch (_) {}
  }

  BarcodeLabelData? get _label {
    final d = _data;
    if (d == null) return null;
    DateTime? lpDate;
    final lpRaw = d['last_purchase_date'];
    if (lpRaw is String && lpRaw.isNotEmpty) {
      lpDate = DateTime.tryParse(lpRaw);
    }
    return BarcodeLabelData(
      itemCode: d['item_code']?.toString() ?? '',
      itemName: d['item_name']?.toString() ?? '',
      unit: d['unit']?.toString(),
      currentStock: (d['current_stock'] as num?)?.toDouble(),
      lastPurchaseDate: lpDate,
      lastPurchaseQty: (d['last_purchase_qty'] as num?)?.toDouble(),
      lastPurchaseUnit: d['last_purchase_unit']?.toString(),
      lastPurchaseRate: (d['last_purchase_rate'] as num?)?.toDouble(),
    );
  }

  Future<void> _print() async {
    final label = _label;
    if (label == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await BarcodePdfService.generateSingleLabel(
        data: label,
        size: _size,
        copies: _copies,
        showLastPurchase: _showLastPurchase,
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _label;
    return Scaffold(
      appBar: AppBar(
        title: Text(label != null ? 'Print · ${label.itemCode}' : 'Print label'),
      ),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (label != null) ...[
                  Text(label.itemName, style: HexaDsType.heading(18)),
                  const SizedBox(height: 12),
                  SegmentedButton<LabelSize>(
                    segments: const [
                      ButtonSegment(value: LabelSize.small, label: Text('Small')),
                      ButtonSegment(value: LabelSize.medium, label: Text('Medium')),
                      ButtonSegment(value: LabelSize.large, label: Text('Large')),
                    ],
                    selected: {_size},
                    onSelectionChanged: (s) => setState(() => _size = s.first),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Copies'),
                      const Spacer(),
                      IconButton(
                        onPressed: _copies > 1 ? () => setState(() => _copies--) : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$_copies'),
                      IconButton(
                        onPressed: _copies < 100 ? () => setState(() => _copies++) : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (_size != LabelSize.small)
                    SwitchListTile(
                      title: const Text('Show last purchase on label'),
                      value: _showLastPurchase,
                      onChanged: (v) => setState(() => _showLastPurchase = v),
                    ),
                  if (label.lastPurchaseDate != null && _showLastPurchase)
                    Text(
                      'Last: ${DateFormat('dd MMM yy').format(label.lastPurchaseDate!)}',
                      style: HexaDsType.body(13),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _print,
                    style: FilledButton.styleFrom(
                      backgroundColor: HexaColors.brandPrimary,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Print now'),
                  ),
                ],
              ],
            ),
    );
  }
}
