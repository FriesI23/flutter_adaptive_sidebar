import 'package:flutter/widgets.dart';

/// Internal interaction state shared by sidebar controls and navigation.
class CupertinoSidebarInteractionScope extends InheritedWidget {
  /// Creates an internal interaction-reset scope.
  const CupertinoSidebarInteractionScope({
    super.key,
    required this.outsideTapGeneration,
    this.enabled = true,
    required super.child,
  });

  /// Monotonically increasing token for actual taps outside the Sidebar.
  final int outsideTapGeneration;

  /// Whether this subtree currently accepts pointer interactions.
  final bool enabled;

  /// Whether interactions are enabled, or true outside a Sidebar.
  static bool isEnabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<
            CupertinoSidebarInteractionScope
          >()
          ?.enabled ??
      true;

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
    return outsideTapGeneration != oldWidget.outsideTapGeneration ||
        enabled != oldWidget.enabled;
  }
}
