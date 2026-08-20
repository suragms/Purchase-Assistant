import 'package:flutter/material.dart';

import '../../theme/hexa_colors.dart';
import '../hexa_ds_tokens.dart';
import '../hexa_glass_theme.dart';
import '../hexa_responsive.dart';

/// Canonical select — parent owns selection state; never instantiate
/// [TextEditingController] for the selected value inside [build].
class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
    this.hint,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? errorText;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final hx = context.hx;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: HexaResponsive.minTouchTarget),
      child: DropdownButtonFormField<T>(
        key: ValueKey<Object?>(value),
        initialValue: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        isExpanded: true,
        hint: hint == null ? null : Text(hint!),
        decoration: InputDecoration(
          labelText: label,
          errorText: hasError ? errorText : null,
          filled: true,
          fillColor: enabled ? hx.inputFill : hx.surfaceCanvas,
          border: OutlineInputBorder(
            borderRadius: HexaDsRadii.input,
            borderSide: BorderSide(color: hx.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: HexaDsRadii.input,
            borderSide: BorderSide(
              color: hasError
                  ? HexaDsColors.error.withValues(alpha: 0.88)
                  : hx.borderSubtle,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: HexaDsRadii.input,
            borderSide: BorderSide(
              color: hasError ? HexaDsColors.error : HexaColors.brandAccent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
