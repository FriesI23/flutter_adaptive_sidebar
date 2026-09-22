import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_adaptive_sidebar/src/cupertino/cupertino_sidebar_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  testWidgets('button has no Material tooltip unless one is supplied', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var presses = 0;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoSidebarButton(
          focusNode: focusNode,
          label: 'Show sidebar',
          onPressed: () => presses++,
          buttonKey: const ValueKey('toggle'),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsNothing);
    await tester.tap(find.byKey(const ValueKey('toggle')));
    expect(presses, 1);
  });

  testWidgets('sidebar uses the supplied tooltip builder', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: true,
      tooltipBuilder: (context, message, child) =>
          KeyedSubtree(key: const ValueKey('injected-tooltip'), child: child),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('injected-tooltip')), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });
}
