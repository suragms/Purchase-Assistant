import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'hexa_app_reload.dart';

/// Shown for widget build/layout failures ([ErrorWidget.builder]).
/// Copy aligned with [_HexaErrorBoundary] in app.dart.
Widget buildHexaLayoutErrorWidget(FlutterErrorDetails details) {
  final message = details.exceptionAsString().split('\n').first;
  return Material(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not load the app. Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: reloadHexaApp,
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    ),
  );
}
