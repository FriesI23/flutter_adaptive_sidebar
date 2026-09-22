import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  testWidgets('press reports the destination and keeps its selected flag', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MaterialWideNavigationRailButton(
          slotKey: const ValueKey('slot'),
          buttonKey: const ValueKey('button'),
          animation: const AlwaysStoppedAnimation(1),
          collapsedRailWidth: 96,
          expandedRailWidth: 200,
          destination: sidebarDestinations.first,
          selected: true,
          onPressed: () => presses++,
        ),
      ),
    );

    expect(
      tester
          .widget<MaterialWideNavigationRailButton>(
            find.byType(MaterialWideNavigationRailButton),
          )
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('button')));
    expect(presses, 1);
  });
}
