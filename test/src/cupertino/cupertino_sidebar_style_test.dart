import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_adaptive_sidebar/src/cupertino/cupertino_floating_surface.dart';
import 'package:flutter_adaptive_sidebar/src/cupertino/cupertino_sidebar_chrome.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('liquid keeps the inset rounded surface', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await _pumpStyle(tester, controller: controller);

    final panel = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
    );
    expect(panel.left, 10);
    expect(panel.top, 10);

    final surface = tester.widget<CupertinoFloatingGlassSurface>(
      find.byKey(const ValueKey('cupertino-sidebar-surface')),
    );
    expect(surface.borderRadius, const BorderRadius.all(Radius.circular(25)));
    expect(surface.blurSigma, CupertinoSidebarChrome.liquid.blurSigma);
    expect(surface.boxShadow, CupertinoSidebarChrome.liquid.boxShadow);
    expect(surface.border, isNull);

    final branch = tester.widget<Padding>(
      find.byKey(const ValueKey('cupertino-sidebar-branch-safe-span')),
    );
    expect(
      branch.padding,
      const EdgeInsetsDirectional.only(start: 10 + 200 + 12),
    );
  });

  testWidgets('liquid dark mode draws the preset hairline', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        home: CupertinoSidebar(
          controller: controller,
          content: const SizedBox.expand(),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final border = tester
        .widget<CupertinoFloatingGlassSurface>(
          find.byKey(const ValueKey('cupertino-sidebar-surface')),
        )
        .border;
    if (border is Border) {
      expect(border.top.width, 0.5);
    } else {
      fail('liquid dark mode draws a uniform hairline');
    }
  });

  testWidgets('liquid does not raise the theme bar opacity', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const barBackground = Color(0x0FFFFFFF);

    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
          barBackgroundColor: barBackground,
        ),
        home: CupertinoSidebar(
          controller: controller,
          content: const SizedBox.expand(),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final surfaceColor = tester
        .widgetList<ColoredBox>(
          find.descendant(
            of: find.byKey(const ValueKey('cupertino-sidebar-surface')),
            matching: find.byType(ColoredBox),
          ),
        )
        .first
        .color;
    expect(surfaceColor, barBackground);
  });

  testWidgets('liquidEdge is flush and separates the page at the panel edge', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await _pumpStyle(
      tester,
      controller: controller,
      style: CupertinoSidebarStyle.liquidEdge,
    );

    final panel = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
    );
    expect(panel.left, 0);
    expect(panel.top, 0);
    expect(panel.right, 200);
    expect(panel.bottom, 800);

    final surface = tester.widget<CupertinoFloatingGlassSurface>(
      find.byKey(const ValueKey('cupertino-sidebar-surface')),
    );
    expect(surface.borderRadius, BorderRadius.zero);
    expect(surface.boxShadow, isEmpty);
    final border = surface.border;
    if (border is BorderDirectional) {
      final separator = CupertinoDynamicColor.resolve(
        CupertinoColors.separator,
        tester.element(find.byKey(const ValueKey('cupertino-sidebar-surface'))),
      );
      expect(border.end.color, separator);
      expect(border.end.width, 0.5);
      expect(border.start, BorderSide.none);
    } else {
      fail('liquidEdge draws a separator on the inner edge');
    }

    final shadows = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .expand((decoration) => decoration.boxShadow ?? const <BoxShadow>[]);
    expect(shadows, isEmpty);

    final branch = tester.widget<Padding>(
      find.byKey(const ValueKey('cupertino-sidebar-branch-safe-span')),
    );
    expect(branch.padding, const EdgeInsetsDirectional.only(start: 200));
    expect(tester.getTopLeft(find.text('Body')).dx, 200);

    final handle = tester.element(
      find.byKey(const ValueKey('cupertino-sidebar-resize-handle')),
    );
    final positioned = handle
        .findAncestorWidgetOfExactType<PositionedDirectional>();
    if (positioned == null) {
      fail('resize handle is positioned');
    }
    expect(positioned.top, 0);
    expect(positioned.bottom, 0);
  });

  testWidgets('liquidEdge keeps the toggle and content in the safe area', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 34, left: 12);
    tester.view.viewPadding = const FakeViewPadding(
      top: 47,
      bottom: 34,
      left: 12,
    );
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await _pumpStyle(
      tester,
      controller: controller,
      style: CupertinoSidebarStyle.liquidEdge,
      content: const Align(
        alignment: Alignment.topLeft,
        child: Text('Edge row'),
      ),
    );

    final panel = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
    );
    expect(panel.topLeft, Offset.zero);
    expect(tester.getTopLeft(find.text('Edge row')), const Offset(12, 47));
    expect(
      tester
          .getRect(find.byKey(const ValueKey('cupertino-sidebar-toggle')))
          .top,
      47,
    );
    expect(tester.getTopLeft(find.text('Body')).dx, 200);
  });

  testWidgets('liquidEdge fill matches the iPadOS 27 neutral background', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    Future<void> pump(Brightness brightness) {
      return tester.pumpWidget(
        CupertinoApp(
          theme: CupertinoThemeData(brightness: brightness),
          home: CupertinoSidebar(
            controller: controller,
            style: CupertinoSidebarStyle.liquidEdge,
            content: const SizedBox.expand(),
            child: const SizedBox.expand(),
          ),
        ),
      );
    }

    Future<Color> expectEdgeFill({
      required Color backdrop,
      required int argb,
    }) async {
      final surface = find.byKey(const ValueKey('cupertino-sidebar-surface'));
      final context = tester.element(surface);
      final expected = CupertinoSidebarChrome.liquidEdge.fill.resolve(context);
      final color = tester
          .widget<ColoredBox>(
            find.descendant(of: surface, matching: find.byType(ColoredBox)),
          )
          .color;
      expect(color, expected);
      expect(color.a, closeTo(kCupertinoSidebarEdgeFillAlpha, 0.001));
      expect(Color.alphaBlend(color, backdrop).toARGB32(), argb);
      expect(
        find.descendant(of: surface, matching: find.byType(BackdropFilter)),
        findsOneWidget,
      );
      return color;
    }

    await pump(Brightness.light);
    final light = await expectEdgeFill(
      backdrop: CupertinoColors.white,
      argb: 0xFFE6EAEE,
    );

    await pump(Brightness.dark);
    final dark = await expectEdgeFill(
      backdrop: CupertinoColors.black,
      argb: 0xFF181D20,
    );
    expect(dark, isNot(light));
  });

  testWidgets('liquidEdge theme tint keeps the package glass opacity', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const sourceColor = Color(0xFF123456);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [
            CupertinoSidebarThemeData(edgeBackgroundColor: sourceColor),
          ],
        ),
        home: CupertinoSidebar.edge(
          controller: controller,
          content: const SizedBox.expand(),
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(
      _surfaceColor(tester),
      sourceColor.withValues(alpha: kCupertinoSidebarEdgeFillAlpha),
    );
  });

  testWidgets('sidebar backgroundColor keeps a plain color unchanged', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const backgroundColor = Color(0xFF123456);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [
            CupertinoSidebarThemeData(edgeBackgroundColor: Color(0xFFABCDEF)),
          ],
        ),
        home: CupertinoSidebar.edge(
          controller: controller,
          backgroundColor: backgroundColor,
          content: const SizedBox.expand(),
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(_surfaceColor(tester), backgroundColor);
    expect(_surfaceBackdropFilters(), findsNothing);
  });

  testWidgets('sidebar backgroundColor resolves Cupertino dynamic colors', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const backgroundColor = CupertinoDynamicColor.withBrightness(
      color: Color(0x80123456),
      darkColor: Color(0x80654321),
    );

    Future<void> pump(Brightness brightness) {
      return tester.pumpWidget(
        CupertinoApp(
          theme: CupertinoThemeData(brightness: brightness),
          home: CupertinoSidebar.edge(
            controller: controller,
            backgroundColor: backgroundColor,
            content: const SizedBox.expand(),
            child: const SizedBox.expand(),
          ),
        ),
      );
    }

    await pump(Brightness.light);
    expect(_surfaceColor(tester).toARGB32(), 0x80123456);
    expect(_surfaceBackdropFilters(), findsOneWidget);

    await pump(Brightness.dark);
    expect(_surfaceColor(tester).toARGB32(), 0x80654321);
    expect(_surfaceBackdropFilters(), findsOneWidget);
  });
}

Finder _surfaceBackdropFilters() {
  return find.descendant(
    of: find.byKey(const ValueKey('cupertino-sidebar-surface')),
    matching: find.byType(BackdropFilter),
  );
}

Color _surfaceColor(WidgetTester tester) {
  return tester
      .widget<ColoredBox>(
        find.descendant(
          of: find.byKey(const ValueKey('cupertino-sidebar-surface')),
          matching: find.byType(ColoredBox),
        ),
      )
      .color;
}

Future<void> _pumpStyle(
  WidgetTester tester, {
  required AdaptiveNavigationController controller,
  CupertinoSidebarStyle style = CupertinoSidebarStyle.liquid,
  Widget content = const SizedBox.expand(),
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: CupertinoSidebar(
        controller: controller,
        style: style,
        content: content,
        child: const SizedBox.expand(child: Text('Body')),
      ),
    ),
  );
}
