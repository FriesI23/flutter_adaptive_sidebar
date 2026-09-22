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
        home: SidebarFooterHost(controller: controller, cupertino: false),
      ),
    );
    await tester.pumpAndSettle();

    const footerKey = 'material-rail-auxiliary-destination-0';
    const homeKey = 'material-rail-destination-0';
    await tester.tap(find.byKey(const ValueKey(footerKey)));
    await tester.pumpAndSettle();
    expect(destinationSelected(tester, footerKey, cupertino: false), isTrue);
    expect(destinationSelected(tester, homeKey, cupertino: false), isFalse);

    await tester.tap(find.byKey(const ValueKey(homeKey)));
    await tester.pumpAndSettle();
    expect(destinationSelected(tester, footerKey, cupertino: false), isFalse);
    expect(destinationSelected(tester, homeKey, cupertino: false), isTrue);
    expect(controller.selectedIndex, 0);
  });

  testWidgets('navigation requires the sidebar metrics', (tester) async {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MaterialSidebarNavigation(
          destinations: sidebarDestinations,
          selectedIndex: 0,
          onDestinationSelected: controller.select,
        ),
      ),
    );

    expect(tester.takeException(), isA<AssertionError>());
  });
}
