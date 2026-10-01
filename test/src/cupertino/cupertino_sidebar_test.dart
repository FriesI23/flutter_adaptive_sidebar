import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_adaptive_sidebar/src/cupertino/cupertino_sidebar_chrome.dart';
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
    expect(controller.selection, const SidebarPrimarySelection(1));

    controller.expanded = false;
    await tester.pumpAndSettle();

    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();
    expect(controller.selection, const SidebarPrimarySelection(1));
    expect(controller.expanded, isFalse);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cupertino-sidebar-panel')), findsNothing);

    controller.expanded = true;
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CupertinoSidebarDestination, 'Settings'),
    );
    await tester.pumpAndSettle();
    expect(controller.selection, const SidebarPrimarySelection(2));
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
          scaffoldBackgroundColor: custom,
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
    final barColor = CupertinoTheme.of(
      tester.element(find.byKey(const ValueKey('cupertino-sidebar-surface'))),
    ).barBackgroundColor;
    expect(
      surfaceColor.color,
      barColor.withValues(alpha: CupertinoSidebarChrome.liquid.fill.alpha),
    );
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

  testWidgets('collapsed bar keeps the toggle and destinations centered', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
      findsOneWidget,
    );
    expect(_pointerIgnored(tester, find.text('Title')), isFalse);
    expect(
      _pointerIgnored(
        tester,
        find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
      ),
      isTrue,
    );
    expect(find.text('reserved:0.0'), findsOneWidget);

    controller.expanded = false;
    await tester.pumpAndSettle();

    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    expect(find.byType(CompositedTransformTarget), findsOneWidget);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-fixed-toolbar-host')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('cupertino-sidebar-panel')), findsNothing);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-toggle-position')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-toggle')),
      findsOneWidget,
    );
    expect(_pointerIgnored(tester, find.text('Title')), isTrue);
    expect(
      _pointerIgnored(
        tester,
        find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
      ),
      isFalse,
    );
    expect(find.text('reserved:0.0'), findsOneWidget);

    final capsule = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
    );
    final toggle = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-toggle')),
    );
    final home = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-0')),
    );
    expect(capsule.left, lessThanOrEqualTo(toggle.left));
    expect(toggle.right, lessThanOrEqualTo(home.left));
    expect(home.right, lessThanOrEqualTo(capsule.right));
    expect(_collapsedBarPaintsOutsideNavigationBar(tester), isTrue);
    expect(
      find.descendant(
        of: find.byType(Scrollable),
        matching: find.byKey(const ValueKey('cupertino-sidebar-toggle')),
      ),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-1')),
    );
    await tester.pumpAndSettle();
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
    await tester.pumpAndSettle();
    expect(controller.expanded, isTrue);
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
      findsOneWidget,
    );
    expect(_pointerIgnored(tester, find.text('Title')), isFalse);
    expect(
      _pointerIgnored(
        tester,
        find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
      ),
      isTrue,
    );
  });

  testWidgets(
    'fixed collapsed bar overlays the toolbar and uses a placeholder',
    (tester) async {
      useLargeTestWindow(tester);
      tester.view.padding = const FakeViewPadding(top: 20);
      tester.view.viewPadding = const FakeViewPadding(top: 20);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      final controller = AdaptiveNavigationController(initialExpanded: false);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        collapsedBarHost(
          controller: controller,
          collapsedBarPlacement:
              CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
          collapsedBarHeight: 30,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      final capsule = find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-capsule'),
      );
      final fixedHost = find.byKey(
        const ValueKey('cupertino-sidebar-fixed-toolbar-host'),
      );
      final placeholder = find.byKey(
        const ValueKey('cupertino-sidebar-fixed-toolbar-placeholder'),
      );
      expect(fixedHost, findsOneWidget);
      expect(capsule, findsOneWidget);
      expect(
        find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        findsOneWidget,
      );
      expect(find.byType(CompositedTransformFollower), findsNothing);
      expect(find.byType(CompositedTransformTarget), findsNothing);
      expect(tester.getSize(fixedHost).height, 44);
      expect(tester.getSize(placeholder), tester.getSize(capsule));
      expect(tester.getCenter(capsule), tester.getCenter(fixedHost));
      expect(tester.getCenter(capsule).dy, 42);
      expect(_pointerIgnored(tester, find.text('Title')), isTrue);

      controller.expanded = true;
      await tester.pumpAndSettle();

      expect(_pointerIgnored(tester, find.text('Title')), isFalse);
      expect(_pointerIgnored(tester, capsule), isTrue);
    },
  );

  testWidgets('toggle builder covers the button and transition placeholder', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        collapsedBarPlacement:
            CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
        theme: const CupertinoThemeData(
          primaryColor: CupertinoColors.systemPurple,
        ),
        toggleButtonBuilder: (context, defaultBuilder) => CupertinoTheme(
          data: CupertinoTheme.of(
            context,
          ).copyWith(primaryColor: CupertinoColors.systemGreen),
          child: Builder(builder: defaultBuilder),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final glyphs = find.byIcon(CupertinoIcons.sidebar_left);
    expect(glyphs, findsOneWidget);
    for (final element in glyphs.evaluate()) {
      final icon = element.widget as Icon;
      expect(
        icon.color ?? IconTheme.of(element).color,
        CupertinoDynamicColor.resolve(CupertinoColors.systemGreen, element),
      );
    }

    controller.expanded = true;
    await tester.pumpAndSettle();

    expect(glyphs, findsNWidgets(2));
    for (final element in glyphs.evaluate()) {
      final icon = element.widget as Icon;
      expect(
        icon.color ?? IconTheme.of(element).color,
        CupertinoDynamicColor.resolve(CupertinoColors.systemGreen, element),
      );
    }
  });

  testWidgets('fixed collapsed bar centers in an LTR edge toolbar', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        collapsedBarPlacement:
            CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
        collapsedBarHeight: 28,
        style: CupertinoSidebarStyle.liquidEdge,
      ),
    );
    await tester.pumpAndSettle();

    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    final fixedHost = find.byKey(
      const ValueKey('cupertino-sidebar-fixed-toolbar-host'),
    );
    final placeholder = find.byKey(
      const ValueKey('cupertino-sidebar-fixed-toolbar-placeholder'),
    );
    expect(find.byType(CompositedTransformFollower), findsNothing);
    expect(find.byType(CompositedTransformTarget), findsNothing);
    expect(tester.getSize(placeholder), tester.getSize(capsule));
    expect(tester.getCenter(capsule), tester.getCenter(fixedHost));
    expect(tester.getCenter(capsule).dy, 22);
  });

  testWidgets('compact geometry keeps the edge toolbar top inset', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        collapsedBarPlacement:
            CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
        style: CupertinoSidebarStyle.liquidEdge,
        toolbarGeometry: CupertinoSidebarToolbarGeometry.compact,
      ),
    );
    await tester.pumpAndSettle();

    final fixedHost = find.byKey(
      const ValueKey('cupertino-sidebar-fixed-toolbar-host'),
    );
    expect(tester.getTopLeft(fixedHost).dy, 10);
    expect(tester.getSize(fixedHost).height, 44);
  });

  testWidgets('custom toolbar geometry controls the fixed toolbar host', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        collapsedBarPlacement:
            CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
        toolbarGeometry: const CupertinoSidebarToolbarGeometry(
          contentHeight: 40,
          collapsedBarHeight: 28,
          height: 44,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    final fixedHost = find.byKey(
      const ValueKey('cupertino-sidebar-fixed-toolbar-host'),
    );
    expect(tester.getSize(fixedHost).height, 40);
    expect(tester.getSize(capsule).height, 28);
    expect(tester.getCenter(capsule), tester.getCenter(fixedHost));
  });

  testWidgets(
    'collapsed bar scrolls destinations and keeps the toggle pinned',
    (tester) async {
      tester.view.physicalSize = const Size(280, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final controller = AdaptiveNavigationController(initialExpanded: false);
      addTearDown(controller.dispose);
      final destinations = [
        for (var index = 0; index < 6; index++)
          AdaptiveNavigationDestination(
            label: 'Destination $index',
            icons: sidebarDestinations.first.icons,
          ),
      ];

      await tester.pumpWidget(
        collapsedBarHost(controller: controller, destinations: destinations),
      );
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(
        find.descendant(
          of: find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      expect(
        find.descendant(
          of: find.byType(Scrollable),
          matching: find.byKey(const ValueKey('cupertino-sidebar-toggle')),
        ),
        findsNothing,
      );
      expect(
        tester
            .getRect(find.byKey(const ValueKey('cupertino-sidebar-toggle')))
            .left,
        lessThan(
          tester
              .getRect(
                find.byKey(
                  const ValueKey('cupertino-sidebar-collapsed-destination-0'),
                ),
              )
              .left,
        ),
      );
    },
  );

  testWidgets('collapsed bar overflows below the button and one slot', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    const slot = 160.0;

    await tester.pumpWidget(
      collapsedBarHost(controller: controller, minimumDestinationExtent: slot),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final roomy = tester.getSize(
      find.descendant(
        of: find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(roomy.width, greaterThanOrEqualTo(slot));

    tester.view.physicalSize = const Size(120, 600);
    await tester.pumpWidget(
      collapsedBarHost(controller: controller, minimumDestinationExtent: slot),
    );
    await tester.pump();

    final errors = <Object>[];
    Object? error;
    while ((error = tester.takeException()) != null) {
      errors.add(error!);
    }
    expect(errors, isNotEmpty);
    expect(errors.first.toString(), contains('overflowed'));
  });

  testWidgets('collapsed bar places the toggle at the start in rtl', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        textDirection: TextDirection.rtl,
      ),
    );
    await tester.pumpAndSettle();

    final capsule = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
    );
    final toggle = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-toggle')),
    );
    final home = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-0')),
    );
    expect(find.byIcon(CupertinoIcons.sidebar_right), findsOneWidget);
    expect(toggle.left, greaterThanOrEqualTo(home.right));
    expect(toggle.right, lessThanOrEqualTo(capsule.right));
  });

  testWidgets('sidebar panel slides in from the leading edge', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();
    controller.expanded = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final translation = tester
        .widget<FractionalTranslation>(
          find.byKey(const ValueKey('cupertino-sidebar-panel-transition')),
        )
        .translation;
    expect(translation.dx, lessThan(0));
    expect(translation.dy, 0);
  });

  testWidgets('collapsed bar drops down while fading in', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    await tester.pumpAndSettle();
    controller.expanded = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final translation = tester
        .widget<FractionalTranslation>(
          find.byKey(const ValueKey('cupertino-sidebar-collapsed-transition')),
        )
        .translation;
    expect(translation.dx, 0);
    expect(translation.dy, lessThan(0));
  });

  testWidgets('collapsed bar can fade in place', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        transitionBuilder: CupertinoSidebarCollapsedBarTransition.fade,
      ),
    );
    await tester.pumpAndSettle();
    controller.expanded = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final transition = tester.widget(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-transition')),
    );
    expect(transition, isA<Opacity>());
    final opacity = (transition as Opacity).opacity;
    expect(opacity, greaterThan(0));
    expect(opacity, lessThan(1));
  });

  testWidgets('collapsed bar controller uses configured transition', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    final collapsedBarController = CupertinoSidebarCollapsedBarController();
    addTearDown(controller.dispose);
    addTearDown(collapsedBarController.dispose);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        collapsedBarController: collapsedBarController,
      ),
    );
    await tester.pumpAndSettle();

    collapsedBarController.hide();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    final transition = tester.widget<FractionalTranslation>(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-transition')),
    );
    expect(transition.translation.dy, lessThan(0));
    expect(collapsedBarController.progress, greaterThan(0));
    expect(collapsedBarController.progress, lessThan(1));
    expect(
      tester
          .widget<IgnorePointer>(
            find
                .ancestor(
                  of: find.byKey(
                    const ValueKey('cupertino-sidebar-collapsed-transition'),
                  ),
                  matching: find.byType(IgnorePointer),
                )
                .first,
          )
          .ignoring,
      isTrue,
    );

    await tester.pumpAndSettle();
    expect(collapsedBarController.progress, 0);
    collapsedBarController.show();
    await tester.pumpAndSettle();
    expect(collapsedBarController.progress, 1);

    controller.expanded = true;
    await tester.pumpAndSettle();
    expect(collapsedBarController.visible, isTrue);
    expect(collapsedBarController.progress, 0);
  });

  testWidgets('press drag moves the collapsed bar selection', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    await tester.pumpAndSettle();

    final start = tester.getCenter(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-0')),
    );
    final target = tester.getCenter(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-1')),
    );
    final gesture = await tester.startGesture(start);
    await tester.pump();
    await gesture.moveTo(target);
    await tester.pump();

    expect(controller.selection, const SidebarPrimarySelection(0));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(controller.selection, const SidebarPrimarySelection(1));
    final highlight = tester.getRect(
      find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
      ),
    );
    final selected = tester.getRect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-1')),
    );
    expect(highlight.overlaps(selected), isTrue);
  });

  testWidgets('collapsed bar defaults to the measured capsule', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    controller.expanded = false;
    await tester.pumpAndSettle();

    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    expect(
      tester.getSize(capsule).height,
      kCupertinoSidebarCollapsedBarMeasuredHeight,
    );
    final capsuleColor = tester.widget<ColoredBox>(
      find.descendant(of: capsule, matching: find.byType(ColoredBox)).first,
    );
    final barColor = CupertinoTheme.of(
      tester.element(capsule),
    ).barBackgroundColor;
    expect(
      capsuleColor.color,
      barColor.withValues(alpha: kCupertinoSidebarCollapsedBarGlassAlpha),
    );
    final label = tester.widget<Text>(find.text('Home'));
    expect(label.style?.fontSize, 15);
    expect(label.style?.fontWeight, FontWeight.w500);
    expect(label.style?.height, 1.2);
    expect(
      tester.widget<Icon>(find.byIcon(CupertinoIcons.sidebar_left)).size,
      20,
    );
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
            ),
          )
          .height,
      36,
    );
    for (final index in [0, 1]) {
      expect(
        tester
            .getSize(
              find.byKey(
                ValueKey('cupertino-sidebar-collapsed-destination-$index'),
              ),
            )
            .width,
        greaterThanOrEqualTo(kCupertinoSidebarCollapsedBarMeasuredWidth),
      );
    }

    await tester.pumpWidget(
      collapsedBarHost(controller: controller, collapsedBarHeight: 40),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
          )
          .height,
      40,
    );
  });

  testWidgets('edge collapsed bar uses the composed theme tint', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    const sourceColor = Color(0xFF123456);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        style: CupertinoSidebarStyle.liquidEdge,
        materialTheme: ThemeData(
          extensions: const [
            CupertinoSidebarThemeData(edgeBackgroundColor: sourceColor),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    final capsuleColor = tester.widget<ColoredBox>(
      find.descendant(of: capsule, matching: find.byType(ColoredBox)).first,
    );
    expect(capsuleColor.color, sourceColor.withValues(alpha: 0.45));
  });

  for (final style in CupertinoSidebarStyle.values) {
    testWidgets('${style.name} collapsed bar follows the Cupertino tint', (
      tester,
    ) async {
      useLargeTestWindow(tester);
      final controller = AdaptiveNavigationController(initialExpanded: false);
      addTearDown(controller.dispose);
      const primaryColor = CupertinoColors.systemPurple;

      await tester.pumpWidget(
        collapsedBarHost(
          controller: controller,
          style: style,
          theme: const CupertinoThemeData(primaryColor: primaryColor),
        ),
      );
      await tester.pumpAndSettle();

      final highlight = tester.widget<DecoratedBox>(
        find.byKey(
          const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
        ),
      );
      expect(
        (highlight.decoration as BoxDecoration).color,
        primaryColor.withValues(alpha: 0.14),
      );

      final context = tester.element(find.text('Home'));
      expect(
        tester.widget<Text>(find.text('Home')).style?.color,
        primaryColor.withValues(alpha: 1),
      );
      expect(
        tester.widget<Text>(find.text('Search')).style?.color?.toARGB32(),
        CupertinoDynamicColor.resolve(
          CupertinoColors.label,
          context,
        ).withValues(alpha: 1).toARGB32(),
      );

      final capsule = find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-capsule'),
      );
      final capsuleColor = tester.widget<ColoredBox>(
        find.descendant(of: capsule, matching: find.byType(ColoredBox)).first,
      );
      expect(capsuleColor.color.a, lessThanOrEqualTo(0.45));
      final hasBorder = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: capsule, matching: find.byType(DecoratedBox)),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .any((decoration) => decoration.border != null);
      expect(
        hasBorder,
        style == CupertinoSidebarStyle.liquidEdge,
        reason: '${style.name} keeps its own capsule treatment',
      );
    });
  }

  testWidgets('collapsed bar follows a dynamic parent style change', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    await tester.pumpAndSettle();

    DecoratedBox highlight() => tester.widget<DecoratedBox>(
      find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
      ),
    );
    expect(
      (highlight().decoration as BoxDecoration).color,
      CupertinoTheme.of(
        tester.element(find.text('Home')),
      ).primaryColor.withValues(alpha: 0.14),
    );

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        style: CupertinoSidebarStyle.liquidEdge,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      (highlight().decoration as BoxDecoration).color,
      CupertinoTheme.of(
        tester.element(find.text('Home')),
      ).primaryColor.withValues(alpha: 0.14),
    );
  });

  testWidgets('edge collapsed bar accepts an independent item style', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    const selected = Color(0xFF123456);
    const selectedForeground = Color(0xFF654321);
    const foreground = Color(0xFF345612);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        style: CupertinoSidebarStyle.liquidEdge,
        collapsedBarItemStyle: const CupertinoSidebarItemStyle(
          selectedColor: selected,
          selectedForegroundColor: selectedForeground,
          foregroundColor: foreground,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final highlight = tester.widget<DecoratedBox>(
      find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
      ),
    );
    expect((highlight.decoration as BoxDecoration).color, selected);
    expect(
      tester.widget<Text>(find.text('Home')).style?.color,
      selectedForeground,
    );
    expect(tester.widget<Text>(find.text('Search')).style?.color, foreground);
  });

  testWidgets('collapsed bar selects nothing when selectedIndex is null', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      collapsedBarHost(controller: controller, selectFromController: false),
    );
    controller.expanded = false;
    await tester.pumpAndSettle();

    expect(
      tester.getSize(
        find.byKey(
          const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
        ),
      ),
      Size.zero,
    );

    await tester.tap(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-1')),
    );
    await tester.pumpAndSettle();
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets('collapsed bar preserves a more transparent theme tint', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    const barColor = Color(0x0FFFFFFF);

    await tester.pumpWidget(
      collapsedBarHost(
        controller: controller,
        theme: const CupertinoThemeData(barBackgroundColor: barColor),
      ),
    );
    controller.expanded = false;
    await tester.pumpAndSettle();

    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    final capsuleColor = tester.widget<ColoredBox>(
      find.descendant(of: capsule, matching: find.byType(ColoredBox)).first,
    );
    expect(capsuleColor.color, barColor);
  });

  testWidgets('collapsed bar icons are off unless requested', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    await tester.pumpAndSettle();
    expect(find.byIcon(CupertinoIcons.house_fill), findsNothing);
    expect(find.byIcon(CupertinoIcons.search), findsNothing);

    await tester.pumpWidget(
      collapsedBarHost(controller: controller, showIcons: true),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(CupertinoIcons.house_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
  });

  testWidgets('collapsed bar separator is off unless requested', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(collapsedBarHost(controller: controller));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-separator')),
      findsNothing,
    );

    await tester.pumpWidget(
      collapsedBarHost(controller: controller, collapsedBarSeparator: true),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-separator')),
      findsOneWidget,
    );
  });
}

