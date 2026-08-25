import 'package:flutter/material.dart';

import '../../../../core/theme/hexa_colors.dart';

const double kPurchaseFieldHeight = 44;

/// Desktop/tablet voucher chrome — Tally-like dense header fields.
const double kPurchaseVoucherFieldHeight = 36;

InputDecoration densePurchaseFieldDecoration(
  String label, {
  String? hint,
  String? prefixText,
  bool voucher = false,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefixText,
    isDense: true,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(voucher ? 4 : 8),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(voucher ? 4 : 8),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(voucher ? 4 : 8)),
      borderSide: const BorderSide(color: HexaColors.brandPrimary, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: voucher
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  );
}
