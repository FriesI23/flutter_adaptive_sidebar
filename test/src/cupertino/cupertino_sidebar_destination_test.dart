import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
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

  for (final edge in [false, true]) {
    testWidgets(
      '${edge ? 'edge' : 'liquid'} selection follows the Cupertino tint',
      (tester) async {
        useLargeTestWindow(tester);
        final controller = AdaptiveNavigationController();
        addTearDown(controller.dispose);
        const primaryColor = CupertinoColors.systemPurple;
        await _pumpSelection(
          tester,
          controller: controller,
          edge: edge,
          primaryColor: primaryColor,
        );

        expect(_fill(tester), primaryColor.withValues(alpha: 0.14));
        final context = tester.element(
          find.byType(CupertinoSidebarDestination),
        );
        expect(
          _labelColor(tester),
          edge
              ? CupertinoDynamicColor.resolve(
                  CupertinoColors.label,
                  context,
                ).withValues(alpha: 1)
              : primaryColor.withValues(alpha: 1),
        );
        expect(_iconColor(tester), primaryColor.withValues(alpha: 1));
        _expectCapsule(tester);
      },
    );
  }

  testWidgets('focused edge selection uses the theme tint and white content', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const primaryColor = CupertinoColors.systemPurple;
    await _pumpSelection(
      tester,
      controller: controller,
      edge: true,
      primaryColor: primaryColor,
    );

    Focus.of(tester.element(find.text('Home'))).requestFocus();
    await tester.pump();

    expect(_fill(tester), primaryColor.withValues(alpha: 1));
    expect(_labelColor(tester), CupertinoColors.white);
    expect(_iconColor(tester), CupertinoColors.white);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: find.byType(CupertinoSidebarDestination),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as ShapeDecoration;
    expect(
      (decoration.shape as RoundedSuperellipseBorder).side.style,
      BorderStyle.none,
    );
  });

  testWidgets('dark edge keeps unfocused and active theme-tint states', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await _pumpSelection(
      tester,
      controller: controller,
      edge: true,
      brightness: Brightness.dark,
    );

    final context = tester.element(find.byType(CupertinoSidebarDestination));
    final primaryColor = CupertinoTheme.of(
      context,
    ).primaryColor.withValues(alpha: 1);
    expect(_fill(tester), primaryColor.withValues(alpha: 0.14));
    expect(_labelColor(tester), CupertinoColors.white);
    expect(_iconColor(tester), primaryColor);

    Focus.of(tester.element(find.text('Home'))).requestFocus();
    await tester.pump();
    expect(_fill(tester), primaryColor);
    expect(_labelColor(tester), CupertinoColors.white);
    expect(_iconColor(tester), CupertinoColors.white);
  });

  testWidgets('an edge touch keeps active tint until focus moves', (
    tester,
  ) async {
    var presses = 0;
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    final bodyFocusNode = FocusNode();
    addTearDown(bodyFocusNode.dispose);
    const primaryColor = CupertinoColors.systemPurple;
    await _pumpSelection(
      tester,
      controller: controller,
      edge: true,
      primaryColor: primaryColor,
      onPressed: () => presses++,
      bodyFocusNode: bodyFocusNode,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CupertinoSidebarDestination)),
    );
    await tester.pump(const Duration(milliseconds: 80));
    expect(_fill(tester), primaryColor.withValues(alpha: 1));
    expect(_labelColor(tester), CupertinoColors.white);
    await gesture.up();
    await tester.pump();

    expect(presses, 1);
    expect(Focus.of(tester.element(find.text('Home'))).hasFocus, isTrue);
    expect(_fill(tester), primaryColor.withValues(alpha: 1));

    bodyFocusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(bodyFocusNode.hasFocus, isTrue);
    expect(Focus.of(tester.element(find.text('Home'))).hasFocus, isFalse);
    expect(_fill(tester), primaryColor.withValues(alpha: 0.14));
  });

  testWidgets('a long press keeps opaque content and does not select', (
    tester,
  ) async {
    var presses = 0;
    await _pumpRow(tester, onPressed: () => presses++);
    final before = _labelColor(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CupertinoSidebarDestination)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(_labelColor(tester), before);
    expect(presses, 0);

    await gesture.up();
    await tester.pump();
    expect(_labelColor(tester), before);
    expect(presses, 0);
  });

  testWidgets('a mouse click keeps edge focus after release', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const primaryColor = CupertinoColors.systemPurple;
    await _pumpSelection(
      tester,
      controller: controller,
      edge: true,
      primaryColor: primaryColor,
    );

    final destination = find.byType(CupertinoSidebarDestination);
    final gesture = await tester.startGesture(
      tester.getCenter(destination),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(Focus.of(tester.element(find.text('Home'))).hasFocus, isTrue);
    expect(_fill(tester), primaryColor.withValues(alpha: 1));
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

  testWidgets('state item style separates background, icon, and label', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    final style = CupertinoSidebarItemStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? const Color(0xFF102030)
            : const Color(0xFF405060),
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? const Color(0xFF708090)
            : const Color(0xFFA0B0C0),
      ),
      labelColor: const WidgetStatePropertyAll(Color(0xFFD0E0F0)),
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

    expect(_fill(tester), const Color(0xFF405060));
    expect(_iconColor(tester), const Color(0xFFA0B0C0));
    expect(_labelColor(tester), const Color(0xFFD0E0F0));

    Focus.of(tester.element(find.text('Home'))).requestFocus();
    await tester.pump();
    expect(_fill(tester), const Color(0xFF102030));
    expect(_iconColor(tester), const Color(0xFF708090));
  });

  testWidgets('state item style resolves Cupertino dynamic colors', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const dynamicColor = CupertinoDynamicColor.withBrightness(
      color: Color(0xFF112233),
      darkColor: Color(0xFFAABBCC),
    );
    const style = CupertinoSidebarItemStyle(
      backgroundColor: WidgetStatePropertyAll(dynamicColor),
      iconColor: WidgetStatePropertyAll(dynamicColor),
      labelColor: WidgetStatePropertyAll(dynamicColor),
    );
    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
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

    expect(_fill(tester).toARGB32(), 0xFFAABBCC);
    expect(_iconColor(tester).toARGB32(), 0xFFAABBCC);
    expect(_labelColor(tester).toARGB32(), 0xFFAABBCC);
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
    (box.decoration as ShapeDecoration).shape,
    isA<RoundedSuperellipseBorder>().having(
      (shape) => shape.borderRadius,
      'borderRadius',
      BorderRadius.circular(22),
    ),
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
  return (box.decoration as ShapeDecoration).color!;
}

