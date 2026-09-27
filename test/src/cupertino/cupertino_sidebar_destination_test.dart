import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  testWidgets('selected destination exposes its semantics label', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoSidebarDestination(
          destination: sidebarDestinations.first,
          selected: true,
          onPressed: () => presses++,
        ),
      ),
    );

    expect(
      tester
          .widget<CupertinoSidebarDestination>(
            find.byType(CupertinoSidebarDestination),
          )
          .selected,
      isTrue,
    );
    expect(
      tester.getSemantics(find.byType(CupertinoSidebarDestination)).label,
      'Home',
    );
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<CupertinoButton>(),
      isNull,
    );
    await tester.tap(find.byType(CupertinoSidebarDestination));
    expect(presses, 1);
  });

  testWidgets('liquid selection stays a translucent primary tint', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await _pumpSelection(tester, controller: controller, edge: false);

    final primary = CupertinoTheme.of(
      tester.element(find.byType(CupertinoSidebarDestination)),
    ).primaryColor;
    expect(_fill(tester), primary.withValues(alpha: 0.14));
    expect(_labelColor(tester), primary.withValues(alpha: 1));
    _expectCapsule(tester);
  });

  testWidgets('edge selection uses a solid contrasting fill', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await _pumpSelection(tester, controller: controller, edge: true);

    final theme = CupertinoTheme.of(
      tester.element(find.byType(CupertinoSidebarDestination)),
    );
    expect(_fill(tester), theme.primaryColor);
    expect(
      _labelColor(tester),
      theme.primaryContrastingColor.withValues(alpha: 1),
    );
    _expectCapsule(tester);
  });

  testWidgets('a tap selects without changing the label color', (tester) async {
    var presses = 0;
    await _pumpRow(tester, onPressed: () => presses++);
    final before = _labelColor(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CupertinoSidebarDestination)),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(_labelColor(tester), before);
    await gesture.up();
    await tester.pump();

    expect(presses, 1);
    expect(_labelColor(tester), before);
  });

  testWidgets('a long press dims the label and does not select', (
    tester,
  ) async {
    var presses = 0;
    await _pumpRow(tester, onPressed: () => presses++);
    final before = _labelColor(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CupertinoSidebarDestination)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(_labelColor(tester), before.withValues(alpha: 0.4));
    expect(presses, 0);

    await gesture.up();
    await tester.pump();
    expect(_labelColor(tester), before);
    expect(presses, 0);
  });

  testWidgets('item style overrides the side capsule', (tester) async {
    const style = CupertinoSidebarItemStyle(
      selectedColor: Color(0xFF112233),
      selectedForegroundColor: Color(0xFFAABBCC),
      foregroundColor: Color(0xFF445566),
      labelStyle: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: SizedBox(
            width: 280,
            child: CupertinoSidebarDestination(
              destination: sidebarDestinations.first,
              selected: true,
              itemStyle: style,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(_fill(tester), const Color(0xFF112233));
    final label = _labelStyle(tester);
    expect(label.color, const Color(0xFFAABBCC));
    expect(label.fontSize, 21);
    expect(label.fontWeight, FontWeight.w800);
  });

  testWidgets('item style overrides an edge fill', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const style = CupertinoSidebarItemStyle(
      selectedColor: Color(0xFF332211),
      selectedForegroundColor: Color(0xFFDDEEFF),
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoSidebar.edge(
          controller: controller,
          content: CupertinoSidebarDestination(
            destination: sidebarDestinations.first,
            selected: true,
            itemStyle: style,
            onPressed: () {},
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );

    expect(_fill(tester), const Color(0xFF332211));
    expect(_labelColor(tester), const Color(0xFFDDEEFF));
  });

  testWidgets('item style overrides the collapsed bar', (tester) async {
    const style = CupertinoSidebarItemStyle(
      selectedColor: Color(0xFFE65100),
      selectedForegroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFFBF360C),
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
    );
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: CupertinoSidebarCollapsedBar(
            destinations: sidebarDestinations,
            selectedIndex: 0,
            itemStyle: style,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final highlight = tester.widget<DecoratedBox>(
      find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
      ),
    );
    expect(
      (highlight.decoration as BoxDecoration).color,
      const Color(0xFFE65100),
    );
    final selected = tester.widget<Text>(find.text('Home')).style!;
    expect(selected.color, const Color(0xFFFFFFFF));
    expect(selected.fontSize, 13);
    expect(selected.fontWeight, FontWeight.w800);
    final unselected = tester.widget<Text>(find.text('Search')).style!;
    expect(unselected.color, const Color(0xFFBF360C));
    expect(unselected.fontSize, 13);
  });

  test('toolbar geometry exposes standard, compact, and custom sizes', () {
    const custom = CupertinoSidebarToolbarGeometry(
      contentHeight: 40,
      collapsedBarHeight: 28,
      height: 44,
    );

    expect(CupertinoSidebarToolbarGeometry.standard.contentHeight, 44);
    expect(CupertinoSidebarToolbarGeometry.standard.collapsedBarHeight, 44);
    expect(CupertinoSidebarToolbarGeometry.standard.height, 54);
    expect(CupertinoSidebarToolbarGeometry.compact.contentHeight, 44);
    expect(CupertinoSidebarToolbarGeometry.compact.collapsedBarHeight, 36);
    expect(CupertinoSidebarToolbarGeometry.compact.height, 44);
    expect(custom.contentHeight, 40);
    expect(custom.collapsedBarHeight, 28);
    expect(custom.height, 44);
  });
}

Future<void> _pumpRow(WidgetTester tester, {required VoidCallback onPressed}) {
  return tester.pumpWidget(
    CupertinoApp(
      home: Center(
        child: SizedBox(
          width: 280,
          child: CupertinoSidebarDestination(
            destination: sidebarDestinations.first,
            selected: true,
            onPressed: onPressed,
          ),
        ),
      ),
    ),
  );
}

void _expectCapsule(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(CupertinoSidebarDestination),
      matching: find.byType(DecoratedBox),
    ),
  );
  expect(
    (box.decoration as BoxDecoration).borderRadius,
    BorderRadius.circular(22),
  );
  expect(
    find.descendant(
      of: find.byType(CupertinoSidebarDestination),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.padding ==
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    ),
    findsOneWidget,
  );
}

Color _fill(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(CupertinoSidebarDestination),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).color!;
}

Color _labelColor(WidgetTester tester) {
  return _labelStyle(tester).color!;
}

TextStyle _labelStyle(WidgetTester tester) {
  final style = tester.widget<DefaultTextStyle>(
    find.descendant(
      of: find.byType(CupertinoSidebarDestination),
      matching: find.byType(DefaultTextStyle),
    ),
  );
  return style.style;
}

Future<void> _pumpSelection(
  WidgetTester tester, {
  required AdaptiveNavigationController controller,
  required bool edge,
}) {
  final destination = CupertinoSidebarDestination(
    destination: sidebarDestinations.first,
    selected: true,
    onPressed: () {},
  );
  final sidebar = edge
      ? CupertinoSidebar.edge(
          controller: controller,
          content: destination,
          child: const SizedBox.expand(),
        )
      : CupertinoSidebar(
          controller: controller,
          content: destination,
          child: const SizedBox.expand(),
        );
  return tester.pumpWidget(CupertinoApp(home: sidebar));
}
