import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/session_notifier.dart';
import '../../../../core/providers/business_aggregates_invalidation.dart';
import '../../../../core/providers/catalog_providers.dart';
import '../../../../core/providers/trade_purchases_provider.dart';
import '../../../../core/widgets/form_field_scroll.dart';
import '../../../../shared/widgets/bag_default_unit_hint.dart';
import '../../../../shared/widgets/search_picker_sheet.dart';

/// Full-screen / sheet body for editing catalog item defaults (name, unit, costs).
class CatalogItemDefaultsEditForm extends StatefulWidget {
  const CatalogItemDefaultsEditForm({
    super.key,
    required this.pickerContext,
    required this.nameCtrl,
    required this.hsnCtrl,
    required this.taxCtrl,
    required this.kgCtrl,
    required this.ipbCtrl,
    required this.wptCtrl,
    required this.landCtrl,
    required this.sellCtrl,
    required this.initialUnit,
    this.scrollController,
    this.showHeader = false,
  });

  final BuildContext pickerContext;
  final TextEditingController nameCtrl;
  final TextEditingController hsnCtrl;
  final TextEditingController taxCtrl;
  final TextEditingController kgCtrl;
  final TextEditingController ipbCtrl;
  final TextEditingController wptCtrl;
  final TextEditingController landCtrl;
  final TextEditingController sellCtrl;
  final String? initialUnit;
  final ScrollController? scrollController;
  final bool showHeader;

  @override
  State<CatalogItemDefaultsEditForm> createState() =>
      CatalogItemDefaultsEditFormState();
}

class CatalogItemDefaultsEditFormState
    extends State<CatalogItemDefaultsEditForm> {
  late String? _unit;
  late final FocusNode _nameFocus;
  late final FocusNode _hsnFocus;
  late final FocusNode _taxFocus;
  late final FocusNode _kgFocus;
  late final FocusNode _ipbFocus;
  late final FocusNode _wptFocus;
  late final FocusNode _landFocus;
  late final FocusNode _sellFocus;

  @override
  void initState() {
    super.initState();
    _unit = widget.initialUnit;
    _nameFocus = FocusNode();
    _hsnFocus = FocusNode();
    _taxFocus = FocusNode();
    _kgFocus = FocusNode();
    _ipbFocus = FocusNode();
    _wptFocus = FocusNode();
    _landFocus = FocusNode();
    _sellFocus = FocusNode();
    bindFocusNodeScrollIntoView(_nameFocus);
    bindFocusNodeScrollIntoView(_hsnFocus);
    bindFocusNodeScrollIntoView(_taxFocus);
    bindFocusNodeScrollIntoView(_kgFocus);
    bindFocusNodeScrollIntoView(_ipbFocus);
    bindFocusNodeScrollIntoView(_wptFocus);
    bindFocusNodeScrollIntoView(_landFocus);
    bindFocusNodeScrollIntoView(_sellFocus);
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _hsnFocus.dispose();
    _taxFocus.dispose();
    _kgFocus.dispose();
    _ipbFocus.dispose();
    _wptFocus.dispose();
    _landFocus.dispose();
    _sellFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sp =
        formFieldScrollPaddingForContext(context, reserveBelowField: 220);
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        if (widget.showHeader) ...[
          Text(
            'Edit core item setup and save.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: widget.nameCtrl,
          focusNode: _nameFocus,
          scrollPadding: sp,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.hsnCtrl,
          focusNode: _hsnFocus,
          scrollPadding: sp,
          decoration: const InputDecoration(labelText: 'HSN code'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.taxCtrl,
          focusNode: _taxFocus,
          scrollPadding: sp,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Tax %',
            hintText: 'e.g. 5',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Default unit (optional)',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        OutlinedButton(
          onPressed: () async {
            const none = '__unit_none__';
            final id = await showSearchPickerSheet<String>(
              context: widget.pickerContext,
              title: 'Default unit',
              rows: const [
                SearchPickerRow(value: none, title: '— (unspecified)'),
                SearchPickerRow(value: 'kg', title: 'kg'),
                SearchPickerRow(value: 'bag', title: 'bag'),
                SearchPickerRow(value: 'box', title: 'box'),
                SearchPickerRow(value: 'piece', title: 'piece'),
              ],
              selectedValue: _unit ?? none,
            );
            if (!mounted) return;
            if (id != null) {
              setState(() => _unit = id == none ? null : id);
            }
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(_unit == null ? '— (unspecified)' : '$_unit'),
          ),
        ),
        if (_unit == 'bag') ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.kgCtrl,
            focusNode: _kgFocus,
            scrollPadding: sp,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Default kg per bag (optional)',
              hintText: 'e.g. 50',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          BagDefaultUnitHint(
            kgAlreadySet: () {
              final v = parseOptionalKgPerBag(widget.kgCtrl.text);
              return v != null && v > 0;
            }(),
          ),
        ],
        if (_unit == 'box') ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.ipbCtrl,
            focusNode: _ipbFocus,
            scrollPadding: sp,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Items per box',
              hintText: 'How many pieces per box',
            ),
          ),
        ],
        if (_unit == 'tin') ...[
          const SizedBox(height: 12),
          TextField(
            controller: widget.wptCtrl,
            focusNode: _wptFocus,
            scrollPadding: sp,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Liters / weight per tin',
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: widget.landCtrl,
          focusNode: _landFocus,
          scrollPadding: sp,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Default landing (₹)',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.sellCtrl,
          focusNode: _sellFocus,
          scrollPadding: sp,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Default selling (₹)',
          ),
        ),
      ],
    );
  }

  String? get selectedUnit => _unit;
}

/// Persists catalog defaults from controllers. Returns true on success.
Future<bool> saveCatalogItemDefaults({
  required WidgetRef ref,
  required String itemId,
  required String? unit,
  required TextEditingController nameCtrl,
  required TextEditingController hsnCtrl,
  required TextEditingController taxCtrl,
  required TextEditingController kgCtrl,
  required TextEditingController ipbCtrl,
  required TextEditingController wptCtrl,
  required TextEditingController landCtrl,
  required TextEditingController sellCtrl,
}) async {
  final session = ref.read(sessionProvider);
  if (session == null) return false;
  final kgParsed = unit == 'bag' ? parseOptionalKgPerBag(kgCtrl.text) : null;
  final tax = double.tryParse(taxCtrl.text.trim());
  final ipb = double.tryParse(ipbCtrl.text.trim());
  final wpt = double.tryParse(wptCtrl.text.trim());
  final land = double.tryParse(landCtrl.text.trim());
  final sell = double.tryParse(sellCtrl.text.trim());
  try {
    await ref.read(hexaApiProvider).updateCatalogItem(
          businessId: session.primaryBusiness.id,
          itemId: itemId,
          name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
          hsnCode: hsnCtrl.text.trim().isEmpty ? null : hsnCtrl.text.trim(),
          taxPercent: tax,
          defaultLandingCost: land,
          defaultSellingCost: sell,
          includeDefaultUnit: true,
          defaultUnit: unit,
          patchDefaultKgPerBag: unit == 'bag',
          defaultKgPerBag: kgParsed,
          patchDefaultItemsPerBox: unit == 'box',
          defaultItemsPerBox: ipb,
          patchDefaultWeightPerTin: unit == 'tin',
          defaultWeightPerTin: wpt,
        );
    ref.invalidate(catalogItemDetailProvider(itemId));
    ref.invalidate(tradePurchasesCatalogIntelProvider);
    invalidatePurchaseWorkspace(ref);
    return true;
  } on DioException {
    rethrow;
  }
}
