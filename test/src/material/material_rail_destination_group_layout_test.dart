import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/src/material/material_rail_destination_group_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('child sits below the largest gap that fits', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 100,
          height: 200,
          child: MaterialRailDestinationGroupLayout(
            minimumGap: 8,
            maximumGap: 40,
            child: SizedBox(key: ValueKey('child'), width: 10, height: 20),
          ),
        ),
      ),
    );

    final layoutTop = tester
        .getTopLeft(find.byType(MaterialRailDestinationGroupLayout))
        .dy;
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('child'))).dy - layoutTop,
      40,
    );
  });

  testWidgets('gap shrinks to its minimum when height is tight', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UnconstrainedBox(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 100,
            height: 28,
            child: MaterialRailDestinationGroupLayout(
              minimumGap: 8,
              maximumGap: 40,
              child: SizedBox(key: ValueKey('child'), width: 10, height: 20),
            ),
          ),
        ),
      ),
    );

    final layoutTop = tester
        .getTopLeft(find.byType(MaterialRailDestinationGroupLayout))
        .dy;
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('child'))).dy - layoutTop,
      8,
    );
  });
}
