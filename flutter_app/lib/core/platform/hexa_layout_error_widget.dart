import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../widgets/hexa_page_error_boundary.dart'
    show hexaAsyncErrorLikelyBenign, hexaErrorLikelyNonFatal;
import 'hexa_app_reload.dart';

/// Shown for widget build/layout failures ([ErrorWidget.builder]).
/// Compact so one bad section does not fill the whole screen.
Widget buildHexaLayoutErrorWidget(FlutterErrorDetails details) {
  if (kDebugMode) {
    debugPrint(
      'Hexa layout error:\n${details.exceptionAsString()}\n\n${details.stack ?? '(no stack)'}',
    );
  }

  // Reuse the same classification already used by FlutterError.onError and
  // PlatformDispatcher.onError. Benign / non-fatal errors (network blips,
  // render-flex overflows, disposed-provider races, etc.) should not show
  // the "section could not load" box — fail silently so the section simply
  // re-renders on the next frame or a pull-to-refresh.
  if (hexaErrorLikelyNonFatal(details) ||
      hexaAsyncErrorLikelyBenign(details.exception)) {
    return const SizedBox.shrink();
  }

  // Non-benign: show the warning box, but only include the raw diagnostic
  // dump in debug / profile builds so production users never see internals.
  return Material(
    color: const Color(0xFFF8FAFC),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 22,
                color: Colors.orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'This section could not load.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap Reload or pull to refresh. If this repeats, sign out and sign in again.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            '${details.exceptionAsString()}\n\n'
                            '${details.stack?.toString() ?? '(no stack)'}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              height: 1.35,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: reloadHexaApp,
              child: const Text('Reload'),
            ),
          ),
        ],
      ),
    ),
  );
}
