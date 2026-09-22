import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sidebar motion lasts 250 milliseconds', () {
    expect(kSidebarAnimationDuration, const Duration(milliseconds: 250));
  });

  testWidgets('tooltip builder receives the message and the child', (
    tester,
  ) async {
    const child = Text('Toggle');
    late String message;

    Widget buildTooltip(BuildContext context, String received, Widget wrapped) {
      message = received;
      return KeyedSubtree(key: const ValueKey('tooltip'), child: wrapped);
    }

    final NavigationTooltipBuilder builder = buildTooltip;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) => builder(context, 'Show sidebar', child),
        ),
      ),
    );

    expect(message, 'Show sidebar');
    expect(find.text('Toggle'), findsOneWidget);
    expect(find.byKey(const ValueKey('tooltip')), findsOneWidget);
  });
}
