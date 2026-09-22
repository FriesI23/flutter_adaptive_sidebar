import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../harness/sidebar_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sidebar publishes collapsed and expanded widths', (
    tester,
  ) async {
    useLargeTestWindow(tester);
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    await pumpSidebar(
      tester,
      controller: controller,
      cupertino: false,
      content: const _MetricsProbe(),
    );
    await tester.pumpAndSettle();

    expect(find.text('96'), findsOneWidget);
    expect(find.textContaining('expanded'), findsOneWidget);
  });

  testWidgets('lookup fails outside a sidebar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            MaterialSidebarMetrics.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(tester.takeException(), isA<AssertionError>());
  });
}

class _MetricsProbe extends StatelessWidget {
  const _MetricsProbe();

  @override
  Widget build(BuildContext context) {
    final metrics = MaterialSidebarMetrics.of(context);
    return Column(
      children: [
        Text(metrics.collapsedWidth.round().toString()),
        Text('expanded ${metrics.expandedWidth.round()}'),
      ],
    );
  }
}
