import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:harisree_warehouse/core/debug/hexa_debug_mq_banner.dart';
import 'package:harisree_warehouse/core/design_system/hexa_responsive.dart';
import 'package:harisree_warehouse/features/purchase/presentation/widgets/purchase_desktop_detail_pane.dart';
import 'package:harisree_warehouse/shared/widgets/hexa_empty_state.dart';

/// Phase 0 / UX-182: phone MQ must not show purchase master-detail.
void main() {
  testWidgets('Phase 0: mqW 390 → phone; 1280 → desktop (breakpoint proof)',
      (tester) async {
    late bool desktopAt390;
    late bool desktopAt1280;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              desktopAt390 = context.isDesktopLayout;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(desktopAt390, isFalse);
    expect(MediaQuery.sizeOf(tester.element(find.byType(SizedBox))).width, 390);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1280, 800)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              desktopAt1280 = context.isDesktopLayout;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(desktopAt1280, isTrue);
  });

  testWidgets('UX-182: 390 list-only; 1280 can show Select a purchase pane',
      (tester) async {
    Widget shell({required Size size, required bool desktop}) {
      return MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Same gate as purchase_home_page: isDesktopLayout && !selectMode
                final showMasterDetail =
                    context.isDesktopLayout && !false;
                expect(showMasterDetail, desktop);
                if (!showMasterDetail) {
                  return const Center(child: Text('history-list-only'));
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: Center(child: Text('history-list'))),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) {
                          return SizedBox(
                            width: c.maxWidth,
                            height: c.maxHeight,
                            child: const PurchaseDesktopDetailPane(
                              purchaseId: null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(shell(size: const Size(390, 844), desktop: false));
    await tester.pumpAndSettle();
    expect(find.text('history-list-only'), findsOneWidget);
    expect(find.text('Select a purchase'), findsNothing);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(shell(size: const Size(1280, 800), desktop: true));
    await tester.pumpAndSettle();
    expect(find.text('history-list'), findsOneWidget);
    expect(find.byType(HexaEmptyState), findsOneWidget);
    expect(find.text('Select a purchase'), findsOneWidget);
  });

  testWidgets('debug MQ banner shows mqW in kDebugMode', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: MaterialApp(
          home: HexaDebugMqBanner(
            child: Scaffold(body: Text('body')),
          ),
        ),
      ),
    );
    expect(find.textContaining('mqW 400'), findsOneWidget);
    expect(find.textContaining('PHONE'), findsOneWidget);
  });

  testWidgets('UX-179: desktop wizard frame height-binds Expanded child',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1280, 800)),
        child: MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (ctx, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;
                const maxW = HexaResponsive.maxHomeContentWidth;
                final frameW = w < maxW ? w : maxW;
                return SizedBox(
                  width: w,
                  height: h,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: frameW,
                      height: h,
                      child: Column(
                        children: [
                          const Text('chrome'),
                          Expanded(
                            child: Container(
                              key: const Key('wizard-expanded'),
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final box =
        tester.renderObject<RenderBox>(find.byKey(const Key('wizard-expanded')));
    expect(box.size.height, greaterThan(100));
  });

  testWidgets('UX-183: login layout gate — phone vs tablet+', (tester) async {
    late bool mobile390;
    late bool mobile1280;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              mobile390 = context.isMobileLayout;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(mobile390, isTrue);

    await tester.binding.setSurfaceSize(const Size(1280, 800));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1280, 800)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              mobile1280 = context.isMobileLayout;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(mobile1280, isFalse);
  });
}
