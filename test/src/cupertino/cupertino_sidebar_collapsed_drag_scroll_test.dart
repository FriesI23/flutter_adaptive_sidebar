import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _capsuleKey = ValueKey('cupertino-sidebar-collapsed-capsule');
const _toggleKey = ValueKey('cupertino-sidebar-toggle');
const _highlightKey = ValueKey(
  'cupertino-sidebar-collapsed-selection-highlight',
);

Finder _destination(int index) =>
    find.byKey(ValueKey('cupertino-sidebar-collapsed-destination-$index'));

class _BarHarness {
  _BarHarness({
    required this.tester,
    required this.controller,
    required this.direction,
    required this.selections,
  });

  final WidgetTester tester;
  final AdaptiveNavigationController controller;
  final TextDirection direction;
  final List<int> selections;

  Finder get viewportFinder => find.descendant(
    of: find.byKey(_capsuleKey),
    matching: find.byType(Scrollable),
  );

  ScrollPosition get position =>
      tester.state<ScrollableState>(viewportFinder).position;

  Rect get viewport => tester.getRect(viewportFinder);

  Rect get toggle => tester.getRect(find.byKey(_toggleKey));

  Rect get highlight => tester.getRect(find.byKey(_highlightKey));

  double get forwardSign => direction == TextDirection.ltr ? 1 : -1;

  Offset edge({bool forward = true, double inset = 1}) {
    final goesRight = (direction == TextDirection.ltr) == forward;
    return Offset(
      goesRight ? viewport.right - inset : viewport.left + inset,
      viewport.center.dy,
    );
  }

  void expectSelection(int index) {
    expect(controller.selection.primaryIndex, index);
  }

  void expectPinned(Rect original) {
    expect(toggle, original);
    expect(find.byKey(_toggleKey).hitTestable(), findsOneWidget);
  }

  void expectNoErrors() => expect(tester.takeException(), isNull);
}

