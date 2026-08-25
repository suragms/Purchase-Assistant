import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/form_field_scroll.dart';
import '../../../../shared/widgets/keyboard_safe_form_viewport.dart';
import '../../domain/purchase_draft.dart';
import '../../state/purchase_draft_provider.dart';
import 'purchase_wizard_shared.dart';

import '../../../../core/theme/hexa_colors.dart';

/// Step 2 — deal terms once (Payment days primary; discount/narration disclosed).
class PurchaseTermsOnlyStep extends ConsumerWidget {
  const PurchaseTermsOnlyStep({
    super.key,
    required this.paymentDaysFocus,
    required this.paymentDaysCtrl,
    required this.commissionCtrl,
    required this.headerDiscCtrl,
    required this.narrationCtrl,
    this.commissionFocus,
    this.headerDiscFocus,
    this.narrationFocus,
    required this.onDraftChanged,
    /// When true (Party step embeds this under an outer scroll), skip nested
    /// [KeyboardSafeFormViewport] to avoid unbounded-height viewport crashes.
    this.embeddedInOuterScroll = false,
    /// Desktop (≥1024px) arranges Payment Days | Discount % | Narration in one grid row.
    this.desktop = false,
  });

  final FocusNode paymentDaysFocus;
  final TextEditingController paymentDaysCtrl;
  final TextEditingController commissionCtrl;
  final TextEditingController headerDiscCtrl;
  /// Stored on wire as `invoice_number`; UX label = Narration/Ref.
  final TextEditingController narrationCtrl;
  final FocusNode? commissionFocus;
  final FocusNode? headerDiscFocus;
  final FocusNode? narrationFocus;
  final VoidCallback onDraftChanged;
  final bool desktop;
  final bool embeddedInOuterScroll;

  static String _duePreview(WidgetRef ref, TextEditingController c) {
    final pd = int.tryParse(c.text.trim());
    if (pd == null || pd < 0) return 'Due: —';
    final d0 = ref.read(purchaseDraftProvider).purchaseDate ?? DateTime.now();
    final d = d0.add(Duration(days: pd));
    return 'Due: ${DateFormat('dd MMM yyyy').format(d)}';
  }

  /// Short label for the fixed-commission **unit** dropdown (same row as ₹).
  static String _unitDropdownLabel(String mode) {
    switch (PurchaseDraft.normalizeCommissionMode(mode)) {
      case kPurchaseCommissionModeFlatInvoice:
        return 'Once / bill';
      case kPurchaseCommissionModeFlatKg:
        return 'Kg';
      case kPurchaseCommissionModeFlatBag:
        return 'Bag';
      case kPurchaseCommissionModeFlatBox:
        return 'Box';
      case kPurchaseCommissionModeFlatTin:
        return 'Tin';
      default:
        return '—';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controllers own payment/discount/narration text — only watch fields that
    // change chrome (supplier link, broker, commission mode), not every draft
    // keystroke via full [purchaseDraftProvider].
    final termsChrome = ref.watch(
      purchaseDraftProvider.select(
        (d) => (
          supplierId: d.supplierId,
          supplierName: d.supplierName,
          brokerId: d.brokerId,
          commissionMode: d.commissionMode,
          lines: d.lines,
        ),
      ),
    );
    final needsSupplierLink = termsChrome.supplierId == null ||
        termsChrome.supplierId!.trim().isEmpty;
    final hasBroker = termsChrome.brokerId != null &&
        termsChrome.brokerId!.trim().isNotEmpty;
    final sub = Theme.of(context).colorScheme.onSurfaceVariant;
    final mode = termsChrome.commissionMode;
    final draftSupplierName = termsChrome.supplierName;
    final draftLines = termsChrome.lines;
    final supplierNameTrimmed = draftSupplierName?.trim() ?? '';

    Widget orderedField({
      required int order,
      required TextEditingController c,
      required String label,
      FocusNode? focusNode,
      TextInputAction textInputAction = TextInputAction.next,
      VoidCallback? onSubmitted,
      TextInputType? keyboard,
      int maxLines = 1,
      void Function(String)? onChanged,
      InputDecoration? decoration,
      bool voucher = false,
    }) {
      final h = voucher ? kPurchaseVoucherFieldHeight : kPurchaseFieldHeight;
      final tf = TextField(
        controller: c,
        focusNode: focusNode,
        keyboardType: keyboard,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 1 : null,
        scrollPadding: formFieldScrollPaddingForContext(
          context,
          reserveBelowField: voucher ? 120 : 280,
        ),
        textInputAction: textInputAction,
        onSubmitted: onSubmitted != null ? (_) => onSubmitted() : null,
        textCapitalization: maxLines > 1
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        style: voucher ? const TextStyle(fontSize: 13) : null,
        decoration: decoration ??
            densePurchaseFieldDecoration(label, voucher: voucher),
        onChanged: onChanged,
      );
      return FocusTraversalOrder(
        order: NumericFocusOrder(order.toDouble()),
        child: Padding(
          padding: EdgeInsets.only(bottom: voucher ? 0 : 4),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: h),
            child: tf,
          ),
        ),
      );
    }

