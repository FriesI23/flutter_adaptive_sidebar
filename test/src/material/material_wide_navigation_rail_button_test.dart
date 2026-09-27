import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  testWidgets('press reports the destination and keeps its selected flag', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    var presses = 0;
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: MaterialSidebar(
          controller: controller,
          content: MaterialWideNavigationRailButton(
            key: const ValueKey('button'),
            destination: sidebarDestinations.first,
            selected: true,
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<MaterialWideNavigationRailButton>(
            find.byType(MaterialWideNavigationRailButton),
          )
          .selected,
      isTrue,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('button')),
        matching: find.byType(TextButton),
      ),
    );
    expect(presses, 1);
  });

  testWidgets('item style overrides the indicator and label', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const style = MaterialSidebarItemStyle(
      selectedColor: Color(0xFF6A1B9A),
      selectedForegroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF4A148C),
      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: MaterialSidebar(
          controller: controller,
          content: MaterialWideNavigationRailButton(
            destination: sidebarDestinations.first,
            selected: true,
            itemStyle: style,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final indicator = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('material-rail-indicator')),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      (indicator.decoration as ShapeDecoration).color,
      const Color(0xFF6A1B9A),
    );
    final label = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('material-rail-expanded-label')),
        matching: find.byType(Text),
      ),
    );
    expect(label.style?.color, const Color(0xFFFFFFFF));
    expect(label.style?.fontSize, 18);
    expect(label.style?.fontWeight, FontWeight.w700);
    expect(
      find.descendant(
        of: find.byType(MaterialWideNavigationRailButton),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is IconTheme &&
              widget.data.color == const Color(0xFFFFFFFF),
        ),
      ),
      findsWidgets,
    );
  });
}
