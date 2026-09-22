import 'package:flutter/widgets.dart';

/// Physical insets that keep navigation chrome clear of system controls.
///
/// iPadOS window controls and corner-adapted safe areas are not read here.
/// Place a [NavigationObstructionScope] above the navigation, or use
/// `IosNavigationObstruction` to fill this value from
/// `ios_window_control_layout`.
@immutable
class NavigationObstruction {
  /// Creates obstruction insets.
  const NavigationObstruction({
    this.sidebar = EdgeInsets.zero,
    this.toolbar = EdgeInsets.zero,
  });

  /// Insets for sidebar chrome, in physical screen coordinates.
  final EdgeInsets sidebar;

  /// Insets for the page toolbar when it must clear window controls.
  final EdgeInsets toolbar;

  @override
  bool operator ==(Object other) =>
      other is NavigationObstruction &&
      other.sidebar == sidebar &&
      other.toolbar == toolbar;

  @override
  int get hashCode => Object.hash(sidebar, toolbar);
}

/// Exposes [NavigationObstruction] to sidebar renderers.
class NavigationObstructionScope extends InheritedWidget {
  /// Creates a scope for [obstruction].
  const NavigationObstructionScope({
    super.key,
    required this.obstruction,
    required super.child,
  });

  /// Insets consumed by navigation chrome in this subtree.
  final NavigationObstruction obstruction;

  /// The obstruction from [context], or an empty value when no scope exists.
  static NavigationObstruction of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<NavigationObstructionScope>()
          ?.obstruction ??
      const NavigationObstruction();

  @override
  bool updateShouldNotify(NavigationObstructionScope oldWidget) =>
      obstruction != oldWidget.obstruction;
}
