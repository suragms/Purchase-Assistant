import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/hexa_api.dart';
import '../../../../core/auth/session_notifier.dart';
import '../../../../core/json_coerce.dart';
import '../../../../core/providers/home_dashboard_provider.dart';
import '../../../../core/providers/stock_providers.dart';
import '../../../../core/widgets/hexa_error_card.dart';

/// **Movement** tab on [StockPage]: audit events for the stock period.
class StockMovementTab extends ConsumerStatefulWidget {
  const StockMovementTab({super.key});

  @override
  ConsumerState<StockMovementTab> createState() => _StockMovementTabState();
}

class _StockMovementTabState extends ConsumerState<StockMovementTab> {
  bool _loading = true;
  Object? _loadError;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final session = ref.read(sessionProvider);
    if (session == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final rows = await ref.read(hexaApiProvider).listStockAuditRecent(
            businessId: session.primaryBusiness.id,
            limit: HexaApi.stockAuditRecentMaxLimit,
          );
      if (!mounted) return;
      final range = homePeriodRange(ref.read(stockPagePeriodProvider));
      final endInclusive = range.end.subtract(const Duration(days: 1));
      final from = DateTime(range.start.year, range.start.month, range.start.day);
      final to = DateTime(
        endInclusive.year,
        endInclusive.month,
        endInclusive.day,
        23,
        59,
        59,
      );
      final filtered = <Map<String, dynamic>>[];
      for (final raw in rows) {
        final at = DateTime.tryParse(
              raw['created_at']?.toString() ??
                  raw['audited_at']?.toString() ??
                  '',
            ) ??
            DateTime.tryParse(raw['on']?.toString() ?? '');
        if (at == null) continue;
        if (at.isBefore(from) || at.isAfter(to)) continue;
        filtered.add(Map<String, dynamic>.from(raw));
      }
      filtered.sort((a, b) {
        final ta = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final tb = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return tb.compareTo(ta);
      });
      setState(() {
        _rows = filtered;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(stockPagePeriodProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _load();
      });
    });
    final period = ref.watch(stockPagePeriodProvider);
    final df = DateFormat('d MMM, HH:mm');

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return HexaErrorCard.fromError(
        error: _loadError!,
        title: 'Could not load stock movement',
        onRetry: _load,
      );
    }
    if (_rows.isEmpty) {
      return Center(
        child: Text(
          'No stock events for ${period.label.toLowerCase()}',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: _rows.length,
        itemBuilder: (context, i) {
          final r = _rows[i];
          final d = coerceToDouble(r['qty_delta'] ?? r['delta']);
          final name = r['item_name']?.toString() ?? 'Item';
          final unit = r['unit']?.toString() ?? '';
          final at = DateTime.tryParse(r['created_at']?.toString() ?? '') ??
              DateTime.now();
          return ListTile(
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(df.format(at)),
            trailing: Text(
              '${d >= 0 ? '+' : ''}${d.round()} $unit'.trim(),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: d >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
          );
        },
      ),
    );
  }
}
