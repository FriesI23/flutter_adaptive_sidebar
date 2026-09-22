import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_adaptive_sidebar/src/side_navigation_extent.dart'
    show SideNavigationResizeHandle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extent = SideNavigationExtent(
    200,
    minimum: 180,
    maximum: 360,
    rampStart: 600,
    rampEnd: 1600,
  );

  test('upper bound follows the window ramp', () {
    expect(extent.upperBoundAt(400), 180);
    expect(extent.upperBoundAt(600), 180);
    expect(extent.upperBoundAt(1600), 360);
    expect(extent.upperBoundAt(2000), 360);
    expect(extent.upperBoundAt(1100), 270);
  });

  test('fixed width stays inside the current upper bound', () {
    expect(extent.resolve(400), 180);
    expect(extent.resolve(1200), 200);
    expect(extent.resolve(1600), 200);
  });

  test('ratio selects a position in the available interval', () {
    const ratio = SideNavigationExtent.fromRatio(1);
    const minimum = SideNavigationExtent.fromRatio(0);

    expect(minimum.resolve(1600), 180);
    expect(ratio.resolve(1600), 360);
    expect(ratio.resolve(1100), 270);
  });

  test('clamp keeps a manual width inside the upper bound', () {
    expect(extent.clamp(100, windowWidth: 1200), 180);
    expect(extent.clamp(500, windowWidth: 1200), 288);
    expect(extent.clamp(220, windowWidth: 1200), 220);
  });

  testWidgets('resize handle flips the drag delta for right-to-left', (
    tester,
  ) async {
    final deltas = <double>[];

    Future<void> pump(TextDirection direction) {
      return tester.pumpWidget(
        Directionality(
          textDirection: direction,
          child: SideNavigationResizeHandle(
            hitExtent: 16,
            onResizeStart: () {},
            onResizeUpdate: deltas.add,
            onResizeEnd: () {},
          ),
        ),
      );
    }

    await pump(TextDirection.ltr);
    await tester.drag(
      find.byType(SideNavigationResizeHandle),
      const Offset(24, 0),
    );
    expect(deltas.last, greaterThan(0));

    await pump(TextDirection.rtl);
    await tester.drag(
      find.byType(SideNavigationResizeHandle),
      const Offset(24, 0),
    );
    expect(deltas.last, lessThan(0));
  });
}
