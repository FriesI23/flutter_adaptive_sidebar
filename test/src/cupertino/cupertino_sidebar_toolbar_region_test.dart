import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

const _region = CupertinoSidebarToolbarRegion(
  bounds: Rect.fromLTWH(0, 28, 525, 44),
  minimumExtent: 82,
  maxCollapsedBarWidth: 161,
);
const _branch = ValueKey('region-branch');
const _content = ValueKey('region-panel-content');
const _toggle = ValueKey('cupertino-sidebar-toggle');
const _capsule = ValueKey('cupertino-sidebar-collapsed-capsule');
const _placeholder = ValueKey('cupertino-sidebar-fixed-toolbar-placeholder');
const _surface = ValueKey('cupertino-sidebar-surface');

void _view(WidgetTester tester) {
  tester.view.physicalSize = const Size(669, 951);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 82, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 82, bottom: 34);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
}

Widget _host({
  required AdaptiveNavigationController controller,
  CupertinoSidebarToolbarRegion? region = _region,
  CupertinoSidebarStyle style = CupertinoSidebarStyle.liquid,
  TextDirection direction = TextDirection.ltr,
  bool hasBar = true,
  bool separator = false,
  SideNavigationExtent extent = const SideNavigationExtent(200),
  CupertinoSidebarCollapsedBarPlacement placement =
      CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
}) {
  final content = Stack(
    fit: StackFit.expand,
    children: [
      const SizedBox(key: _content, width: 1, height: 1),
      CupertinoSidebarNavigation(
        destinations: sidebarDestinations,
        selection: controller.selection,
        onSelectionChanged: controller.select,
      ),
    ],
  );
  final bar = hasBar
      ? CupertinoSidebarCollapsedBar(
          destinations: sidebarDestinations,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
        )
      : null;
  const branch = CupertinoPageScaffold(
    key: _branch,
    navigationBar: CupertinoNavigationBar(
      middle: CupertinoSidebarMiddle(title: Text('Title')),
    ),
    child: SizedBox.expand(),
  );
  final sidebar = style == CupertinoSidebarStyle.liquid
      ? CupertinoSidebar(
          controller: controller,
          toolbarRegion: region,
          extent: extent,
          collapsedBarPlacement: placement,
          collapsedBar: bar,
          collapsedBarSeparator: separator,
          content: content,
          child: branch,
        )
      : CupertinoSidebar.edge(
          controller: controller,
          toolbarRegion: region,
          extent: extent,
          collapsedBarPlacement: placement,
          collapsedBar: bar,
          collapsedBarSeparator: separator,
          content: content,
          child: branch,
        );
  return MaterialApp(
    home: Directionality(textDirection: direction, child: sidebar),
  );
}

SidebarLeadingScope _scope(WidgetTester tester) =>
    SidebarLeadingScope.maybeOf(tester.element(find.byKey(_branch)))!;

void _safeToggle(WidgetTester tester) {
  final rect = tester.getRect(find.byKey(_toggle));
  expect(rect.top, 28);
  expect(rect.bottom, 72);
  expect(rect.width, 44);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(525));
}

