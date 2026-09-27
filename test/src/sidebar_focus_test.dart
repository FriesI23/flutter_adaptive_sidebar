import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tap outside the material rail clears destination focus', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('material-rail-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.text('Body'));
    await tester.pump();

    expect(_focusNode(tester, destination).hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets('tap outside the cupertino panel clears destination focus', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await pumpSidebar(tester, controller: controller, cupertino: true);
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('cupertino-sidebar-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.text('Body'));
    await tester.pump();

    expect(_focusNode(tester, destination).hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets('tab reaches cupertino destinations on macOS', (tester) async {
    useLargeTestWindow(tester);
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);
      await pumpSidebar(tester, controller: controller, cupertino: true);
      await tester.pumpAndSettle();

      final destination = find.byKey(
        const ValueKey('cupertino-sidebar-destination-0'),
      );
      var reachedDestination = false;
      for (var index = 0; index < 5; index += 1) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        if (_focusNode(tester, destination).hasFocus) {
          reachedDestination = true;
          break;
        }
      }

      expect(reachedDestination, isTrue);
      final decoration = tester
          .widget<DecoratedBox>(
            find.descendant(
              of: destination,
              matching: find.byType(DecoratedBox),
            ),
          )
          .decoration;
      expect((decoration as BoxDecoration).border, isNotNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('tap outside the collapsed bar clears destination focus', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController(initialExpanded: false);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return CupertinoSidebar(
              controller: controller,
              content: const SizedBox.shrink(),
              collapsedBar: CupertinoSidebarCollapsedBar(
                destinations: sidebarDestinations,
                selectedIndex: controller.selection.primaryIndex,
                onDestinationSelected: (index) =>
                    controller.select(SidebarPrimarySelection(index)),
              ),
              child: const CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  middle: CupertinoSidebarMiddle(title: Text('Title')),
                ),
                child: Text('Body'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('cupertino-sidebar-collapsed-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    expect(controller.selection, const SidebarPrimarySelection(1));

    await tester.tap(find.text('Body'));
    await tester.pump();

    expect(_focusNode(tester, destination).hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });

  testWidgets('a focused page field is not cleared by the sidebar', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: false,
      body: const Material(child: TextField(key: ValueKey('page-field'))),
    );
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('material-rail-destination-1'),
    );
    await _selectAndFocus(tester, destination);
    final destinationFocus = _focusNode(tester, destination);

    await tester.tap(find.byKey(const ValueKey('page-field')));
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );
    expect(destinationFocus.hasFocus, isFalse);
    expect(controller.selection, const SidebarPrimarySelection(1));
  });
}

Future<void> _selectAndFocus(WidgetTester tester, Finder destination) async {
  await tester.tap(destination);
  await tester.pumpAndSettle();
  final node = _focusNode(tester, destination);
  node.requestFocus();
  await tester.pump();
  expect(node.hasFocus, isTrue);
}

FocusNode _focusNode(WidgetTester tester, Finder destination) {
  final text = find.descendant(of: destination, matching: find.byType(Text));
  expect(text, findsWidgets);
  return Focus.of(tester.element(text.first));
}
