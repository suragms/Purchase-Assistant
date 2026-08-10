import 'package:flutter_test/flutter_test.dart';
import 'package:harisree_warehouse/core/debug/agent_debug_log.dart';
import 'package:harisree_warehouse/features/shell/shell_realtime_listener.dart';

void main() {
  test('agent debug ingest is off by default (no HEXA_AGENT_DEBUG_LOG)', () {
    expect(agentDebugLogEnabled, isFalse);
    expect(kHexaAgentDebugLog, isFalse);
  });

  test('realtime warehouse coalesce is at least 5s', () {
    expect(
      kRealtimeWarehouseCoalesce.inSeconds,
      greaterThanOrEqualTo(5),
    );
  });
}
