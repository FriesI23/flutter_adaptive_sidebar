import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unsupported platforms publish an empty obstruction', (
    tester,
  ) async {
    late NavigationObstruction obstruction;
    await tester.pumpWidget(
      IosNavigationObstruction(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              obstruction = NavigationObstructionScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(obstruction.sidebar, EdgeInsets.zero);
    expect(obstruction.toolbar, EdgeInsets.zero);
  });
}