Future<_BarHarness> _pumpBar(
  WidgetTester tester, {
  TextDirection direction = TextDirection.ltr,
  int destinationCount = 8,
  double maximumWidth = 161,
  ValueNotifier<double>? maximumWidthListenable,
  double destinationExtent = 80,
}) async {
  tester.view.physicalSize = const Size(669, 951);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 82, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 82, bottom: 34);
  addTearDown(tester.view.reset);
  final controller = AdaptiveNavigationController(initialExpanded: false);
  addTearDown(controller.dispose);
  final selections = <int>[];
  final destinations = [
    for (var index = 0; index < destinationCount; index++)
      AdaptiveNavigationDestination(
        label: '$index',
        icons: const NavigationDestinationIcons(
          material: Icon(Icons.home_outlined),
          materialSelected: Icon(Icons.home),
          cupertino: Icon(CupertinoIcons.house),
          cupertinoSelected: Icon(CupertinoIcons.house_fill),
        ),
      ),
  ];
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: ListenableBuilder(
          listenable: Listenable.merge([controller, ?maximumWidthListenable]),
          builder: (context, _) => CupertinoSidebar(
            controller: controller,
            toolbarRegion: CupertinoSidebarToolbarRegion(
              bounds: const Rect.fromLTWH(0, 28, 525, 44),
              minimumExtent: 82,
              maxCollapsedBarWidth:
                  maximumWidthListenable?.value ?? maximumWidth,
            ),
            collapsedBarPlacement:
                CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
            collapsedBar: CupertinoSidebarCollapsedBar(
              destinations: destinations,
              minimumDestinationExtent: destinationExtent,
              selectedIndex: controller.selection.primaryIndex,
              onDestinationSelected: (index) {
                selections.add(index);
                controller.select(SidebarPrimarySelection(index));
              },
            ),
            content: const SizedBox.expand(),
            child: const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: CupertinoSidebarMiddle(title: Text('Title')),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final harness = _BarHarness(
    tester: tester,
    controller: controller,
    direction: direction,
    selections: selections,
  );
  final naturalWidth = 52.0 + destinationCount * destinationExtent;
  final cap = maximumWidthListenable?.value ?? maximumWidth;
  final expectedWidth = naturalWidth < cap ? naturalWidth : cap;
  expect(tester.getSize(find.byKey(_capsuleKey)).width, expectedWidth);
  expect(harness.viewport.width, expectedWidth - 52);
  harness.expectSelection(0);
  harness.expectNoErrors();
  return harness;
}

Future<void> _pumpUntil(
  _BarHarness harness,
  bool Function() predicate, {
  required String reason,
}) async {
  for (var frame = 0; frame < 500 && !predicate(); frame++) {
    await harness.tester.pump(const Duration(milliseconds: 16));
    harness.expectNoErrors();
    expect(
      harness.position.pixels,
      inInclusiveRange(0, harness.position.maxScrollExtent),
    );
  }
  expect(predicate(), isTrue, reason: reason);
}

Future<void> _expectStopped(_BarHarness harness) async {
  final offset = harness.position.pixels;
  await harness.tester.pump(const Duration(milliseconds: 300));
  await harness.tester.pump(const Duration(milliseconds: 300));
  expect(harness.position.pixels, closeTo(offset, 0.001));
  harness.expectNoErrors();
}

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('$direction thumb reveals the obscured second tab on hold', (
      tester,
    ) async {
      final harness = await _pumpBar(
        tester,
        direction: direction,
        destinationCount: 2,
      );
      final pinned = harness.toggle;
      final second = _destination(1);
      expect(harness.viewport.contains(tester.getCenter(second)), isFalse);
      final gesture = await tester.startGesture(
        tester.getCenter(_destination(0)),
      );
      await gesture.moveTo(harness.edge());
      await tester.pump();
      await _pumpUntil(
        harness,
        () =>
            harness.position.pixels > 0 &&
            harness.viewport.contains(tester.getCenter(second)),
        reason: 'a stationary edge drag must reveal the second tab',
      );
      harness.expectSelection(0);
      expect(harness.selections, isEmpty);
      expect(
        harness.highlight
            .intersect(harness.viewport)
            .overlaps(tester.getRect(second).intersect(harness.viewport)),
        isTrue,
      );
      harness.expectPinned(pinned);

      await gesture.up();
      await tester.pumpAndSettle();
      harness.expectSelection(1);
      expect(harness.selections, [1]);
      expect(
        harness.highlight.center.dx,
        closeTo(tester.getCenter(second).dx, 1),
      );
      await _expectStopped(harness);
      harness.expectPinned(pinned);
    });

    testWidgets('$direction edge hold reaches the last tab and cancel stops', (
      tester,
    ) async {
      final harness = await _pumpBar(tester, direction: direction);
      final pinned = harness.toggle;
      final edge = harness.edge();
      final gesture = await tester.startGesture(
        tester.getCenter(_destination(0)),
      );
      await gesture.moveTo(edge);
      await tester.pump();
      await _pumpUntil(
        harness,
        () => harness.position.pixels >= 24,
        reason: 'holding the edge must keep scrolling without pointer updates',
      );
      harness.expectSelection(0);
      expect(harness.selections, isEmpty);
      expect(harness.highlight.center.dx, closeTo(edge.dx, 2));
      harness.expectPinned(pinned);
      await _pumpUntil(
        harness,
        () =>
            (harness.position.maxScrollExtent - harness.position.pixels).abs() <
            0.001,
        reason: 'the same held pointer must reach destinations beyond the next',
      );
      expect(
        harness.viewport.contains(tester.getCenter(_destination(7))),
        isTrue,
      );
      harness.expectSelection(0);
      expect(harness.selections, isEmpty);
      await gesture.up();
      await tester.pumpAndSettle();
      harness.expectSelection(7);
      expect(harness.selections, [7]);
      await _expectStopped(harness);

      final farOffset = harness.position.pixels;
      final reverse = await tester.startGesture(
        tester.getCenter(_destination(7)),
      );
      await reverse.moveTo(harness.edge(forward: false));
      await tester.pump();
      await _pumpUntil(
        harness,
        () => harness.position.pixels < farOffset - 16,
        reason: 'the opposite physical edge must reverse scrolling',
      );
      harness.expectSelection(7);
      expect(harness.selections, [7]);
      await reverse.cancel();
      await tester.pumpAndSettle();
      await _expectStopped(harness);
      harness.expectSelection(7);
      expect(harness.selections, [7]);
      harness.expectPinned(pinned);
    });

    testWidgets('$direction an external selection cancels the captured thumb', (
      tester,
    ) async {
      final harness = await _pumpBar(tester, direction: direction);
      final pinned = harness.toggle;
      final gesture = await tester.startGesture(
        tester.getCenter(_destination(0)),
      );
      await gesture.moveTo(harness.edge());
      await tester.pump();
      await _pumpUntil(
        harness,
        () => harness.position.pixels > 0,
        reason: 'external selection must interrupt an actively scrolling thumb',
      );

      harness.controller.select(const SidebarPrimarySelection(3));
      await tester.pump();
      harness.expectSelection(3);
      expect(harness.selections, isEmpty);
      await _expectStopped(harness);
      await gesture.moveTo(harness.edge(forward: false));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pumpAndSettle();
      await _expectStopped(harness);
      harness.expectSelection(3);
      expect(harness.selections, isEmpty);
      harness.expectPinned(pinned);
    });

    testWidgets('$direction a fresh drag survives the previous cancellation', (
      tester,
    ) async {
      final harness = await _pumpBar(tester, direction: direction);
      final pinned = harness.toggle;
      final cancelled = await tester.startGesture(
        tester.getCenter(_destination(0)),
      );
      await cancelled.moveTo(harness.edge());
      await tester.pump();
      await _pumpUntil(
        harness,
        () => harness.position.pixels > 0,
        reason: 'the first drag must have an active scroll before cancellation',
      );
      await cancelled.cancel();

      // Do not settle: the next gesture must tolerate completion of the old
      // scroll step while it is already driving its own preview and scroll.
      final offset = harness.position.pixels;
      final start = tester.getCenter(_destination(0));
      expect(harness.viewport.contains(start), isTrue);
      final replacement = await tester.startGesture(start);
      final edge = harness.edge();
      await replacement.moveTo(edge);
      await tester.pump();
      await _pumpUntil(
        harness,
        () => harness.position.pixels >= offset + 100,
        reason: 'the replacement drag must keep scrolling without more moves',
      );
      harness.expectSelection(0);
      expect(harness.selections, isEmpty);
      expect(harness.highlight.center.dx, closeTo(edge.dx, 2));
      expect(tester.getRect(_destination(2)).contains(edge), isTrue);
      await replacement.up();
      await tester.pumpAndSettle();
      harness.expectSelection(2);
      expect(harness.selections, [2]);
      await _expectStopped(harness);
      harness.expectPinned(pinned);
    });

    testWidgets('$direction removing an actively scrolling thumb is safe', (
      tester,
    ) async {
      final harness = await _pumpBar(tester, direction: direction);
      final gesture = await tester.startGesture(
        tester.getCenter(_destination(0)),
      );
      await gesture.moveTo(
        harness.edge() + Offset(harness.forwardSign * 20, 0),
      );
      await tester.pump();
      await _pumpUntil(
        harness,
        () => harness.position.pixels > 0,
        reason: 'an active drag may continue beyond the clipped viewport',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(harness.selections, isEmpty);
      expect(tester.binding.transientCallbackCount, 0);
      harness.expectNoErrors();
    });

    testWidgets(
      '$direction dragging an unselected tab remains ordinary scroll',
      (tester) async {
        final harness = await _pumpBar(tester, direction: direction);
        final pinned = harness.toggle;
        // Only the near edge of tab 1 is visible; its center is clipped out.
        final start = harness.edge(inset: 8);
        expect(tester.getRect(_destination(1)).contains(start), isTrue);
        final gesture = await tester.startGesture(start);
        await gesture.moveBy(Offset(-harness.forwardSign * 30, 0));
        await tester.pump(const Duration(milliseconds: 16));
        await gesture.moveBy(Offset(-harness.forwardSign * 70, 0));
        await tester.pump(const Duration(milliseconds: 30));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(harness.position.pixels, greaterThan(0));
        harness.expectSelection(0);
        expect(harness.selections, isEmpty);
        harness.expectPinned(pinned);
        harness.expectNoErrors();
      },
    );
  }

  testWidgets('a roomy bar preserves thumb drag selection without scrolling', (
    tester,
  ) async {
    final harness = await _pumpBar(
      tester,
      destinationCount: 3,
      maximumWidth: 340,
    );
    final pinned = harness.toggle;
    expect(harness.position.maxScrollExtent, 0);
    final target = _destination(2);
    final gesture = await tester.startGesture(
      tester.getCenter(_destination(0)),
    );
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump(const Duration(milliseconds: 300));
    harness.expectSelection(0);
    expect(harness.selections, isEmpty);
    expect(harness.position.pixels, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    harness.expectSelection(2);
    expect(harness.selections, [2]);
    expect(
      harness.highlight.center.dx,
      closeTo(tester.getCenter(target).dx, 1),
    );
    harness.expectPinned(pinned);
    harness.expectNoErrors();
  });

  testWidgets('resizing the body viewport cancels a stationary thumb', (
    tester,
  ) async {
    final cap = ValueNotifier(161.0);
    addTearDown(cap.dispose);
    final harness = await _pumpBar(
      tester,
      maximumWidthListenable: cap,
      destinationExtent: 52,
    );
    final point = harness.viewport.center;
    expect(tester.getRect(_destination(1)).contains(point), isTrue);
    final gesture = await tester.startGesture(
      Offset(harness.viewport.left + 20, point.dy),
    );
    await gesture.moveTo(point);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(harness.position.pixels, 0);
    harness.expectSelection(0);
    expect(harness.selections, isEmpty);
    expect(harness.highlight.center.dx, closeTo(point.dx, 1));

    cap.value = 151;
    await tester.pump();
    expect(harness.viewport.width, 99);
    expect(tester.getRect(_destination(0)).contains(point), isTrue);
    await gesture.up();
    await tester.pumpAndSettle();
    harness.expectSelection(0);
    expect(harness.selections, isEmpty);
    expect(harness.position.pixels, 0);
    harness.expectNoErrors();
  });

  testWidgets('expanding the sidebar cancels a captured scrolling thumb', (
    tester,
  ) async {
    final harness = await _pumpBar(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(_destination(0)),
    );
    await gesture.moveTo(harness.edge());
    await tester.pump();
    await _pumpUntil(
      harness,
      () => harness.position.pixels > 0,
      reason: 'the thumb must be scrolling before the sidebar expands',
    );
    final position = harness.position;
    harness.controller.expanded = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    final leading = tester
        .element(find.byType(CupertinoPageScaffold))
        .getInheritedWidgetOfExactType<SidebarLeadingScope>()!;
    expect(leading.progress, lessThan(1));
    final offset = position.pixels;
    await tester.pump(const Duration(milliseconds: 60));
    expect(position.pixels, closeTo(offset, 0.001));
    await gesture.up();
    await tester.pumpAndSettle();
    harness.expectSelection(0);
    expect(harness.selections, isEmpty);
    expect(tester.binding.transientCallbackCount, 0);
    harness.expectNoErrors();
  });
}
