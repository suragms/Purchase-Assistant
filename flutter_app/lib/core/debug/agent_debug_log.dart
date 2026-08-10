import 'package:flutter/foundation.dart';

import 'agent_debug_log_stub.dart'
    if (dart.library.html) 'agent_debug_log_web.dart' as impl;

/// Opt-in Cursor debug ingest. Default **off** even in [kDebugMode] to avoid
/// Network spam (`POST 127.0.0.1:7388/ingest/...`) on every rebuild.
///
/// Enable: `--dart-define=HEXA_AGENT_DEBUG_LOG=true`
const bool kHexaAgentDebugLog = bool.fromEnvironment(
  'HEXA_AGENT_DEBUG_LOG',
  defaultValue: false,
);

/// Session debug ingest (Cursor debug mode). Best-effort; never throws.
/// No-ops unless [kHexaAgentDebugLog] is true.
void agentDebugLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'pre-fix',
}) {
  if (!kHexaAgentDebugLog) return;
  // #region agent log
  impl.agentDebugLogImpl(
    hypothesisId: hypothesisId,
    location: location,
    message: message,
    data: data,
    runId: runId,
  );
  // #endregion
}

/// Whether [agentDebugLog] would emit (for tests / callers).
@visibleForTesting
bool get agentDebugLogEnabled => kHexaAgentDebugLog;
