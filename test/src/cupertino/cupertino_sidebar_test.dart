import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selection and expansion survive a style change', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.tap(find.byKey(const ValueKey('material-rail-destination-1')));
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 1);

    controller.expanded = false;
    await tester.pumpAndSettle();

    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 1);
    expect(controller.expanded, isFalse);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cupertino-sidebar-panel')), findsNothing);

    controller.expanded = true;
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CupertinoButton, 'Settings'));
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 2);
    expect(controller.expanded, isTrue);
  });

  testWidgets('collapsed sidebar reserves the page leading slot', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();

    final scope = SidebarLeadingScope.maybeOf(
      tester.element(find.text('Body')),
    );
    expect(scope?.reservedExtent, SidebarLeadingScope.buttonExtent);
  });

  testWidgets('disableAnimations style switch does not throw', (tester) async {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: false,
      disableAnimations: true,
    );
    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: true,
      disableAnimations: true,
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
  });

  testWidgets('dragged sidebar width survives a style change', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('rail-resize-gesture-handle')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(controller.manualWidth, isNotNull);
    final width = controller.manualWidth;

    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();

    expect(controller.manualWidth, width);
    final panel = tester.widget<SizedBox>(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
    );
    expect(panel.width, moreOrLessEquals(width!));
  });

  testWidgets('background color is shared with the content area', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const custom = Color(0xFF336699);

    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();

    final backdrop = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('cupertino-sidebar-backdrop')),
    );
    final pageContext = tester.element(find.text('Body'));
    expect(
      CupertinoTheme.of(pageContext).scaffoldBackgroundColor,
      backdrop.color,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: sidebarHost(
          controller: controller,
          cupertino: true,
          backgroundColor: custom,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final customBackdrop = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('cupertino-sidebar-backdrop')),
    );
    expect(customBackdrop.color, custom);
    final surfaceColor = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byKey(const ValueKey('cupertino-sidebar-surface')),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(surfaceColor.color, custom);
    final customPage = tester.element(find.text('Body'));
    expect(CupertinoTheme.of(customPage).scaffoldBackgroundColor, custom);
    expect(CupertinoTheme.of(customPage).barBackgroundColor, custom);
  });

  testWidgets('vertical window avoidance does not drop the toggle', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: const EdgeInsets.only(top: 20)),
            child: NavigationObstructionScope(
              obstruction: const NavigationObstruction(
                sidebar: EdgeInsets.only(left: 50, top: 43),
              ),
              child: CupertinoTheme(
                data: const CupertinoThemeData(),
                child: CupertinoSidebar(
                  controller: controller,
                  content: const SizedBox.shrink(),
                  child: const CupertinoPageScaffold(
                    navigationBar: CupertinoNavigationBar(
                      middle: Text('Title'),
                    ),
                    child: SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggle = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-toggle')),
    );
    final title = tester.getRect(find.text('Title'));
    expect(toggle.top, 20);
    expect(title.center.dy, toggle.center.dy);
  });
}
