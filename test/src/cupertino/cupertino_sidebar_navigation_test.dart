import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auxiliary selection clears the primary highlight', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: SidebarFooterHost(controller: controller, cupertino: true),
      ),
    );
    await tester.pumpAndSettle();

    const footerKey = 'cupertino-sidebar-auxiliary-destination-0';
    const homeKey = 'cupertino-sidebar-destination-0';
    await tester.tap(find.byKey(const ValueKey(footerKey)));
    await tester.pumpAndSettle();
    expect(destinationSelected(tester, footerKey, cupertino: true), isTrue);
    expect(destinationSelected(tester, homeKey, cupertino: true), isFalse);

    await tester.tap(find.byKey(const ValueKey(homeKey)));
    await tester.pumpAndSettle();
    expect(destinationSelected(tester, footerKey, cupertino: true), isFalse);
    expect(destinationSelected(tester, homeKey, cupertino: true), isTrue);
    expect(controller.selection, const SidebarPrimarySelection(0));
  });

  testWidgets('edge retains theme-colored interaction across rebuilds', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    late StateSetter rebuild;
    var revision = 0;
    SidebarDestinationSelection? pressedSelection;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return CupertinoSidebar.edge(
              controller: controller,
              content: CupertinoSidebarNavigation(
                destinations: sidebarDestinations.sublist(0, 2),
                selection: const SidebarAuxiliarySelection(1),
                onSelectionChanged: (selection) {
                  pressedSelection = selection;
                },
                auxiliaryDestinations: const [
                  sidebarFooterDestination,
                  AdaptiveNavigationDestination(
                    label: 'Settings',
                    icons: NavigationDestinationIcons(
                      material: Icon(Icons.settings_outlined),
                      materialSelected: Icon(Icons.settings),
                      cupertino: Icon(CupertinoIcons.settings),
                      cupertinoSelected: Icon(CupertinoIcons.settings_solid),
                    ),
                  ),
                ],
              ),
              child: Text('Body $revision'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final action = find.byKey(
      const ValueKey('cupertino-sidebar-auxiliary-destination-0'),
    );
    final settings = find.byKey(
      const ValueKey('cupertino-sidebar-auxiliary-destination-1'),
    );
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(pressedSelection, const SidebarAuxiliarySelection(0));
    final primaryColor = CupertinoTheme.of(
      tester.element(settings),
    ).primaryColor;
    expect(_fill(tester, action), primaryColor.withValues(alpha: 1));
    expect(_fill(tester, settings), primaryColor.withValues(alpha: 0.14));

    rebuild(() => revision += 1);
    await tester.pumpAndSettle();
    expect(find.text('Body 1'), findsOneWidget);
    expect(_fill(tester, action), primaryColor.withValues(alpha: 1));
    expect(_fill(tester, settings), primaryColor.withValues(alpha: 0.14));

    await tester.tap(find.text('Body 1'));
    await tester.pumpAndSettle();
    expect(_fill(tester, action), isNull);
    expect(_fill(tester, settings), primaryColor.withValues(alpha: 0.14));
  });

  testWidgets('edge keeps the selected primary active after rebuild', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    var selection = const SidebarPrimarySelection(0);
    var revision = 0;
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return CupertinoSidebar.edge(
              controller: controller,
              content: CupertinoSidebarNavigation(
                destinations: sidebarDestinations.sublist(0, 2),
                selection: selection,
                onSelectionChanged: (value) {
                  setState(() => selection = value as SidebarPrimarySelection);
                },
              ),
              child: Text('Body $revision'),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final destination = find.byKey(
      const ValueKey('cupertino-sidebar-destination-1'),
    );
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(
      tester.widget<CupertinoSidebarDestination>(destination).selected,
      isTrue,
    );
    expect(
      tester.widget<CupertinoSidebarDestination>(destination).active,
      isTrue,
    );
    final primaryColor = CupertinoTheme.of(
      tester.element(destination),
    ).primaryColor;
    expect(_fill(tester, destination), primaryColor.withValues(alpha: 1));

    rebuild(() => revision += 1);
    await tester.pumpAndSettle();
    expect(find.text('Body 1'), findsOneWidget);
    expect(
      tester.widget<CupertinoSidebarDestination>(destination).active,
      isTrue,
    );
    expect(_fill(tester, destination), primaryColor.withValues(alpha: 1));
  });
}

Color? _fill(WidgetTester tester, Finder destination) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: destination, matching: find.byType(DecoratedBox)),
  );
  return (box.decoration as BoxDecoration).color;
}
