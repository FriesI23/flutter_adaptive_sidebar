import 'package:flutter/cupertino.dart';
import 'package:flutter_adaptive_sidebar/src/cupertino/cupertino_floating_surface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opaque color skips the backdrop blur', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoFloatingGlassSurface(
          backgroundColor: Color(0xFF112233),
          child: SizedBox.expand(),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF112233),
      ),
      findsOneWidget,
    );
  });

  testWidgets('translucent color blurs the backdrop', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoFloatingGlassSurface(
          backgroundColor: Color(0x80112233),
          child: SizedBox.expand(),
        ),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('dark mode draws a hairline border', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        theme: CupertinoThemeData(brightness: Brightness.dark),
        home: CupertinoFloatingGlassSurface(
          backgroundColor: Color(0xFF112233),
          child: SizedBox.expand(),
        ),
      ),
    );

    final border = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.border)
        .whereType<Border>()
        .single;
    expect(border.top.width, 0.5);
  });
}
