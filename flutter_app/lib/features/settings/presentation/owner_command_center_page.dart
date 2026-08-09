import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_notifier.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../../core/errors/load_state_error.dart';
import '../../../core/widgets/friendly_load_error.dart';

/// Owner command center — exception-first aggregate.
class OwnerCommandCenterPage extends ConsumerStatefulWidget {
  const OwnerCommandCenterPage({super.key});

  @override
  ConsumerState<OwnerCommandCenterPage> createState() =>
      _OwnerCommandCenterPageState();
}

class _OwnerCommandCenterPageState extends ConsumerState<OwnerCommandCenterPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  List<dynamic> _waItems = [];

  final _money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load();
      await _loadWa();
    });
  }

  Future<void> _load() async {
    final bid = ref.read(sessionProvider)?.primaryBusiness.id;
    if (bid == null || bid.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'No business selected';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data =
          await ref.read(hexaApiProvider).fetchOwnerDashboard(businessId: bid);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = loadStateErrorSubtitle(e);
      });
    }
  }

  Future<void> _loadWa() async {
    final bid = ref.read(sessionProvider)?.primaryBusiness.id;
    if (bid == null || bid.isEmpty) return;
    try {
      final data =
          await ref.read(hexaApiProvider).listWhatsappDeliveries(businessId: bid);
      if (!mounted) return;
      setState(() => _waItems = (data['items'] as List?) ?? []);
    } catch (_) {
      // Soft-fail — dashboard still useful without WA log.
    }
  }

  Future<void> _resendWa(String poId) async {
    final bid = ref.read(sessionProvider)?.primaryBusiness.id;
    if (bid == null || poId.isEmpty) return;
    try {
      await ref.read(hexaApiProvider).resendWhatsappDelivery(
            businessId: bid,
            poId: poId,
          );
      await _loadWa();
      await _load();
    } catch (e) {
      if (!mounted) return;
      // Error surfaces via refresh; keep UI calm.
    }
  }

  @override
  Widget build(BuildContext context) {
    final spend = (_data?['comparison'] as Map?)?['spend_last_7_days'];
    final stock = _data?['stock'] as Map? ?? {};
    final backup = _data?['backup'] as Map? ?? {};
    final exceptions = (_data?['exceptions'] as List?) ?? [];
    final staff = (_data?['staff_performance'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner command center'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const LinearProgressIndicator(minHeight: 2)
          : _error != null
              ? FriendlyLoadError(message: _error!, onRetry: _load)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Needs attention',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (exceptions.isEmpty)
                      const Text(
                        'No exceptions right now.',
                        style: TextStyle(color: HexaColors.neutral),
                      )
                    else
                      for (final e in exceptions)
                        if (e is Map)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.warning_amber_rounded,
                              color: HexaColors.warning,
                            ),
                            title: Text(e['message']?.toString() ?? '—'),
                          ),
                    const Divider(height: 32),
                    Text(
                      'Stock · low ${stock['low_count'] ?? 0} · out ${stock['out_count'] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Spend (7d): ${_money.format((spend is num) ? spend : 0)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Backup: ${backup['last_status'] ?? 'none'}'
                      '${backup['last_at'] != null ? ' · ${backup['last_at']}' : ''}',
                      style: const TextStyle(color: HexaColors.neutral),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Damage pending: ${(_data?['damage'] as Map?)?['pending_count'] ?? 0}'
                      ' · AI today: ${(_data?['ai_usage'] as Map?)?['requests_today'] ?? 0}'
                      ' · WhatsApp queue: ${(_data?['whatsapp'] as Map?)?['needs_attention'] ?? 0}',
                      style: const TextStyle(color: HexaColors.neutral),
                    ),
                    const Divider(height: 32),
                    const Text(
                      'WhatsApp PO deliveries',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadWa,
                      child: const Text('Refresh delivery log'),
                    ),
                    if (_waItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No delivery attempts yet.',
                          style: TextStyle(color: HexaColors.neutral),
                        ),
                      )
                    else
                      for (final w in _waItems.take(12))
                        if (w is Map)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${w['status']} · PO ${w['po_id']}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(w['error_message']?.toString() ?? ''),
                            trailing: (w['status'] == 'failed' ||
                                    w['status'] == 'pending_manual')
                                ? TextButton(
                                    onPressed: () => _resendWa('${w['po_id']}'),
                                    child: const Text('Resend'),
                                  )
                                : null,
                          ),
                    const Divider(height: 32),
                    const Text(
                      'Staff tasks',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (staff.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No staff tasks yet.',
                          style: TextStyle(color: HexaColors.neutral),
                        ),
                      )
                    else
                      for (final s in staff)
                        if (s is Map)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Staff ${s['staff_id']}'),
                            subtitle: Text(
                              'done ${s['completed']} · pending ${s['pending']} · '
                              'rejected ${s['rejected']}',
                            ),
                          ),
                  ],
                ),
    );
  }
}
