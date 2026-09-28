import 'package:flutter/widgets.dart';

/// Internal edge-sidebar interaction state shared with its navigation list.
class CupertinoSidebarInteractionScope extends InheritedWidget {
  /// Creates an internal interaction-reset scope.
  const CupertinoSidebarInteractionScope({
    super.key,
    required this.outsideTapGeneration,
    required super.child,
  });

  /// Monotonically increasing token for actual taps outside the Sidebar.
  final int outsideTapGeneration;

  /// Current outside-tap token, or zero outside a Sidebar.
  static int outsideTapGenerationOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
              CupertinoSidebarInteractionScope
            >()
            ?.outsideTapGeneration ??
        0;
  }

  @override
  bool updateShouldNotify(CupertinoSidebarInteractionScope oldWidget) {
    return outsideTapGeneration != oldWidget.outsideTapGeneration;
  }
}