Color _labelColor(WidgetTester tester) {
  return _labelStyle(tester).color!;
}

Color _iconColor(WidgetTester tester) {
  return tester
      .widget<IconTheme>(
        find.descendant(
          of: find.byType(CupertinoSidebarDestination),
          matching: find.byType(IconTheme),
        ),
      )
      .data
      .color!;
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
  Color? primaryColor,
  Brightness? brightness,
  VoidCallback? onPressed,
  FocusNode? bodyFocusNode,
}) {
  final destination = CupertinoSidebarDestination(
    destination: sidebarDestinations.first,
    selected: true,
    onPressed: onPressed ?? () {},
  );
  final sidebar = edge
      ? CupertinoSidebar.edge(
          controller: controller,
          content: destination,
          child: bodyFocusNode == null
              ? const SizedBox.expand()
              : Focus(focusNode: bodyFocusNode, child: const SizedBox.expand()),
        )
      : CupertinoSidebar(
          controller: controller,
          content: destination,
          child: bodyFocusNode == null
              ? const SizedBox.expand()
              : Focus(focusNode: bodyFocusNode, child: const SizedBox.expand()),
        );
  return tester.pumpWidget(
    CupertinoApp(
      theme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: primaryColor,
      ),
      home: sidebar,
    ),
  );
}
