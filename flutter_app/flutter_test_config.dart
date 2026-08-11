import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Load real fonts so golden images render legible glyphs (not Ahem boxes).
///
/// Must be loaded before golden capture so text width/size in goldens matches
/// production (PlusJakartaSans is the app's primary UI font).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final root = Directory.current.path;

  Future<void> load(String family, String fileName) async {
    final bytes = File('$root/assets/fonts/$fileName').readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await load('PlusJakartaSans', 'PlusJakartaSans-Regular.ttf');
  await load('PlusJakartaSans', 'PlusJakartaSans-Medium.ttf');
  await load('PlusJakartaSans', 'PlusJakartaSans-SemiBold.ttf');
  await load('PlusJakartaSans', 'PlusJakartaSans-Bold.ttf');
  await load('PlusJakartaSans', 'PlusJakartaSans-ExtraBold.ttf');
  await load('Inter', 'Inter-Medium.ttf');
  await load('Inter', 'Inter-SemiBold.ttf');
  await load('NotoSans', 'NotoSans-Regular.ttf');
  await load('NotoSans', 'NotoSans-Bold.ttf');
  await load('NotoSansMalayalam', 'NotoSansMalayalam-Regular.ttf');

  await testMain();
}