import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equal insets compare equal', () {
    const first = NavigationObstruction(
      sidebar: EdgeInsets.only(left: 8),
      toolbar: EdgeInsets.only(top: 4),
    );
    const second = NavigationObstruction(
      sidebar: EdgeInsets.only(left: 8),
      toolbar: EdgeInsets.only(top: 4),
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  testWidgets('missing scope reads as empty insets', (tester) async {
    late NavigationObstruction obstruction;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            obstruction = NavigationObstructionScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(obstruction.sidebar, EdgeInsets.zero);
    expect(obstruction.toolbar, EdgeInsets.zero);
  });

  testWidgets('scope publishes its obstruction', (tester) async {
    const obstruction = NavigationObstruction(
      sidebar: EdgeInsets.only(left: 12),
    );
    late NavigationObstruction read;
    await tester.pumpWidget(
      const NavigationObstructionScope(
        obstruction: obstruction,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: _ObstructionReader(),
        ),
      ),
    );
    read = tester
        .widget<_ObstructionReader>(find.byType(_ObstructionReader))
        .value;

    expect(read, obstruction);
  });
}

class _ObstructionReader extends StatelessWidget {
  const _ObstructionReader();

  NavigationObstruction get value => _value;
  static late NavigationObstruction _value;

  @override
  Widget build(BuildContext context) {
    _value = NavigationObstructionScope.of(context);
    return const SizedBox();
  }
}
