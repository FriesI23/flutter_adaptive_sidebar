import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const icons = NavigationDestinationIcons(
    material: SizedBox(),
    materialSelected: SizedBox(),
    cupertino: SizedBox(),
    cupertinoSelected: SizedBox(),
  );

  test('semantics label falls back to the visible label', () {
    const destination = AdaptiveNavigationDestination(
      label: 'Home',
      icons: icons,
    );

    expect(destination.effectiveSemanticsLabel, 'Home');
  });

  test('semantics label uses the explicit override', () {
    const destination = AdaptiveNavigationDestination(
      label: 'Home',
      semanticsLabel: 'Go home',
      icons: icons,
    );

    expect(destination.effectiveSemanticsLabel, 'Go home');
  });
}
