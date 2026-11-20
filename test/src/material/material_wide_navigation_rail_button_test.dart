import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
        matching: find.byType(InkWell),
      ),
    );
    expect(presses, 1);
  });

  for (final expanded in [false, true]) {
    for (final selected in [false, true]) {
      testWidgets(
        '${expanded ? 'expanded' : 'collapsed'} rail paints hover and press '
        'feedback when selected=$selected',
        (tester) async {
          useLargeTestWindow(tester);
          var presses = 0;
          final controller = AdaptiveNavigationController(
            initialExpanded: expanded,
          );
          addTearDown(controller.dispose);
          const boundaryKey = ValueKey('feedback-boundary');
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                hoverColor: const Color(0xFF0000FF),
                splashColor: const Color(0xFF00FF00),
                splashFactory: InkRipple.splashFactory,
              ),
              home: MaterialSidebar(
                controller: controller,
                content: RepaintBoundary(
                  key: boundaryKey,
                  child: MaterialWideNavigationRailButton(
                    destination: sidebarDestinations.first,
                    selected: selected,
                    onPressed: () => presses++,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final button = find.descendant(
            of: find.byType(MaterialWideNavigationRailButton),
            matching: find.byType(InkWell),
          );
          final rect = tester.getRect(button);
          // Sample inside the indicator, away from its icon and label.
          final position = rect.centerLeft + const Offset(10, 0);
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(boundaryKey),
          );
          final sample = boundary.globalToLocal(position);
          Future<int> pixel() async {
            return (await tester.runAsync(() async {
              final image = await boundary.toImage();
              final bytes = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              final offset =
                  (sample.dy.floor() * image.width + sample.dx.floor()) * 4;
              final value = bytes.getUint32(offset);
              image.dispose();
              return value;
            }))!;
          }

          final idle = await pixel();
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(position);
          await tester.pumpAndSettle();
          expect(await pixel(), isNot(idle));
          await mouse.moveTo(Offset.zero);
          await tester.pumpAndSettle();
          expect(await pixel(), idle);
          await mouse.removePointer();

          final press = await tester.startGesture(position);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          expect(await pixel(), isNot(idle));
          await press.up();
          await tester.pumpAndSettle();
          expect(presses, 1);
          expect(await pixel(), idle);
        },
      );
    }
  }

  testWidgets('rail follows NavigationBar overlays and rail indicator shape', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    final overlays = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.hovered)) return Colors.blue;
      if (states.contains(WidgetState.pressed)) return Colors.green;
      if (states.contains(WidgetState.focused)) return Colors.red;
      return null;
    });
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          navigationBarTheme: NavigationBarThemeData(overlayColor: overlays),
          navigationRailTheme: const NavigationRailThemeData(
            indicatorShape: shape,
          ),
        ),
        home: MaterialSidebar(
          controller: controller,
          content: MaterialWideNavigationRailButton(
            destination: sidebarDestinations.first,
            selected: true,
            onPressed: () {},
          ),
        ),
      ),
    );
    final ink = tester.widget<InkWell>(
      find.descendant(
        of: find.byType(MaterialWideNavigationRailButton),
        matching: find.byType(InkWell),
      ),
    );
    expect(ink.customBorder, shape);
    for (final state in [
      WidgetState.hovered,
      WidgetState.pressed,
      WidgetState.focused,
    ]) {
      expect(ink.overlayColor?.resolve({state}), overlays.resolve({state}));
    }
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
