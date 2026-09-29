import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_adaptive_sidebar/src/cupertino/cupertino_floating_surface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tap outside the material rail clears destination focus', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('material-rail-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.text('Body'));
    await tester.pump();

    expect(_focusNode(tester, destination).hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets('tap outside the cupertino panel clears destination focus', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('cupertino-sidebar-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.text('Body'));
    await tester.pump();

    expect(_focusNode(tester, destination).hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets(
    'tap outside clears the retained theme-colored edge interaction',
    (tester) async {
      useLargeTestWindow(tester);
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);
      await pumpSidebar(
        tester,
        controller: controller,
        cupertino: true,
        cupertinoStyle: CupertinoSidebarStyle.liquidEdge,
      );
      await tester.pumpAndSettle();

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-destination-0'),
      );
      await tester.tap(destination);
      await tester.pumpAndSettle();

      expect(controller.selection, const SidebarPrimarySelection(0));
      expect(_focusNode(tester, destination).hasFocus, isTrue);
      final primaryColor = CupertinoTheme.of(
        tester.element(destination),
      ).primaryColor;
      expect(
        _destinationFill(tester, destination),
        primaryColor.withValues(alpha: 1),
      );

      await tester.tap(find.text('Body'));
      await tester.pumpAndSettle();

      expect(_focusNode(tester, destination).hasFocus, isFalse);
      expect(
        _destinationFill(tester, destination),
        primaryColor.withValues(alpha: 0.14),
      );
      expect(controller.selection, const SidebarPrimarySelection(0));
    },
  );

  testWidgets('tab reaches cupertino destinations on macOS', (tester) async {
    useLargeTestWindow(tester);
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);
      await pumpSidebar(tester, controller: controller, cupertino: true);
      await tester.pumpAndSettle();

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-destination-0'),
      );
      var reachedDestination = false;
      for (var index = 0; index < 5; index += 1) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        if (_focusNode(tester, destination).hasFocus) {
          reachedDestination = true;
          break;
        }
      }

      expect(reachedDestination, isTrue);
      final shape =
          _nativeHaloDecoration(tester, destination).shape
              as RoundedSuperellipseBorder;
      expect(shape.side.style, BorderStyle.solid);
      expect(shape.side.strokeAlign, BorderSide.strokeAlignInside);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('iOS inset destination uses a focused capsule without a halo', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    try {
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);
      await pumpSidebar(tester, controller: controller, cupertino: true);
      await tester.pumpAndSettle();

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-destination-0'),
      );
      final node = _focusNode(tester, destination);
      node.requestFocus();
      await tester.pump();

      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: destination,
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as ShapeDecoration;
      expect(decoration.color, isNotNull);
      expect(
        (decoration.shape as RoundedSuperellipseBorder).side.style,
        BorderStyle.none,
      );
    } finally {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('theme overrides macOS halo but not the iOS highlight', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    var buildCount = 0;
    final theme = ThemeData(
      extensions: [
        CupertinoSidebarThemeData(
          focusHaloBuilder:
              (
                context, {
                required child,
                required visible,
                required decoration,
              }) {
                buildCount += 1;
                return DecoratedBox(
                  key: ValueKey('app-sidebar-halo-$visible'),
                  decoration: decoration,
                  child: child,
                );
              },
        ),
      ],
    );

    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: sidebarHost(controller: controller, cupertino: true),
        ),
      );
      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-destination-0'),
      );
      _focusNode(tester, destination).requestFocus();
      await tester.pump();
      expect(
        find.byKey(const ValueKey('app-sidebar-halo-true')),
        findsOneWidget,
      );
      final macBuildCount = buildCount;

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: sidebarHost(controller: controller, cupertino: true),
        ),
      );
      await tester.pump();
      expect(buildCount, macBuildCount);
      expect(find.byKey(const ValueKey('app-sidebar-halo-true')), findsNothing);
    } finally {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('tap outside the collapsed bar clears destination focus', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return CupertinoSidebar(
              controller: controller,
              content: const SizedBox.shrink(),
              collapsedBar: CupertinoSidebarCollapsedBar(
                destinations: sidebarDestinations,
                selectedIndex: controller.selection.primaryIndex,
                onDestinationSelected: (index) =>
                    controller.select(SidebarPrimarySelection(index)),
              ),
              child: const CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: CupertinoSidebarMiddle(title: Text('Title')),
                ),
                child: Text('Body'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.text('Body'));
    await tester.pump();

    expect(_focusNode(tester, destination).hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets('collapsed destination uses Flutter native halo on macOS', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: CupertinoSidebarCollapsedBar(
              destinations: sidebarDestinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-destination-0'),
      );
      final node = _focusNode(tester, destination);
      node.requestFocus();
      await tester.pump();

      final shape =
          _nativeHaloDecoration(tester, destination).shape
              as RoundedSuperellipseBorder;
      expect(shape.side.style, BorderStyle.solid);
      expect(shape.side.strokeAlign, BorderSide.strokeAlignInside);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('macOS expanded native halo paints all four straight edges', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    try {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(primaryColor: Color(0xFF00FF00)),
          home: Center(
            child: RepaintBoundary(
              key: const ValueKey('focus-pixel-boundary'),
              child: ColoredBox(
                color: const Color(0xFF101010),
                child: SizedBox(
                  width: 320,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CupertinoSidebarDestination(
                      key: const ValueKey('focus-pixel-expanded-destination'),
                      destination: sidebarDestinations.first,
                      selected: false,
                      onPressed: _noop,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final destination = find.byKey(
        const ValueKey('focus-pixel-expanded-destination'),
      );
      final surface = find.descendant(
        of: destination,
        matching: find.byType(CupertinoFocusHalo),
      );
      await _expectFourVisibleHaloEdges(tester, destination, surface);
    } finally {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('macOS collapsed native halo paints all four straight edges', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    try {
      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(primaryColor: Color(0xFF00FF00)),
          home: Center(
            child: RepaintBoundary(
              key: const ValueKey('focus-pixel-boundary'),
              child: ColoredBox(
                color: const Color(0xFF101010),
                child: SizedBox(
                  width: 220,
                  height: 90,
                  child: Center(
                    child: CupertinoFloatingGlassSurface(
                      backgroundColor: const Color(0xFF202020),
                      borderRadius: BorderRadius.circular(24),
                      clipContent: false,
                      child: CupertinoSidebarCollapsedBar(
                        destinations: sidebarDestinations.sublist(0, 1),
                        selectedIndex: null,
                        minimumDestinationExtent: 120,
                        onDestinationSelected: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-destination-0'),
      );
      final surface = find.descendant(
        of: destination,
        matching: find.byType(CupertinoFocusHalo),
      );
      await _expectFourVisibleHaloEdges(tester, destination, surface);
    } finally {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('collapsed destination uses a focused segment on iOS', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    try {
      const focusedColor = Color(0xFF123456);
      final itemStyle = CupertinoSidebarItemStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? focusedColor
              : const Color(0x22123456),
        ),
      );
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: CupertinoSidebarCollapsedBar(
              destinations: sidebarDestinations,
              selectedIndex: 0,
              itemStyle: itemStyle,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-destination-0'),
      );
      final node = _focusNode(tester, destination);
      node.requestFocus();
      await tester.pump();

      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.descendant(
                            of: destination,
                            matching: find.byKey(
                              const ValueKey(
                                'cupertino-sidebar-collapsed-focus-surface',
                              ),
                            ),
                          ),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as ShapeDecoration;
      expect(decoration.color, focusedColor);
      expect(
        (decoration.shape as RoundedSuperellipseBorder).side.style,
        BorderStyle.none,
      );
    } finally {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('a focused page field is not cleared by the sidebar', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: false,
      body: const Material(child: TextField(key: ValueKey('page-field'))),
    );
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('material-rail-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    final destinationFocus = _focusNode(tester, destination);

    await tester.tap(find.byKey(const ValueKey('page-field')));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
    expect(destinationFocus.hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });
}

Future<void> _selectAndFocus(WidgetTester tester, Finder destination) async {
  await tester.tap(destination);
  await tester.pumpAndSettle();
  final node = _focusNode(tester, destination);
  node.requestFocus();
  await tester.pump();
  expect(node.hasFocus, isTrue);
}

FocusNode _focusNode(WidgetTester tester, Finder destination) {
  final collapsedSurface = find.descendant(
    of: destination,
    matching: find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-focus-surface'),
    ),
  );
  if (collapsedSurface.evaluate().isNotEmpty) {
    return Focus.of(tester.element(collapsedSurface.first));
  }
  final text = find.descendant(of: destination, matching: find.byType(Text));
  expect(text, findsWidgets);
  return Focus.of(tester.element(text.first));
}

Color _destinationFill(WidgetTester tester, Finder destination) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: destination, matching: find.byType(DecoratedBox)),
  );
  return switch (box.decoration) {
    final BoxDecoration decoration => decoration.color!,
    final ShapeDecoration decoration => decoration.color!,
    _ => throw StateError('Unsupported destination decoration'),
  };
}

void _noop() {}

ShapeDecoration _nativeHaloDecoration(WidgetTester tester, Finder destination) {
  final halo = find.descendant(
    of: destination,
    matching: find.byType(CupertinoFocusHalo),
  );
  expect(halo, findsOneWidget);
  final boxes = find.descendant(of: halo, matching: find.byType(DecoratedBox));
  final foreground = tester
      .widgetList<DecoratedBox>(boxes)
      .singleWhere((box) => box.position == DecorationPosition.foreground);
  return foreground.decoration as ShapeDecoration;
}

Future<void> _expectFourVisibleHaloEdges(
  WidgetTester tester,
  Finder destination,
  Finder surface,
) async {
  final boundary = find.byKey(const ValueKey('focus-pixel-boundary'));
  final boundaryRect = tester.getRect(boundary);
  final surfaceRect = tester.getRect(surface).shift(-boundaryRect.topLeft);
  final before = await _captureRgba(tester, boundary);

  _focusNode(tester, destination).requestFocus();
  await tester.pump();

  final after = await _captureRgba(tester, boundary);
  final points = [
    Offset(surfaceRect.center.dx, surfaceRect.top + 2),
    Offset(surfaceRect.center.dx, surfaceRect.bottom - 2),
    Offset(surfaceRect.left + 2, surfaceRect.center.dy),
    Offset(surfaceRect.right - 2, surfaceRect.center.dy),
  ];
  for (final point in points) {
    expect(
      after.pixelAt(point),
      isNot(before.pixelAt(point)),
      reason: 'The native focus halo must paint at $point inside $surfaceRect.',
    );
  }
}

Future<_RgbaCapture> _captureRgba(
  WidgetTester tester,
  Finder boundaryFinder,
) async => (await tester.runAsync(() async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(boundaryFinder);
  final image = await boundary.toImage(pixelRatio: 1);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final capture = _RgbaCapture(image.width, image.height, bytes!);
  image.dispose();
  return capture;
}))!;

class _RgbaCapture {
  const _RgbaCapture(this.width, this.height, this.bytes);

  final int width;
  final int height;
  final ByteData bytes;

  int pixelAt(Offset point) {
    final x = point.dx.round();
    final y = point.dy.round();
    expect(x, inInclusiveRange(0, width - 1));
    expect(y, inInclusiveRange(0, height - 1));
    return bytes.getUint32((y * width + x) * 4, Endian.big);
  }
}
