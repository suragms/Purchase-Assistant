import 'package:flutter/material.dart';

import '../../../../core/design_system/widgets/app_form_layout.dart';
import '../../../../core/design_system/widgets/app_text_field.dart';
import '../../../../core/utils/item_code_format.dart';

// Shared catalog field widgets (DUP-F-003).
// Same labels as [CatalogItemDefaultsEditForm] — create / barcode / batch reuse these
// instead of forking InputDecoration / TextField copies.

/// Catalog item display name — label matches edit form (`Name *`).
class CatalogItemNameField extends StatelessWidget {
  const CatalogItemNameField({
    super.key,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.characters,
    this.textInputAction,
    this.hint,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: 'Name *',
      helper: hint,
      errorText: errorText,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

/// Item code — [codeRequired] flips label to `Item code *`.
class CatalogItemCodeField extends StatelessWidget {
  const CatalogItemCodeField({
    super.key,
    required this.controller,
    this.focusNode,
    this.codeRequired = false,
    this.helper,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool codeRequired;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: codeRequired ? 'Item code *' : 'Item code',
      helper: helper ??
          (codeRequired ? 'A-Z, 0-9, hyphen' : 'Auto-generated if empty'),
      inputFormatters: [ItemCodeInputFormatter()],
      textCapitalization: TextCapitalization.characters,
    );
  }
}

class CatalogItemHsnField extends StatelessWidget {
  const CatalogItemHsnField({
    super.key,
    required this.controller,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: 'HSN code',
    );
  }
}

class CatalogItemKgPerBagField extends StatelessWidget {
  const CatalogItemKgPerBagField({
    super.key,
    required this.controller,
    this.focusNode,
    this.unitIsBag = true,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool unitIsBag;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: unitIsBag ? 'Kg per bag *' : 'Kg per bag (optional)',
      helper: unitIsBag
          ? 'Required when stock unit is bag'
          : 'Set unit to bag if this item is stocked in bags',
      errorText: errorText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}

class CatalogItemDefaultRatesRow extends StatelessWidget {
  const CatalogItemDefaultRatesRow({
    super.key,
    required this.landCtrl,
    required this.sellCtrl,
    this.landFocus,
    this.sellFocus,
  });

  final TextEditingController landCtrl;
  final TextEditingController sellCtrl;
  final FocusNode? landFocus;
  final FocusNode? sellFocus;

  @override
  Widget build(BuildContext context) {
    return AppFormRow(
      children: [
        AppTextField(
          controller: landCtrl,
          focusNode: landFocus,
          label: 'Default landing (\u20B9)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        AppTextField(
          controller: sellCtrl,
          focusNode: sellFocus,
          label: 'Default selling (\u20B9)',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }
}
