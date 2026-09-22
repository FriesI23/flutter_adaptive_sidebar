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
    expect(controller.selectedIndex, 0);
  });
}
