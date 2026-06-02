import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/design_system/hexa_ds_tokens.dart';
import '../../../core/json_coerce.dart';
import '../../../core/theme/hexa_colors.dart';
import '../../../core/utils/unit_utils.dart';
import '../../../core/widgets/friendly_load_error.dart';
import '../../../core/widgets/list_skeleton.dart';
import 'widgets/scan_item_stock_summary_card.dart';

/// Read-only stock view for QR label scans (no login required).
class PublicItemScanPage extends StatefulWidget {
  const PublicItemScanPage({super.key, required this.lookupKey});

  /// Public token, item code, or barcode from label URL `/item/:lookupKey`.
  final String lookupKey;

  @override
  State<PublicItemScanPage> createState() => _PublicItemScanPageState();
}

class _PublicItemScanPageState extends State<PublicItemScanPage> {
  late final Future<Map<String, dynamic>> _load;

  @override
  void initState() {
    super.initState();
    _load = _fetch();
  }

  Future<Map<String, dynamic>> _fetch() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.resolvedApiBaseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );
    final res = await dio.get<Map<String, dynamic>>(
      '/public/items/${Uri.encodeComponent(widget.lookupKey)}.json',
    );
    return Map<String, dynamic>.from(res.data ?? const {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexaColors.brandBackground,
      appBar: AppBar(
        title: const Text('Item stock'),
        backgroundColor: Colors.transparent,
        foregroundColor: HexaColors.brandPrimary,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _load,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: ListSkeleton(rowCount: 4, rowHeight: 72),
            );
          }
          if (snap.hasError) {
            return FriendlyLoadError(
              message: _publicLoadMessage(snap.error),
              onRetry: () => setState(() => _load = _fetch()),
            );
          }
          final data = snap.data ?? const {};
          final name = data['name']?.toString() ?? 'Item';
          final category = data['category']?.toString() ?? 'Catalog item';
          final code = data['item_code']?.toString() ?? '—';
          final rack = data['rack_location']?.toString() ?? '—';
          final status = (data['status']?.toString() ?? 'healthy')
              .replaceAll('_', ' ')
              .toUpperCase();
          final system = coerceToDouble(data['current_stock']);
          final unit = data['stock_unit']?.toString() ?? '';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                category,
                style: HexaDsType.body(14, color: HexaDsColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: HexaDsType.heading(22),
              ),
              const SizedBox(height: 16),
              Text(
                'Current stock',
                style: HexaDsType.label(12, color: HexaDsColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatStockQtyNumber(system)}${unit.isNotEmpty ? ' ${unit.toUpperCase()}' : ''}',
                style: HexaDsType.heading(32, color: HexaColors.brandPrimary),
              ),
              const SizedBox(height: 16),
              ScanItemStockSummaryCard(item: data, showTitle: false),
              const SizedBox(height: 12),
              Text('Item code: $code', style: HexaDsType.bodySm(context)),
              Text('Rack: $rack', style: HexaDsType.bodySm(context)),
              const SizedBox(height: 8),
              Text(
                'Status: $status',
                style: HexaDsType.label(12, color: HexaDsColors.textMuted),
              ),
              const SizedBox(height: 16),
              Text(
                'Read-only · open the Harisree app to update physical or system stock.',
                textAlign: TextAlign.center,
                style: HexaDsType.body(12, color: HexaDsColors.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _publicLoadMessage(Object? error) {
    if (error is DioException) {
      final sc = error.response?.statusCode;
      if (sc == 404) return 'Item not found or link expired.';
      if (sc == 401 || sc == 403) {
        return 'This link is read-only. Try scanning the QR on the label again.';
      }
      if (sc != null && sc >= 500) {
        return 'Server is waking up. Pull to refresh in a moment.';
      }
    }
    return 'Could not load item. Check your connection and try again.';
  }
}
