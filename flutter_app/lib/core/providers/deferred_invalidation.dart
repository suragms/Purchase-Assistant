import 'package:flutter/scheduler.dart';

/// Avoid Riverpod "modify provider during build" when listeners react to writes.
void deferInvalidate(dynamic ref, Object provider) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(provider);
  });
}

void deferVoid(void Function() fn) {
  SchedulerBinding.instance.addPostFrameCallback((_) => fn());
}
