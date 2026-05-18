import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/design_system/hexa_ds_tokens.dart';
import '../../core/theme/hexa_colors.dart';

/// A reusable premium date picker button that resolves keyboard overlay issues.
class DatePickerButton extends StatelessWidget {
  const DatePickerButton({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled) return;

    // Unfocus any active fields to ensure the keyboard is dismissed
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final initialDate = value ?? now;
    final first = firstDate ?? DateTime(2020);
    final last = lastDate ?? now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(last)
          ? last
          : (initialDate.isBefore(first) ? first : initialDate),
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: HexaColors.brandPrimary,
              onPrimary: Colors.white,
              onSurface: HexaDsColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: HexaColors.brandPrimary,
                textStyle: HexaDsType.label(14),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final formattedDate = hasValue
        ? DateFormat('dd MMM yyyy').format(value!)
        : label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => _selectDate(context) : null,
        borderRadius: HexaDsRadii.input,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: enabled ? HexaDsColors.inputFill : Colors.grey.shade50,
            borderRadius: HexaDsRadii.input,
            border: Border.all(
              color: HexaColors.inputBorderGrey,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: enabled
                      ? (hasValue ? HexaColors.brandPrimary : Colors.grey.shade500)
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: HexaDsType.body(
                      15,
                      color: enabled
                          ? (hasValue ? HexaDsColors.textPrimary : Colors.grey.shade500)
                          : Colors.grey.shade400,
                      weight: hasValue ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
