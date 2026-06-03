import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/business_profile.dart';
import '../models/trade_purchase_models.dart';
import '../providers/business_profile_provider.dart';
import '../router/navigation_ext.dart';
import 'pdf_actions.dart';
import 'purchase_pdf.dart';

/// India mobile: 10 digits; strips +91 when 12 digits present.
String? normalizeIndiaMobile10(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;
  var digits = t.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('91') && digits.length == 12) {
    digits = digits.substring(2);
  }
  if (digits.length != 10) return null;
  return digits;
}

String buildAccountsWhatsAppSummary(TradePurchase p, BusinessProfile biz) {
  final title = biz.displayTitle.trim().isNotEmpty
      ? biz.displayTitle.trim()
      : biz.legalName.trim();
  final supplier = (p.supplierName ?? '').trim().isNotEmpty
      ? p.supplierName!.trim()
      : '—';
  final dateStr = DateFormat('dd/MM/yyyy').format(p.purchaseDate);
  final total = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  ).format(p.totalAmount);
  final ref = p.humanId.trim().isNotEmpty ? p.humanId.trim() : p.id;
  final lineCount = p.lines.length;

  return 'New Purchase Order — $title\n'
      'Supplier: $supplier\n'
      'Date: $dateStr\n'
      'Items: $lineCount items\n'
      'Total: $total\n'
      'Ref: $ref';
}

Uri whatsappUriForAccounts(String phone10, String message) {
  return Uri.parse(
    'https://wa.me/91$phone10?text=${Uri.encodeComponent(message)}',
  );
}

/// Generic WhatsApp summary (no fixed recipient).
Future<void> openWhatsAppSummaryMessage(
  TradePurchase p, {
  BusinessProfile? biz,
}) async {
  final profile = biz ??
      const BusinessProfile(
        legalName: 'Workspace',
        displayTitle: 'Purchase order',
      );
  final text = buildAccountsWhatsAppSummary(p, profile);
  final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Returns true when share may proceed (number configured or user chose Skip).
Future<bool> ensureAccountsWhatsappConfigured(
  BuildContext context,
  WidgetRef ref,
) async {
  final phone =
      normalizeIndiaMobile10(ref.read(invoiceBusinessProfileProvider).accountsWhatsappNumber);
  if (phone != null) return true;
  if (!context.mounted) return false;

  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Accounts WhatsApp not set'),
      content: const Text(
        'Set accounts staff WhatsApp number in Settings first. Go to Settings?',
      ),
      actions: [
        TextButton(
          onPressed: () => popOverlay(ctx, false),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: () => popOverlay(ctx, true),
          child: const Text('Go to Settings'),
        ),
      ],
    ),
  );
  if (go == true && context.mounted) {
    await context.push('/settings/business');
  }
  if (!context.mounted) return false;
  final after =
      normalizeIndiaMobile10(ref.read(invoiceBusinessProfileProvider).accountsWhatsappNumber);
  return after != null;
}

/// Shares purchase PDF via OS sheet, then opens WhatsApp to accounts staff with summary.
/// WhatsApp deep links cannot attach PDF bytes; user attaches PDF from the share sheet if needed.
Future<PdfActionResult> sharePurchaseToAccountsStaff(
  TradePurchase p,
  BusinessProfile biz,
) async {
  final phone10 = normalizeIndiaMobile10(biz.accountsWhatsappNumber);
  if (phone10 == null) {
    return const PdfActionResult(
      ok: false,
      message: 'Accounts WhatsApp number is not configured.',
    );
  }

  final pdfResult = await sharePurchasePdf(p, biz);
  if (!pdfResult.ok) {
    return pdfResult;
  }

  final message = buildAccountsWhatsAppSummary(p, biz);
  final waUri = whatsappUriForAccounts(phone10, message);
  if (await canLaunchUrl(waUri)) {
    await launchUrl(waUri, mode: LaunchMode.externalApplication);
  }

  return pdfResult;
}