Widget collapsedBarHost({
  required AdaptiveNavigationController controller,
  ThemeData? materialTheme,
  CupertinoThemeData theme = const CupertinoThemeData(),
  CupertinoSidebarCollapsedBarController? collapsedBarController,
  CupertinoSidebarCollapsedBarPlacement collapsedBarPlacement =
      CupertinoSidebarCollapsedBarPlacement.toolbarAnchor,
  List<AdaptiveNavigationDestination> destinations = sidebarDestinations,
  TextDirection textDirection = TextDirection.ltr,
  CupertinoSidebarCollapsedBarTransitionBuilder? transitionBuilder,
  CupertinoSidebarStyle style = CupertinoSidebarStyle.liquid,
  Color? backgroundColor,
  CupertinoSidebarItemStyle? collapsedBarItemStyle,
  CupertinoSidebarToolbarGeometry toolbarGeometry =
      CupertinoSidebarToolbarGeometry.standard,
  double? minimumDestinationExtent,
  double? collapsedBarHeight,
  bool collapsedBarSeparator = false,
  bool showIcons = false,
  bool selectFromController = true,
  int? selectedIndex,
  CupertinoSidebarToggleBuilder? toggleButtonBuilder,
}) {
  final effectiveCollapsedBarHeight =
      collapsedBarHeight ?? toolbarGeometry.collapsedBarHeight;
  return MaterialApp(
    theme: materialTheme,
    home: Directionality(
      textDirection: textDirection,
      child: CupertinoTheme(
        data: theme,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return CupertinoSidebar(
              controller: controller,
              collapsedBarController: collapsedBarController,
              collapsedBarPlacement: collapsedBarPlacement,
              style: style,
              backgroundColor: backgroundColor,
              toolbarGeometry: toolbarGeometry,
              content: const SizedBox.shrink(),
              collapsedBarHeight: collapsedBarHeight,
              collapsedBarSeparator: collapsedBarSeparator,
              collapsedBarMinimumDestinationExtent:
                  minimumDestinationExtent ??
                  kCupertinoSidebarCollapsedBarMeasuredWidth,
              collapsedBarTransitionBuilder:
                  transitionBuilder ??
                  CupertinoSidebarCollapsedBarTransition.drop,
              toggleButtonBuilder: toggleButtonBuilder,
              collapsedBar: CupertinoSidebarCollapsedBar(
                destinations: destinations,
                selectedIndex: selectFromController
                    ? controller.selection.primaryIndex
                    : selectedIndex,
                showIcons: showIcons,
                itemStyle: collapsedBarItemStyle,
                height: effectiveCollapsedBarHeight,
                onDestinationSelected: (index) =>
                    controller.select(SidebarPrimarySelection(index)),
              ),
              child: const CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: CupertinoSidebarMiddle(title: Text('Title')),
                ),
                child: _ReservedExtentLabel(),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _ReservedExtentLabel extends StatelessWidget {
  const _ReservedExtentLabel();

  @override
  Widget build(BuildContext context) {
    final reserved = SidebarLeadingScope.maybeOf(context)?.reservedExtent;
    return Text('reserved:$reserved');
  }
}

bool _collapsedBarPaintsOutsideNavigationBar(WidgetTester tester) {
  final capsule = tester.element(
    find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
  );
  final navigationBar = tester.renderObject<RenderBox>(
    find.byType(CupertinoNavigationBar),
  );
  final barBottom =
      navigationBar.localToGlobal(Offset.zero).dy + navigationBar.size.height;
  final shadowBottom =
      tester
          .getBottomLeft(
            find.byKey(const ValueKey('cupertino-sidebar-collapsed-capsule')),
          )
          .dy +
      4 +
      16;
  var clippedByNavigationBar = false;
  capsule.visitAncestorElements((ancestor) {
    if (ancestor.renderObject == navigationBar) {
      clippedByNavigationBar = true;
      return false;
    }
    return ancestor.widget is! Overlay;
  });
  return !clippedByNavigationBar && shadowBottom > barBottom;
}

bool _pointerIgnored(WidgetTester tester, Finder finder) {
  var ignored = false;
  tester.element(finder).visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is IgnorePointer) {
      ignored = widget.ignoring;
      return false;
    }
    return true;
  });
  return ignored;
}
