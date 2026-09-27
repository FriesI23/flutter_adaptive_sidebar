import 'package:flutter/widgets.dart';

/// Insets that keep navigation chrome clear of something covering the window.
///
/// Sidebars read this from [NavigationObstructionScope]. With no scope in the
/// tree, both insets are zero and the chrome stays where the sidebar placed
/// it. An app publishes its own insets; this package does not measure window
/// controls.
///
/// [sidebar] shifts the sidebar. [toolbar] shifts the page toolbar while a
/// Cupertino sidebar is collapsed.
@immutable
class NavigationObstruction {
  /// Creates obstruction insets.
  const NavigationObstruction({
    this.sidebar = EdgeInsets.zero,
    this.toolbar = EdgeInsets.zero,
  });

  /// Insets for the sidebar, in screen coordinates.
  final EdgeInsets sidebar;

  /// Insets for the page toolbar while a Cupertino sidebar is collapsed.
  final EdgeInsets toolbar;

  @override
  bool operator ==(Object other) =>
      other is NavigationObstruction &&
      other.sidebar == sidebar &&
      other.toolbar == toolbar;

  @override
  int get hashCode => Object.hash(sidebar, toolbar);
}

/// Publishes [obstruction] to sidebars below it.
///
/// Omit this widget when the navigation should not clear an obstruction.
class NavigationObstructionScope extends InheritedWidget {
  /// Creates a scope for [obstruction].
  const NavigationObstructionScope({
    super.key,
    required this.obstruction,
    required super.child,
  });

  /// Insets consumed by navigation chrome in this subtree.
  final NavigationObstruction obstruction;

  /// The obstruction from [context], or zero insets when no scope exists.
  static NavigationObstruction of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<NavigationObstructionScope>()
          ?.obstruction ??
      const NavigationObstruction();

  @override
  bool updateShouldNotify(NavigationObstructionScope oldWidget) =>
      obstruction != oldWidget.obstruction;
}
