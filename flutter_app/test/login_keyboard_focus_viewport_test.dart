import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:harisree_warehouse/core/providers/prefs_provider.dart';
import 'package:harisree_warehouse/features/auth/presentation/login_page.dart';
import 'package:harisree_warehouse/features/auth/presentation/widgets/auth_page_shell.dart';

Finder _fieldByDecoration(String labelOrHint) {
  return find.byWidgetPredicate(
    (w) =>
        w is TextField &&
        (w.decoration?.labelText == labelOrHint ||
            w.decoration?.hintText == labelOrHint),
  );
}

/// Confirms login does not double-apply IME inset (Scaffold + scroll padding),
/// which previously clipped the email field / card under the top on password focus.
void main() {
  Future<void> pumpLogin(
    WidgetTester tester, {
    required Size size,
    required ValueNotifier<EdgeInsets> insets,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ValueListenableBuilder<EdgeInsets>(
        valueListenable: insets,
        builder: (context, viewInsets, _) {
          return MediaQuery(
            data: MediaQueryData(size: size, viewInsets: viewInsets),
            child: ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(prefs),
              ],
              child: const MaterialApp(
                home: LoginPage(),
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectEmailFieldTopInViewport(WidgetTester tester, Size size) {
    final emailField = _fieldByDecoration('Email');
    expect(emailField, findsOneWidget);

    final box = tester.renderObject<RenderBox>(emailField);
    final topLeft = box.localToGlobal(Offset.zero);
    expect(
      topLeft.dy,
      greaterThanOrEqualTo(-0.5),
      reason: 'Email field must not clip above the viewport top '
          '(got dy=${topLeft.dy} for size=$size)',
    );
    expect(topLeft.dy, lessThan(size.height));
  }

  void expectDesktopCardCentered(WidgetTester tester, Size size) {
    final card = find.byType(AuthFormCard);
    expect(card, findsOneWidget);
    final cardBox = tester.renderObject<RenderBox>(card);
    final cardTop = cardBox.localToGlobal(Offset.zero).dy;
    final cardCenterY = cardTop + cardBox.size.height / 2;
    final lowerBound = size.height * 0.2;
    final upperBound = size.height * 0.8;
    expect(
      cardCenterY,
      inInclusiveRange(lowerBound, upperBound),
      reason: 'Auth card center Y ($cardCenterY) should stay in middle 60% '
          'of viewport ($lowerBound–$upperBound) on desktop',
    );
  }

  void expectAuthShellFillsViewport(WidgetTester tester, Size size) {
    final shell = find.byType(AuthPageShell);
    expect(shell, findsOneWidget);
    final shellBox = tester.renderObject<RenderBox>(shell);
    expect(
      shellBox.size.height,
      greaterThanOrEqualTo(size.height * 0.95),
      reason: 'AuthPageShell height (${shellBox.size.height}) must fill viewport '
          '(${size.height}) — shrunk scaffold body exposes blank band',
    );
  }

  testWidgets(
      'desktop login: typing in email keeps card centered with IME inset',
      (tester) async {
    const desktop = Size(1536, 776);
    final insets = ValueNotifier(EdgeInsets.zero);
    addTearDown(insets.dispose);

    await pumpLogin(tester, size: desktop, insets: insets);

    final email = _fieldByDecoration('Email');
    await tester.tap(email);
    await tester.pump();
    await tester.enterText(email, 'a');
    await tester.pump();

    insets.value = const EdgeInsets.only(bottom: 320);
    await tester.pumpAndSettle();

    expectEmailFieldTopInViewport(tester, desktop);
    expectDesktopCardCentered(tester, desktop);
    expectAuthShellFillsViewport(tester, desktop);
  });

  testWidgets(
      'desktop login: password focus + IME keeps email within viewport',
      (tester) async {
    const desktop = Size(1536, 864);
    final insets = ValueNotifier(EdgeInsets.zero);
    addTearDown(insets.dispose);

    await pumpLogin(tester, size: desktop, insets: insets);
    expect(find.byType(AuthPageShell), findsOneWidget);

    final password = _fieldByDecoration('Password');
    expect(password, findsOneWidget);
    await tester.tap(password);
    await tester.pump();

    insets.value = const EdgeInsets.only(bottom: 320);
    await tester.pumpAndSettle();

    expectEmailFieldTopInViewport(tester, desktop);
    expectDesktopCardCentered(tester, desktop);
    expectAuthShellFillsViewport(tester, desktop);
    final card = find.byType(AuthFormCard);
    expect(card, findsOneWidget);
    final cardTop =
        tester.renderObject<RenderBox>(card).localToGlobal(Offset.zero).dy;
    expect(cardTop, greaterThanOrEqualTo(-0.5));
  });

  testWidgets(
      'phone login: password focus + IME keeps email within viewport',
      (tester) async {
    const phone = Size(390, 844);
    final insets = ValueNotifier(EdgeInsets.zero);
    addTearDown(insets.dispose);

    await pumpLogin(tester, size: phone, insets: insets);

    final password = _fieldByDecoration('Password');
    expect(password, findsOneWidget);
    await tester.tap(password);
    await tester.pump();

    insets.value = const EdgeInsets.only(bottom: 300);
    await tester.pumpAndSettle();

    expectEmailFieldTopInViewport(tester, phone);
  });
}
