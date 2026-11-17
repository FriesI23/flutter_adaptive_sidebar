// Deliberate legacy host to verify the migration diagnostic.
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('legacy MaterialApp explains how to migrate the host', (
    tester,
  ) async {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      legacy.MaterialApp(
        home: MaterialSidebar(
          controller: controller,
          content: const SizedBox.shrink(),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(
      error.toString(),
      contains('MaterialSidebar requires material_ui localizations.'),
    );
    expect(error.toString(), contains('package:material_ui/material_ui.dart'));
    expect(error.toString(), contains('package:flutter/material.dart'));
  });

  testWidgets('toggle collapses the rail to its collapsed extent', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('rail-panel'))).width,
      greaterThan(96),
    );

    await tester.tap(find.byKey(const ValueKey('rail-toggle-button')));
    await tester.pumpAndSettle();

    expect(controller.expanded, isFalse);
    expect(tester.getSize(find.byKey(const ValueKey('rail-panel'))).width, 96);
  });

  testWidgets('custom content does not require destinations', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: false,
      content: const Text('Custom rail'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custom rail'), findsOneWidget);
    expect(find.byType(MaterialSidebarNavigation), findsNothing);
  });

  testWidgets('obstruction insets pad the leading control', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: NavigationObstructionScope(
          obstruction: const NavigationObstruction(
            sidebar: EdgeInsets.only(left: 28),
          ),
          child: sidebarHost(controller: controller, cupertino: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final padding = tester.widget<Padding>(
      find.byKey(const ValueKey('rail-leading-safe-span')),
    );
    expect(padding.padding, const EdgeInsets.only(left: 28));
  });

  testWidgets('extend button centers on a standard toolbar', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.pumpAndSettle();

    final toggle = tester.getRect(
      find.byKey(const ValueKey('rail-toggle-button')),
    );
    expect(toggle.center.dy, kToolbarHeight / 2);
  });

  testWidgets('omitted tooltip builder uses a Material tooltip', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(tester, controller: controller, cupertino: false);
    await tester.pumpAndSettle();

    expect(find.byType(Tooltip), findsOneWidget);
  });
}
