import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_adaptive_sidebar_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cupertino example uses the 54pt sidebar navigation row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: true));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<CupertinoNavigationBar>(
      find.byType(CupertinoNavigationBar).first,
    );
    expect(navigationBar.preferredSize.height, 54);
  });

  testWidgets('Cupertino example cycles default and custom sidebar tints', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: true));
    await tester.pumpAndSettle();

    final colorButton = find.byKey(const ValueKey('theme-color-button'));
    BuildContext destinationContext() => tester.element(
      find.byKey(const ValueKey('cupertino-sidebar-destination-0')),
    );
    expect(
      CupertinoTheme.of(destinationContext()).primaryColor,
      const CupertinoThemeData().primaryColor,
    );
    await tester.tap(find.byKey(const ValueKey('glass-style-button')));
    await tester.pumpAndSettle();

    await tester.tap(colorButton);
    await tester.pumpAndSettle();
    expect(
      CupertinoTheme.of(destinationContext()).primaryColor,
      CupertinoColors.systemPurple,
    );
    final sideHighlight = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('cupertino-sidebar-destination-0')),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      (sideHighlight.decoration as BoxDecoration).color,
      CupertinoColors.systemPurple.withValues(alpha: 0.14),
    );
    final surface = find.byKey(const ValueKey('cupertino-sidebar-surface'));
    final edgeSource = Theme.of(
      tester.element(surface),
    ).extension<CupertinoSidebarThemeData>()!.edgeBackgroundColor!;
    final surfaceColor = tester.widget<ColoredBox>(
      find.descendant(of: surface, matching: find.byType(ColoredBox)).first,
    );
    expect(
      surfaceColor.color,
      edgeSource.withValues(alpha: kCupertinoSidebarEdgeFillAlpha),
    );

    await tester.tap(find.byKey(const ValueKey('cupertino-sidebar-toggle')));
    await tester.pumpAndSettle();
    final barHighlight = tester.widget<DecoratedBox>(
      find.byKey(
        const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
      ),
    );
    expect(
      (barHighlight.decoration as BoxDecoration).color,
      CupertinoColors.systemPurple.withValues(alpha: 0.14),
    );
    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    final capsuleColor = tester.widget<ColoredBox>(
      find.descendant(of: capsule, matching: find.byType(ColoredBox)).first,
    );
    expect(capsuleColor.color, edgeSource.withValues(alpha: 0.45));

    for (final expected in [
      CupertinoColors.systemTeal,
      CupertinoColors.systemOrange,
      const CupertinoThemeData().primaryColor,
    ]) {
      await tester.tap(colorButton);
      await tester.pumpAndSettle();
      expect(
        CupertinoTheme.of(
          tester.element(
            find.byKey(
              const ValueKey('cupertino-sidebar-collapsed-destination-0'),
            ),
          ),
        ).primaryColor,
        expected,
      );
    }
  });

  testWidgets(
    'Cupertino top inset exposes safe area and supports iOS offsets',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59);
      tester.view.viewPadding = const FakeViewPadding(top: 59);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);

      await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: true));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('cupertino-sidebar-auxiliary-destination-0')),
      );
      await tester.pumpAndSettle();

      final control = find.byKey(const ValueKey('toolbar-top-inset-control'));
      await Scrollable.ensureVisible(tester.element(control), alignment: 0.5);
      CupertinoSidebar sidebar() =>
          tester.widget<CupertinoSidebar>(find.byType(CupertinoSidebar));
      final togglePosition = find.byKey(
        const ValueKey('cupertino-sidebar-toggle-position'),
      );

      expect(
        sidebar().toolbarGeometry,
        CupertinoSidebarToolbarGeometry.standard,
      );
      expect(tester.getTopLeft(togglePosition).dy, 59);

      await tester.tap(find.text('Unified'));
      await tester.pumpAndSettle();
      expect(sidebar().toolbarGeometry.topInset, 10);
      expect(tester.getTopLeft(togglePosition).dy, 59);
      expect(sidebar().toolbarGeometry.height, 54);
      expect(sidebar().toolbarGeometry.collapsedBarHeight, 44);
      expect(
        tester
            .widget<CupertinoNavigationBar>(
              find.byType(CupertinoNavigationBar).first,
            )
            .preferredSize
            .height,
        54,
      );

      await Scrollable.ensureVisible(tester.element(control), alignment: 0.5);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      final slider = find.byKey(const ValueKey('toolbar-top-inset-slider'));
      expect(find.text('Configured 10 · Safe area 59'), findsOneWidget);
      expect(tester.widget<CupertinoSlider>(slider).max, 96);
      expect(tester.widget<CupertinoSlider>(slider).divisions, 96);
      tester.widget<CupertinoSlider>(slider).onChanged?.call(72);
      await tester.pumpAndSettle();
      expect(find.text('Configured 72 · Safe area 59'), findsOneWidget);
      expect(sidebar().toolbarGeometry.topInset, 72);
      expect(tester.getTopLeft(togglePosition).dy, 72);
      expect(sidebar().toolbarGeometry.height, 54);
      expect(sidebar().toolbarGeometry.collapsedBarHeight, 44);

      await Scrollable.ensureVisible(tester.element(control), alignment: 0.5);
      await tester.tap(
        find.descendant(of: control, matching: find.text('Auto')),
      );
      await tester.pumpAndSettle();
      expect(
        sidebar().toolbarGeometry,
        CupertinoSidebarToolbarGeometry.standard,
      );
      expect(slider, findsNothing);
    },
  );

  testWidgets('style and presence controls keep the selected destination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();

    final styleButton = tester.getTopLeft(find.byTooltip('Use Cupertino'));
    final title = tester.getTopLeft(find.text('Adaptive sidebar'));
    expect(styleButton.dx, greaterThan(title.dx));

    expect(find.text('Home'), findsWidgets);
    expect(find.byKey(const ValueKey('rail-panel')), findsOneWidget);
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('rail-panel'))),
      ),
      TextDirection.ltr,
    );

    await tester.tap(find.byKey(const ValueKey('direction-button')));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('rail-panel'))),
      ),
      TextDirection.rtl,
    );

    await tester.tap(find.byKey(const ValueKey('direction-button')));
    await tester.pumpAndSettle();
    expect(
      Directionality.of(
        tester.element(find.byKey(const ValueKey('rail-panel'))),
      ),
      TextDirection.ltr,
    );
    expect(find.text('Item 0'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('material-rail-destination-1')));
    await tester.pumpAndSettle();
    expect(find.text('Search'), findsWidgets);

    await tester.tap(find.byTooltip('Use Cupertino'));
    await tester.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<CupertinoButton>(),
      isNull,
    );
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
    expect(find.text('Search'), findsWidgets);
    final backdrop = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('cupertino-sidebar-backdrop')),
    );
    expect(
      CupertinoTheme.of(
        tester.element(find.widgetWithText(Center, 'Search')),
      ).scaffoldBackgroundColor,
      backdrop.color,
    );
    await tester.tap(
      find.byKey(const ValueKey('cupertino-sidebar-auxiliary-destination-0')),
    );
    await tester.pumpAndSettle();
    final expansionControl = find.byKey(const ValueKey('expansion-control'));
    final segmentStyle = DefaultTextStyle.of(
      tester.element(
        find.descendant(of: expansionControl, matching: find.text('Auto')),
      ),
    ).style;
    expect(segmentStyle.decoration, TextDecoration.none);
    expect(segmentStyle.fontFamily, 'CupertinoSystemText');

    await Scrollable.ensureVisible(
      tester.element(find.text('Coll')),
      alignment: 0.5,
    );
    await tester.tap(find.text('Coll'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cupertino-sidebar-panel')), findsNothing);
    expect(find.text('Search'), findsWidgets);

    await Scrollable.ensureVisible(
      tester.element(find.text('Expand')),
      alignment: 0.5,
    );
    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-panel')),
      findsOneWidget,
    );
  });

  testWidgets('extend button centers on the material toolbar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();

    final toggle = tester.getRect(
      find.byKey(const ValueKey('rail-toggle-button')),
    );
    final title = tester.getRect(find.text('Adaptive sidebar'));
    expect(toggle.center.dy, title.center.dy);
  });

  testWidgets('portrait auto mode collapses the sidebar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('rail-panel')), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('rail-panel'))).width, 96);
  });

  testWidgets('manual toggle pauses automatic expansion', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );

    await tester.tap(find.byKey(const ValueKey('rail-toggle-button')));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('rail-panel'))).width, 96);

    tester.view.physicalSize = const Size(1300, 800);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('rail-panel'))).width, 96);

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('material-rail-auxiliary-destination-0')),
        matching: find.byType(TextButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('expansion-control')),
        matching: find.text('Auto'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );
  });

  testWidgets('settings and appearance follow the shared theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('material-rail-auxiliary-destination-0')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sidebar-settings')), findsOneWidget);
    expect(find.text('Preferred width'), findsOneWidget);
    expect(find.text('Custom tooltip'), findsOneWidget);

    await tester.tap(find.byTooltip('Appearance'));
    await tester.pumpAndSettle();
    final lightBackground = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('example-background')),
    );
    final lightDecoration = lightBackground.decoration as BoxDecoration;
    expect(lightDecoration.gradient, isNull);
    expect(lightDecoration.color?.toARGB32(), CupertinoColors.white.toARGB32());

    await tester.tap(find.byTooltip('Appearance'));
    await tester.pumpAndSettle();
    final darkBackground = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('example-background')),
    );
    final darkDecoration = darkBackground.decoration as BoxDecoration;
    expect(darkDecoration.gradient, isNull);
    expect(darkDecoration.color?.toARGB32(), CupertinoColors.black.toARGB32());

    final settingsContext = tester.element(find.text('Preferred width'));
    expect(Theme.of(settingsContext).brightness, Brightness.dark);
    expect(CupertinoTheme.of(settingsContext).primaryColor, isNot(Colors.blue));

    await tester.tap(find.byTooltip('Use Cupertino'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-color-button')));
    await tester.pumpAndSettle();
    final tintedBackground = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('example-background')),
    );
    final tintedGradient =
        (tintedBackground.decoration as BoxDecoration).gradient!
            as LinearGradient;
    expect(tintedGradient.begin, Alignment.centerLeft);
    expect(tintedGradient.end, Alignment.centerRight);
    expect(
      CupertinoTheme.brightnessOf(
        tester.element(find.textContaining('Preferred width')),
      ),
      Brightness.dark,
    );
    expect(find.byType(CupertinoSwitch), findsWidgets);
  });

  testWidgets('auto collapses once the window is narrower than 800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );

    tester.view.physicalSize = const Size(760, 500);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('rail-panel'))).width, 96);

    tester.view.physicalSize = const Size(900, 500);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );
  });

  testWidgets('settings can replace the navigation list with custom content', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('material-rail-auxiliary-destination-0')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Custom sidebar content'));
    await tester.tap(find.text('Custom sidebar content'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('custom-sidebar-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('material-rail-primary-scroll-view')),
      findsNothing,
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('3 due'), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('Coll')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coll'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsNothing);
    expect(find.text('3 due'), findsNothing);
    expect(find.byKey(const ValueKey('custom-sidebar-lists')), findsOneWidget);

    await Scrollable.ensureVisible(
      tester.element(find.text('Expand')),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('custom-sidebar-note')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Center, 'Note'), findsOneWidget);

    await tester.tap(find.byTooltip('Use Cupertino'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('custom-sidebar-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-destination-list')),
      findsNothing,
    );
    expect(find.widgetWithText(Center, 'Note'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    final listsStyle = DefaultTextStyle.of(
      tester.element(find.text('Lists')),
    ).style;
    expect(listsStyle.decoration, TextDecoration.none);
    expect(listsStyle.fontFamily, 'CupertinoSystemText');
    expect(listsStyle.color, isNot(const Color(0xD0FF0000)));

    await tester.tap(
      find.byKey(const ValueKey('custom-sidebar-destination-0')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    final note = find.byKey(const ValueKey('custom-sidebar-note'));
    final noteText = find.descendant(of: note, matching: find.text('Note'));
    var reachedNote = false;
    for (var index = 0; index < 20; index += 1) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      if (Focus.of(tester.element(noteText)).hasFocus) {
        reachedNote = true;
        break;
      }
    }
    expect(reachedNote, isTrue);
    final noteDecoration = tester
        .widget<DecoratedBox>(
          find.descendant(of: note, matching: find.byType(DecoratedBox)),
        )
        .decoration;
    expect((noteDecoration as BoxDecoration).border, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Center, 'Note'), findsOneWidget);
  });

  testWidgets('auto width setting changes when the sidebar collapses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: false));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );

    await tester.tap(
      find.byKey(const ValueKey('material-rail-auxiliary-destination-0')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Auto width'));
    tester
        .widget<Slider>(
          find.descendant(
            of: find.widgetWithText(ListTile, 'Auto width'),
            matching: find.byType(Slider),
          ),
        )
        .onChanged!(1100);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const ValueKey('rail-panel'))).width, 96);

    tester
        .widget<Slider>(
          find.descendant(
            of: find.widgetWithText(ListTile, 'Auto width'),
            matching: find.byType(Slider),
          ),
        )
        .onChanged!(600);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );
  });

  testWidgets('cupertino app bar keeps blurring the gradient while scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: true));
    await tester.pumpAndSettle();

    final bar = find.byType(CupertinoNavigationBar);
    BackdropFilter barBlur() {
      return tester.widget<BackdropFilter>(
        find.descendant(of: bar, matching: find.byType(BackdropFilter)),
      );
    }

    expect(barBlur().enabled, isTrue);

    await tester.drag(find.text('Item 0'), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(barBlur().enabled, isTrue);
    final navigationBar = tester.widget<CupertinoNavigationBar>(bar);
    final scaffoldColor = CupertinoTheme.of(
      tester.element(bar),
    ).scaffoldBackgroundColor;
    final backgroundColor = navigationBar.backgroundColor!;
    expect(backgroundColor.r, scaffoldColor.r);
    expect(backgroundColor.g, scaffoldColor.g);
    expect(backgroundColor.b, scaffoldColor.b);
    expect(backgroundColor.a, 0);
  });

  testWidgets('apple platforms open the cupertino sidebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    try {
      for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        await tester.pumpWidget(
          AdaptiveSidebarExampleApp(key: ValueKey(platform)),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(
            const ValueKey('cupertino-sidebar-auxiliary-destination-0'),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
          findsOneWidget,
        );
        expect(find.text('Drop'), findsOneWidget);
      }

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        const AdaptiveSidebarExampleApp(key: ValueKey('android')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('rail-panel')), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('collapsed bar placement switches between anchored and fixed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: true));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('cupertino-sidebar-auxiliary-destination-0')),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Coll'));
    await tester.tap(find.text('Coll'));
    await tester.pumpAndSettle();

    final placementControl = find.byKey(
      const ValueKey('collapsed-bar-placement-control'),
    );
    await tester.ensureVisible(placementControl);
    final segmented = find.descendant(
      of: placementControl,
      matching: find.byType(
        CupertinoSlidingSegmentedControl<CupertinoSidebarCollapsedBarPlacement>,
      ),
    );
    expect(
      tester
          .widget<CupertinoSidebar>(find.byType(CupertinoSidebar))
          .collapsedBarPlacement,
      CupertinoSidebarCollapsedBarPlacement.toolbarAnchor,
    );

    tester
        .widget<
          CupertinoSlidingSegmentedControl<
            CupertinoSidebarCollapsedBarPlacement
          >
        >(segmented)
        .onValueChanged(CupertinoSidebarCollapsedBarPlacement.fixedToolbar);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<CupertinoSidebar>(find.byType(CupertinoSidebar))
          .collapsedBarPlacement,
      CupertinoSidebarCollapsedBarPlacement.fixedToolbar,
    );

    expect(
      find.byKey(const ValueKey('cupertino-sidebar-fixed-toolbar-host')),
      findsOneWidget,
    );
    expect(find.byType(CompositedTransformFollower), findsNothing);
    expect(find.byType(CompositedTransformTarget), findsNothing);

    final capsule = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-capsule'),
    );
    final capsuleElement = tester.element(capsule);
    final fixedCenter = tester.getCenter(capsule);
    await tester.tap(
      find.byKey(const ValueKey('collapsed-bar-placement-demo-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.element(capsule), same(capsuleElement));
    expect(tester.getCenter(capsule), fixedCenter);
    await tester.pumpAndSettle();
    expect(tester.getCenter(capsule), fixedCenter);
    expect(find.textContaining('Fixed toolbar is active'), findsOneWidget);
    expect(
      tester
          .getCenter(
            find.byKey(const ValueKey('collapsed-bar-placement-demo-title')),
          )
          .dx,
      lessThan(tester.view.physicalSize.width / 2),
    );
    final demoDescription = find.byKey(
      const ValueKey('collapsed-bar-placement-demo-description'),
    );
    final demoTextStyle = DefaultTextStyle.of(
      tester.element(demoDescription),
    ).style;
    expect(demoTextStyle.decoration, TextDecoration.none);
    expect(demoTextStyle.fontFamily, 'CupertinoSystemText');

    Navigator.of(tester.element(demoDescription)).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(placementControl);
    tester
        .widget<
          CupertinoSlidingSegmentedControl<
            CupertinoSidebarCollapsedBarPlacement
          >
        >(segmented)
        .onValueChanged(CupertinoSidebarCollapsedBarPlacement.toolbarAnchor);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-fixed-toolbar-host')),
      findsNothing,
    );
    expect(find.byType(CompositedTransformFollower), findsOneWidget);
    expect(find.byType(CompositedTransformTarget), findsOneWidget);

    final anchoredElement = tester.element(capsule);
    final anchoredCenter = tester.getCenter(capsule);
    await tester.tap(
      find.byKey(const ValueKey('collapsed-bar-placement-demo-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.element(capsule), same(anchoredElement));
    expect(tester.getCenter(capsule), isNot(anchoredCenter));
    expect(find.byType(CompositedTransformTarget), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.textContaining('Toolbar anchor is active'), findsOneWidget);

    Navigator.of(
      tester.element(
        find.byKey(const ValueKey('collapsed-bar-placement-demo-description')),
      ),
    ).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(CompositedTransformTarget), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.getCenter(capsule), anchoredCenter);
  });

  testWidgets('collapsed bar clears its selection off the primary page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp(cupertino: true));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('cupertino-sidebar-auxiliary-destination-0')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Coll'));
    await tester.tap(find.text('Coll'));
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
      find.byKey(const ValueKey('cupertino-sidebar-collapsed-destination-0')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Item 0'), findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('cupertino-sidebar-collapsed-selection-highlight'),
            ),
          )
          .isEmpty,
      isFalse,
    );
  });
}
