import 'package:flutter/material.dart';

import '../hexa_ds_tokens.dart';
import 'app_button.dart';

/// Confirm dialog policy: one [AlertDialog], no nested sheets, Esc cancels.
/// Controllers must live in a [StatefulWidget] that [dispose]s them — never
/// allocate [TextEditingController] in this builder.
Future<bool> showHexaConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title, style: HexaDsType.heading(18)),
        content: Text(message, style: HexaDsType.body(14)),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          SizedBox(
            width: 120,
            child: AppSecondaryButton(
              dense: true,
              label: cancelLabel,
              onPressed: () => Navigator.pop(ctx, false),
            ),
          ),
          SizedBox(
            width: 140,
            child: destructive
                ? FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: HexaDsColors.error,
                      minimumSize: const Size(140, 44),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(confirmLabel),
                  )
                : AppPrimaryButton(
                    label: confirmLabel,
                    onPressed: () => Navigator.pop(ctx, true),
                  ),
          ),
        ],
      );
    },
  );
  return ok == true;
}

/// Host for forms that need controllers — caller owns lifecycle.
Future<T?> showHexaFormDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: builder,
  );
}

/// Loading-aware primary CTA for dialogs/sheets.
class AppLoadingButton extends StatelessWidget {
  const AppLoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      enabled: enabled,
    );
  }
}