void main() {
  test('region values compare by all layout fields', () {
    expect(
      _region,
      const CupertinoSidebarToolbarRegion(
        bounds: Rect.fromLTWH(0, 28, 525, 44),
        minimumExtent: 82,
        maxCollapsedBarWidth: 161,
      ),
    );
    expect(
      _region,
      isNot(
        const CupertinoSidebarToolbarRegion(
          bounds: Rect.fromLTWH(0, 28, 525, 44),
          minimumExtent: 94,
          maxCollapsedBarWidth: 161,
        ),
      ),
    );
  });

  for (final style in CupertinoSidebarStyle.values) {
    for (final direction in TextDirection.values) {
      testWidgets('$style $direction uses a centered hard cap on first frame', (
        tester,
      ) async {
        _view(tester);
        final controller = AdaptiveNavigationController(initialExpanded: false);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _host(controller: controller, style: style, direction: direction),
        );
        expect(_scope(tester).toolbarRegion, _region);
        expect(tester.getSize(find.byKey(_placeholder)).width, 161);
        final capsule = tester.getRect(find.byKey(_capsule));
        expect(capsule.width, 161);
        expect(capsule.center, const Offset(334.5, 50));
        expect(capsule.right, lessThanOrEqualTo(525));
        final media = MediaQuery.of(tester.element(find.byKey(_branch)));
        expect(media.padding.top, 82);
        expect(media.viewPadding.top, 82);
        expect(media.padding.right, 0);
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        '$style $direction separates surface and content protection',
        (tester) async {
          _view(tester);
          final controller = AdaptiveNavigationController();
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            _host(controller: controller, style: style, direction: direction),
          );
          await tester.pumpAndSettle();
          expect(_scope(tester).toolbarRegion, _region);
          expect(
            tester.getTopLeft(find.byKey(_surface)).dy,
            style == CupertinoSidebarStyle.liquid ? 28 : 0,
          );
          expect(tester.getTopLeft(find.byKey(_content)).dy, 82);
          expect(
            tester
                .getTopLeft(
                  find.byKey(const ValueKey('cupertino-sidebar-destination-0')),
                )
                .dy,
            150,
          );
          _safeToggle(tester);
          expect(find.byKey(_toggle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        '$style $direction keeps acceptance throughout open and close',
        (tester) async {
          _view(tester);
          final controller = AdaptiveNavigationController(
            initialExpanded: false,
          );
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            _host(controller: controller, style: style, direction: direction),
          );
          await tester.pumpAndSettle();
          final focus = tester
              .widget<CupertinoButton>(find.byKey(_toggle))
              .focusNode;
          for (final expanded in [true, false]) {
            controller.expanded = expanded;
            for (var frame = 0; frame < 32; frame++) {
              await tester.pump(const Duration(milliseconds: 16));
              expect(_scope(tester).toolbarRegion, _region);
              _safeToggle(tester);
              expect(find.byKey(_toggle), findsOneWidget);
              expect(
                tester.widget<CupertinoButton>(find.byKey(_toggle)).focusNode,
                same(focus),
              );
              expect(tester.getRect(find.byKey(_capsule)).center.dx, 334.5);
            }
          }
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        '$style $direction positions a standalone hidden toggle safely',
        (tester) async {
          _view(tester);
          final controller = AdaptiveNavigationController(
            initialExpanded: false,
          );
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            _host(
              controller: controller,
              style: style,
              direction: direction,
              hasBar: false,
            ),
          );
          _safeToggle(tester);
          expect(_scope(tester).toolbarRegion, _region);
          expect(_scope(tester).reservedExtent, 44);
          expect(find.byKey(_capsule), findsNothing);
          expect(
            MediaQuery.of(tester.element(find.byKey(_branch))).padding.top,
            82,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('RTL expanded toggle clamps inside a 48.42-point intersection', (
    tester,
  ) async {
    _view(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        controller: controller,
        style: CupertinoSidebarStyle.liquidEdge,
        direction: TextDirection.rtl,
      ),
    );
    final panel = tester.getRect(find.byKey(_surface));
    final toggle = tester.getRect(find.byKey(_toggle));
    expect(panel.width, closeTo(192.42, 0.001));
    expect(toggle.left, closeTo(481, 0.001));
    expect(toggle.left, greaterThanOrEqualTo(panel.left));
    expect(toggle.right, 525);
    expect(toggle.right, lessThanOrEqualTo(525));
    expect(_scope(tester).toolbarRegion, _region);
  });

  testWidgets(
    'a 36-point expanded intersection rejects every animation state',
    (tester) async {
      _view(tester);
      final controller = AdaptiveNavigationController(initialExpanded: false);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          controller: controller,
          style: CupertinoSidebarStyle.liquidEdge,
          direction: TextDirection.rtl,
          extent: const SideNavigationExtent(180),
        ),
      );
      expect(_scope(tester).toolbarRegion, isNull);
      expect(tester.getRect(find.byKey(_capsule)).top, 82);
      controller.expanded = true;
      for (var frame = 0; frame < 32; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(_scope(tester).toolbarRegion, isNull);
        expect(tester.getRect(find.byKey(_toggle)).top, 82);
      }
      expect(tester.takeException(), isNull);
    },
  );

  for (final invalid in <String, CupertinoSidebarToolbarRegion?>{
    'null': null,
    'empty': const CupertinoSidebarToolbarRegion(
      bounds: Rect.zero,
      minimumExtent: 82,
    ),
    'outside host': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 670, 44),
      minimumExtent: 82,
    ),
    'nonfinite': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(double.nan, 28, 525, 44),
      minimumExtent: 82,
    ),
    'short row': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 525, 43),
      minimumExtent: 82,
    ),
    'short protection': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 525, 44),
      minimumExtent: 71,
    ),
    'nonfinite protection': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 525, 44),
      minimumExtent: double.infinity,
    ),
    'small hard cap': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 525, 44),
      minimumExtent: 82,
      maxCollapsedBarWidth: 131,
    ),
    'nonfinite cap': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 525, 44),
      minimumExtent: 82,
      maxCollapsedBarWidth: double.infinity,
    ),
    'window center outside': const CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 300, 44),
      minimumExtent: 82,
    ),
  }.entries) {
    testWidgets(
      '${invalid.key} region preserves the complete original layout',
      (tester) async {
        _view(tester);
        final controller = AdaptiveNavigationController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _host(controller: controller, region: invalid.value),
        );
        await tester.pumpAndSettle();
        expect(_scope(tester).toolbarRegion, isNull);
        expect(tester.getRect(find.byKey(_toggle)).top, 82);
        expect(tester.getTopLeft(find.byKey(_surface)).dy, 82);
        expect(tester.getTopLeft(find.byKey(_content)).dy, 82);
        expect(
          MediaQuery.of(tester.element(find.byKey(_branch))).padding.top,
          82,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('separator width participates in the minimum capsule budget', (
    tester,
  ) async {
    _view(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    const narrow = CupertinoSidebarToolbarRegion(
      bounds: Rect.fromLTWH(0, 28, 525, 44),
      minimumExtent: 82,
      maxCollapsedBarWidth: 132,
    );
    await tester.pumpWidget(_host(controller: controller, region: narrow));
    expect(_scope(tester).toolbarRegion?.maxCollapsedBarWidth, 132);
    await tester.pumpWidget(
      _host(controller: controller, region: narrow, separator: true),
    );
    expect(_scope(tester).toolbarRegion, isNull);
    expect(tester.getRect(find.byKey(_capsule)).top, 82);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toolbar anchors retain their page-owned positioning', (
    tester,
  ) async {
    _view(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        controller: controller,
        placement: CupertinoSidebarCollapsedBarPlacement.toolbarAnchor,
      ),
    );
    await tester.pumpAndSettle();
    expect(_scope(tester).toolbarRegion, isNull);
    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    expect(tester.getRect(find.byKey(_toggle)).top, 82);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'removing a region immediately restores the original protection',
    (tester) async {
      _view(tester);
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_host(controller: controller));
      expect(_scope(tester).toolbarRegion, _region);
      expect(tester.getTopLeft(find.byKey(_surface)).dy, 28);
      await tester.pumpWidget(_host(controller: controller, region: null));
      expect(_scope(tester).toolbarRegion, isNull);
      expect(tester.getRect(find.byKey(_toggle)).top, 82);
      expect(tester.getTopLeft(find.byKey(_surface)).dy, 82);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'minimum extent protects panel content beyond the original inset',
    (tester) async {
      _view(tester);
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);
      const larger = CupertinoSidebarToolbarRegion(
        bounds: Rect.fromLTWH(0, 50, 525, 44),
        minimumExtent: 94,
        maxCollapsedBarWidth: 161,
      );
      for (final style in CupertinoSidebarStyle.values) {
        await tester.pumpWidget(
          _host(controller: controller, region: larger, style: style),
        );
        expect(tester.getRect(find.byKey(_toggle)).top, 50);
        expect(tester.getTopLeft(find.byKey(_content)).dy, 94);
        expect(
          MediaQuery.of(tester.element(find.byKey(_branch))).padding.top,
          82,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the current hard cap replaces old measured sizes on the first frame',
    (tester) async {
      _view(tester);
      final controller = AdaptiveNavigationController(initialExpanded: false);
      addTearDown(controller.dispose);
      const roomy = CupertinoSidebarToolbarRegion(
        bounds: Rect.fromLTWH(0, 28, 525, 44),
        minimumExtent: 82,
      );
      await tester.pumpWidget(_host(controller: controller, region: roomy));
      await tester.pumpAndSettle();
      expect(_scope(tester).toolbarRegion?.maxCollapsedBarWidth, 381);
      expect(tester.getSize(find.byKey(_placeholder)).width, 381);
      await tester.pumpWidget(_host(controller: controller));
      expect(tester.getSize(find.byKey(_placeholder)).width, 161);
      expect(tester.getRect(find.byKey(_capsule)).width, 161);
      expect(tester.getRect(find.byKey(_capsule)).center.dx, 334.5);
      expect(tester.takeException(), isNull);
    },
  );
}
