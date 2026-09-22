import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  testWidgets('selected destination exposes its semantics label', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoSidebarDestination(
          destination: sidebarDestinations.first,
          selected: true,
          onPressed: () => presses++,
        ),
      ),
    );

    expect(
      tester
          .widget<CupertinoSidebarDestination>(
            find.byType(CupertinoSidebarDestination),
          )
          .selected,
      isTrue,
    );
    expect(
      tester.getSemantics(find.byType(CupertinoSidebarDestination)).label,
      'Home',
    );
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<CupertinoButton>(),
      isNull,
    );
    await tester.tap(find.byType(CupertinoButton));
    expect(presses, 1);
  });
}