    final paymentDaysField = orderedField(
      order: 10,
      c: paymentDaysCtrl,
      label: 'Payment days',
      focusNode: paymentDaysFocus,
      keyboard: TextInputType.number,
      voucher: desktop,
      onChanged: (s) {
        ref.read(purchaseDraftProvider.notifier).setPaymentDaysText(s);
        onDraftChanged();
      },
    );
    final paymentDaysCol = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        paymentDaysField,
        if (!desktop)
          ListenableBuilder(
            listenable: paymentDaysCtrl,
            builder: (_, __) {
              final t = paymentDaysCtrl.text.trim();
              if (t.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _duePreview(ref, paymentDaysCtrl),
                  style: const TextStyle(
                    fontSize: 12,
                    color: HexaColors.brandTealBright,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
      ],
    );
    final discountField = orderedField(
      order: hasBroker ? 40 : 20,
      c: headerDiscCtrl,
      label: 'Discount %',
      focusNode: headerDiscFocus,
      keyboard: const TextInputType.numberWithOptions(decimal: true),
      voucher: desktop,
      onChanged: (s) {
        ref
            .read(purchaseDraftProvider.notifier)
            .setHeaderDiscountFromText(s);
        onDraftChanged();
      },
    );
    final narrationField = orderedField(
      order: hasBroker ? 50 : 30,
      c: narrationCtrl,
      label: 'Narration / ref (optional)',
      focusNode: narrationFocus,
      keyboard: TextInputType.text,
      maxLines: desktop ? 1 : 2,
      voucher: desktop,
      textInputAction: TextInputAction.done,
      onSubmitted: () => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (s) {
        ref.read(purchaseDraftProvider.notifier).setInvoiceText(s);
        onDraftChanged();
      },
    );

    Widget brokerCommissionBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Broker commission',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: desktop ? 12 : null,
                ),
          ),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment<String>(
                value: kPurchaseCommissionModePercent,
                label: Text('Commission %'),
                icon: Icon(Icons.percent_rounded, size: 18),
              ),
              ButtonSegment<String>(
                value: '_figure',
                label: Text('Fixed ₹'),
                icon: Icon(Icons.currency_rupee_rounded, size: 18),
              ),
            ],
            emptySelectionAllowed: false,
            selected: <String>{
              if (mode == kPurchaseCommissionModePercent)
                kPurchaseCommissionModePercent
              else
                '_figure',
            },
            onSelectionChanged: (Set<String> next) {
              final v = next.first;
              if (v == kPurchaseCommissionModePercent) {
                ref
                    .read(purchaseDraftProvider.notifier)
                    .setCommissionMode(kPurchaseCommissionModePercent);
              } else {
                final sug = suggestedBrokerFigureModeFromLines(draftLines);
                ref.read(purchaseDraftProvider.notifier).setCommissionMode(sug);
              }
              onDraftChanged();
            },
          ),
          if (mode == kPurchaseCommissionModePercent) ...[
            const SizedBox(height: 6),
            Text(
              '% of each line ₹ total after purchase discount. '
              'For ₹ per kg / bag / tin, switch to Fixed ₹.',
              style: TextStyle(fontSize: 11, height: 1.25, color: sub),
            ),
            const SizedBox(height: 8),
            orderedField(
              order: 20,
              c: commissionCtrl,
              label: 'Commission %',
              focusNode: commissionFocus,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              voucher: desktop,
              decoration: densePurchaseFieldDecoration(
                'Commission %',
                voucher: desktop,
              ).copyWith(suffixText: '%'),
              onChanged: (s) {
                ref.read(purchaseDraftProvider.notifier).setCommissionText(s);
                onDraftChanged();
              },
            ),
          ] else ...[
            Builder(
              builder: (context) {
                final figOpts = brokerFigureUiOptions(draftLines);
                final allowed = figOpts.map((e) => e.$1).toSet();
                final coerced = allowed.contains(mode)
                    ? mode
                    : clampFigureModeToUiOptions(mode, draftLines);
                if (coerced != mode) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;
                    ref
                        .read(purchaseDraftProvider.notifier)
                        .setCommissionMode(coerced);
                    onDraftChanged();
                  });
                }

                final hint = brokerFigureBasisLineHint(draftLines, coerced);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Choose what the ₹ amount multiplies by. '
                      'You can set this before adding items; hints update after lines exist.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: sub,
                      ),
                    ),
                    const SizedBox(height: 8),
                    orderedField(
                      order: 20,
                      c: commissionCtrl,
                      label: 'Amount (₹)',
                      focusNode: commissionFocus,
                      keyboard: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      voucher: desktop,
                      decoration: densePurchaseFieldDecoration(
                        'Amount (₹)',
                        voucher: desktop,
                      ),
                      onChanged: (s) {
                        ref
                            .read(purchaseDraftProvider.notifier)
                            .setCommissionText(s);
                        onDraftChanged();
                      },
                    ),
                    const SizedBox(height: 8),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(30),
                      child: InputDecorator(
                        decoration: densePurchaseFieldDecoration(
                          'Commission applies to',
                          voucher: desktop,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: coerced,
                            isExpanded: true,
                            isDense: true,
                            items: [
                              for (final o in figOpts)
                                DropdownMenuItem<String>(
                                  value: o.$1,
                                  child: Text(
                                    _unitDropdownLabel(o.$1),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              ref
                                  .read(purchaseDraftProvider.notifier)
                                  .setCommissionMode(v);
                              onDraftChanged();
                            },
                          ),
                        ),
                      ),
                    ),
                    if (hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          hint,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            color: sub,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      );
    }

    // ── Desktop voucher: payment + discount always visible; rest collapsed ──
    if (desktop) {
      final moreOpen = narrationCtrl.text.trim().isNotEmpty ||
          (hasBroker && commissionCtrl.text.trim().isNotEmpty);
      final voucherColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (needsSupplierLink)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Pick a supplier above to link catalog rates.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade900,
                ),
              ),
            )
          else if (supplierNameTrimmed.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Defaults from $supplierNameTrimmed',
                style: const TextStyle(
                  fontSize: 11,
                  color: HexaColors.brandTealBright,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: paymentDaysCol),
              const SizedBox(width: 8),
              Expanded(child: discountField),
              const SizedBox(width: 8),
              Expanded(
                child: ListenableBuilder(
                  listenable: paymentDaysCtrl,
                  builder: (_, __) {
                    final t = paymentDaysCtrl.text.trim();
                    if (t.isEmpty) {
                      return const SizedBox(height: kPurchaseVoucherFieldHeight);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        _duePreview(ref, paymentDaysCtrl),
                        style: const TextStyle(
                          fontSize: 11,
                          color: HexaColors.brandTealBright,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: moreOpen,
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 4),
              visualDensity: VisualDensity.compact,
              title: Text(
                'More terms',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
              ),
              subtitle: Text(
                hasBroker
                    ? 'Narration · broker commission'
                    : 'Narration / ref',
                style: TextStyle(fontSize: 10, color: sub),
              ),
              children: [
                narrationField,
                if (hasBroker) ...[
                  const SizedBox(height: 8),
                  brokerCommissionBlock(),
                ],
              ],
            ),
          ),
        ],
      );
      return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: voucherColumn,
      );
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (needsSupplierLink) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.link_rounded,
                        size: 20, color: Colors.amber.shade900),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        supplierNameTrimmed.isNotEmpty
                            ? 'Bill shows “$supplierNameTrimmed” — go back to Party and pick the matching directory supplier. You can still edit payment days and charges below.'
                            : 'Select a supplier on the Party step first. You can still edit payment days and charges below.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (!needsSupplierLink && supplierNameTrimmed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: HexaColors.brandTealBright.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: HexaColors.brandTealBright.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_fix_high,
                      size: 16, color: HexaColors.brandTealBright),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Defaults from $supplierNameTrimmed (editable)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: HexaColors.brandTealBright,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Text(
          'Payment terms',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        paymentDaysCol,
        Builder(
          builder: (context) {
            final hasOptionalTerms = headerDiscCtrl.text.trim().isNotEmpty ||
                narrationCtrl.text.trim().isNotEmpty;
            final optionalBody = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                discountField,
                narrationField,
              ],
            );
            return Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: ValueKey<String>(
                  'terms-optional-${hasOptionalTerms ? 'open' : 'closed'}',
                ),
                initiallyExpanded: hasOptionalTerms,
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 4),
                title: Text(
                  'Discount & narration',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                ),
                subtitle: hasOptionalTerms
                    ? null
                    : Text(
                        'Optional',
                        style: TextStyle(fontSize: 11, color: sub),
                      ),
                children: [optionalBody],
              ),
            );
          },
        ),
        if (hasBroker) ...[
          const SizedBox(height: 8),
          brokerCommissionBlock(),
          const SizedBox(height: 8),
        ],
      ],
    );

    final fields = FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: column,
    );

    // Nested under wizard SingleChildScrollView — never wrap another scroll viewport.
    if (embeddedInOuterScroll) {
      return fields;
    }

    // Scaffold (when used) owns IME resize — do not pass viewInsets into
    // bottomExtraInset (KeyboardSafeFormViewport default already excludes it).
    return KeyboardSafeFormViewport(
      dismissKeyboardOnTap: true,
      horizontalPadding: 0,
      topPadding: 0,
      minFieldsHeight: 0,
      fields: fields,
      footer: const SizedBox.shrink(),
    );
  }
}
