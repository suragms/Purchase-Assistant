import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harisree_warehouse/shared/widgets/app_settings_action.dart';

void main() {
  testWidgets('AppSettingsAction menu exposes Help & guide', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            appBar: AppBar(actions: const [AppSettingsAction()]),
            body: const SizedBox.shrink(),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const Scaffold(body: Text('settings-page')),
        ),
        GoRoute(
          path: '/settings/help',
          builder: (_, __) => const Scaffold(body: Text('help-page')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byTooltip('Settings & help'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Help & guide'), findsOneWidget);

    await tester.tap(find.text('Help & guide'));
    await tester.pumpAndSettle();
    expect(find.text('help-page'), findsOneWidget);
  });
}
