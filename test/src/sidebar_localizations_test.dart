import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../harness/sidebar_harness.dart';

void main() {
  for (final cupertino in [false, true]) {
    for (final chinese in [false, true]) {
      testWidgets(
        '${cupertino ? 'Cupertino' : 'Material'} toggle uses standalone '
        '${chinese ? 'Chinese' : 'English'} localizations',
        (tester) async {
          useLargeTestWindow(tester);
          final controller = AdaptiveNavigationController();
          addTearDown(controller.dispose);

          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(chinese ? 'zh' : 'en'),
              supportedLocales: const [Locale('en'), Locale('zh')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: sidebarHost(controller: controller, cupertino: cupertino),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            cupertino
                ? find.bySemanticsLabel(chinese ? '收起' : 'Collapse')
                : find.byTooltip(chinese ? '收起' : 'Collapse'),
            findsWidgets,
          );
          controller.expanded = false;
          await tester.pumpAndSettle();
          expect(
            cupertino
                ? find.bySemanticsLabel(chinese ? '展开' : 'Expand')
                : find.byTooltip(chinese ? '展开' : 'Expand'),
            findsWidgets,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final customLabels in [false, true]) {
    testWidgets('CupertinoApp supports ${customLabels ? 'custom' : 'fallback'} '
        'toggle labels without Material localizations', (tester) async {
      useLargeTestWindow(tester);
      final controller = AdaptiveNavigationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        CupertinoApp(
          locale: const Locale('zh'),
          supportedLocales: const [Locale('zh')],
          localizationsDelegates: GlobalCupertinoLocalizations.delegates,
          home: CupertinoSidebar(
            controller: controller,
            expandLabel: customLabels ? '显示导航' : null,
            collapseLabel: customLabels ? '隐藏导航' : null,
            content: const SizedBox.expand(),
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(customLabels ? '隐藏导航' : 'Collapse'),
        findsWidgets,
      );
      controller.expanded = false;
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(customLabels ? '显示导航' : 'Expand'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
