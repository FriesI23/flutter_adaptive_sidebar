import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('style and presence controls keep the selected destination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
    await tester.pumpAndSettle();

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
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
    expect(find.text('Search'), findsWidgets);
    final segmentStyle = DefaultTextStyle.of(
      tester.element(find.text('Auto')),
    ).style;
    expect(segmentStyle.decoration, TextDecoration.none);
    expect(segmentStyle.fontFamily, 'CupertinoSystemText');
    final backdrop = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('cupertino-sidebar-backdrop')),
    );
    expect(
      CupertinoTheme.of(
        tester.element(find.widgetWithText(Center, 'Search')),
      ).scaffoldBackgroundColor,
      backdrop.color,
    );

    await tester.tap(find.text('Coll'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('cupertino-sidebar-beside-host')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('cupertino-sidebar-panel')), findsNothing);
    expect(find.text('Search'), findsWidgets);

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

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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

    await tester.tap(find.text('Expand'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto'));
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

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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
    await tester.tap(find.byTooltip('Appearance'));
    await tester.pumpAndSettle();

    final settingsContext = tester.element(find.text('Preferred width'));
    expect(Theme.of(settingsContext).brightness, Brightness.dark);
    expect(CupertinoTheme.of(settingsContext).primaryColor, isNot(Colors.blue));

    await tester.tap(find.byTooltip('Use Cupertino'));
    await tester.pumpAndSettle();
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

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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

    await tester.tap(find.text('Coll'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsNothing);
    expect(find.text('3 due'), findsNothing);
    expect(find.byKey(const ValueKey('custom-sidebar-lists')), findsOneWidget);

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
  });

  testWidgets('auto width setting changes when the sidebar collapses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AdaptiveSidebarExampleApp());
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
}
