import 'package:flutter/cupertino.dart' show kMinInteractiveDimensionCupertino;
import 'package:flutter/widgets.dart';

/// Sidebar toggle geometry exposed to page app bars inside the body.
///
/// The sidebar owns the toggle button. Pages read this scope to reserve
/// leading space without reparenting that button.
class SidebarLeadingScope extends InheritedWidget {
  /// Creates a scope describing the sidebar toggle reservation.
  const SidebarLeadingScope({
    super.key,
    required this.toolbarAvoidance,
    required this.progress,
    required super.child,
  });

  /// Extent of the sidebar toggle button.
  static const double buttonExtent = kMinInteractiveDimensionCupertino;

  /// Extra physical toolbar space the page should avoid.
  final EdgeInsets toolbarAvoidance;

  /// Visibility progress for the reserved leading slot.
  ///
  /// Zero means the sidebar is open and the page does not reserve the slot.
  /// One means the sidebar is hidden and the page reserves the toggle.
  final double progress;

  /// Width reserved before the page-owned leading content.
  double get reservedExtent => buttonExtent * progress;

  /// The scope from [context], if one is present.
  static SidebarLeadingScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SidebarLeadingScope>();

  @override
  bool updateShouldNotify(SidebarLeadingScope oldWidget) =>
      toolbarAvoidance != oldWidget.toolbarAvoidance ||
      progress != oldWidget.progress;
}
