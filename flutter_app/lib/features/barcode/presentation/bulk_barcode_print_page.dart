import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/providers/catalog_providers.dart';
import '../../../core/theme/hexa_colors.dart';
import '../services/barcode_pdf_service.dart';

class BulkBarcodePrintPage extends ConsumerStatefulWidget {
  const BulkBarcodePrintPage({super.key});

  @override
  ConsumerState<BulkBarcodePrintPage> createState() => _BulkBarcodePrintPageState();
}

class _BulkBarcodePrintPageState extends ConsumerState<BulkBarcodePrintPage> {
  final _selected = <String>{};
  LabelSize _size = LabelSize.medium;
  int _copies = 1;
  bool _busy = false;

  Future<void> _print() async {
    if (_selected.isEmpty) return;
    final session = ref.read(sessionProvider);
    if (session == null) return;
    setState(() => _busy = true);
    try {
      final api = ref.read(hexaApiProvider);
      final labels = await api.barcodeLabelBatch(
        businessId: session.primaryBusiness.id,
        itemIds: _selected.toList(),
      );
      final batch = <BarcodeLabelData>[];
      for (final j in labels) {
        final code = j['item_code']?.toString() ?? j['item_name']?.toString() ?? '';
        if (code.isEmpty) continue;
        batch.add(
          BarcodeLabelData(
            itemCode: code,
            itemName: j['item_name']?.toString() ?? code,
            unit: j['unit']?.toString(),
            currentStock: (j['current_stock'] as num?)?.toDouble(),
          ),
        );
      }
      if (batch.isEmpty) return;
      final pdf = await BarcodePdfService.generateBatch(
        items: batch,
        size: _size,
        copiesPerItem: _copies,
      );
      await Printing.layoutPdf(onLayout: (_) async => pdf);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(catalogItemsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bulk barcode print')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text('${_selected.length} selected'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() {
                        _selected
                          ..clear()
                          ..addAll(
                            items
                                .map((e) => e['id']?.toString())
                                .whereType<String>(),
                          );
                      }),
                      child: const Text('Select all'),
                    ),
                    TextButton(
                      onPressed: () => setState(_selected.clear),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final it = items[i];
                    final id = it['id']?.toString() ?? '';
                    final name = it['name']?.toString() ?? '';
                    final code = it['item_code']?.toString() ?? '';
                    return CheckboxListTile(
                      value: _selected.contains(id),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selected.add(id);
                        } else {
                          _selected.remove(id);
                        }
                      }),
                      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(code),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FilledButton(
                    onPressed: _busy || _selected.isEmpty ? null : _print,
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
                        : Text('Print ${_selected.length * _copies} labels'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
