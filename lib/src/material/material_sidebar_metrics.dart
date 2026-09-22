import 'package:flutter/widgets.dart';

/// Rail geometry published by `MaterialSidebar` for its content.
class MaterialSidebarMetrics extends InheritedWidget {
  /// Creates metrics for a sidebar panel.
  const MaterialSidebarMetrics({
    super.key,
    required this.extended,
    required this.collapsedWidth,
    required this.expandedWidth,
    required super.child,
  });

  /// Whether the rail is using its expanded width.
  final bool extended;

  /// Width of the collapsed rail.
  final double collapsedWidth;

  /// Width of the expanded rail.
  final double expandedWidth;

  /// The metrics from the enclosing `MaterialSidebar`.
  static MaterialSidebarMetrics of(BuildContext context) {
    final metrics = context
        .dependOnInheritedWidgetOfExactType<MaterialSidebarMetrics>();
    assert(
      metrics != null,
      'MaterialSidebarNavigation must be placed in a MaterialSidebar.',
    );
    return metrics!;
  }

  @override
  bool updateShouldNotify(MaterialSidebarMetrics oldWidget) =>
      extended != oldWidget.extended ||
      collapsedWidth != oldWidget.collapsedWidth ||
      expandedWidth != oldWidget.expandedWidth;
}
