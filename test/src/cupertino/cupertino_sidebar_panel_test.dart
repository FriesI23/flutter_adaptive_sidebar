import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('panel content uses the Cupertino text style', (tester) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: true,
      content: const Text('Custom panel'),
    );
    await tester.pumpAndSettle();

    final style = DefaultTextStyle.of(
      tester.element(find.text('Custom panel')),
    ).style;
    expect(style.decoration, TextDecoration.none);
    expect(style.fontFamily, 'CupertinoSystemText');
    expect(style.color, isNot(const Color(0xD0FF0000)));
    expect(find.byType(CupertinoSidebarNavigation), findsNothing);
  });
}
