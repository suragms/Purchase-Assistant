import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/errors/user_facing_errors.dart';
import '../../../core/json_coerce.dart';

class SalesComparisonPage extends ConsumerStatefulWidget {
  const SalesComparisonPage({super.key});

  @override
  ConsumerState<SalesComparisonPage> createState() =>
      _SalesComparisonPageState();
}

class _SalesComparisonPageState extends ConsumerState<SalesComparisonPage> {
  final _inputCtrl = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _parseLines() {
    return _inputCtrl.text
        .split('\n')
        .map((raw) => raw.trim())
        .where((raw) => raw.isNotEmpty)
        .map((raw) {
      final parts = raw.split(RegExp(r'[,|\t]')).map((e) => e.trim()).toList();
      return {
        'name': parts.first,
        if (parts.length > 1) 'qty': double.tryParse(parts[1]),
        if (parts.length > 2) 'amount': double.tryParse(parts[2]),
      };
    }).toList();
  }

  Future<void> _compare() async {
    final session = ref.read(sessionProvider);
    if (session == null || _busy) return;
    final lines = _parseLines();
    if (lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste at least one sales line.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref.read(hexaApiProvider).compareSalesLines(
            businessId: session.primaryBusiness.id,
            lines: lines,
          );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingError(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyCsv() async {
    final rows = [
      for (final e in (_result?['rows'] as List? ?? []))
        if (e is Map) Map<String, dynamic>.from(e),
    ];
    if (rows.isEmpty) return;
    final csv = StringBuffer('source,match,status,score,qty,amount\n');
    for (final r in rows) {
      csv.writeln(
        [
          r['source_name'] ?? '',
          r['catalog_name'] ?? '',
          r['match_status'] ?? '',
          r['match_score'] ?? '',
          r['qty'] ?? '',
          r['amount'] ?? '',
        ].map((v) => '"${v.toString().replaceAll('"', '""')}"').join(','),
      );
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copied.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final e in (_result?['rows'] as List? ?? []))
        if (e is Map) Map<String, dynamic>.from(e),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales comparison'),
        actions: [
          IconButton(
            tooltip: 'Copy CSV',
            onPressed: rows.isEmpty ? null : _copyCsv,
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Paste sales rows as: item name, qty, amount. The app matches names to catalog items for review.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _inputCtrl,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Sugar 50kg, 2, 4800\nRice bag, 1, 2200',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _compare,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.compare_arrows_rounded),
            label: const Text('Compare with catalog'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Text(
              'Matched ${coerceToInt(_result?['matched'])} · Review ${coerceToInt(_result?['review'])} · Missing ${coerceToInt(_result?['missing'])}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final r in rows)
              Card(
                child: ListTile(
                  title: Text(r['source_name']?.toString() ?? ''),
                  subtitle: Text(
                    '${r['catalog_name'] ?? 'No catalog match'} · score ${r['match_score']}',
                  ),
                  trailing: Text(
                    r['match_status']?.toString().toUpperCase() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
