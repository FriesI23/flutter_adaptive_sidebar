import 'package:flutter/widgets.dart';

/// Platform-specific icon pair for an [AdaptiveNavigationDestination].
///
/// Callers describe both renderers without reading the current platform.
class NavigationDestinationIcons {
  /// Creates an icon pair for Material and Cupertino navigation.
  const NavigationDestinationIcons({
    required this.material,
    required this.materialSelected,
    required this.cupertino,
    required this.cupertinoSelected,
  });

  /// Icon shown by Material navigation when the destination is not selected.
  final Widget material;

  /// Icon shown by Material navigation when the destination is selected.
  final Widget materialSelected;

  /// Icon shown by Cupertino navigation when the destination is not selected.
  final Widget cupertino;

  /// Icon shown by Cupertino navigation when the destination is selected.
  final Widget cupertinoSelected;
}

/// Description of a top-level navigation destination.
class AdaptiveNavigationDestination {
  /// Creates a destination with a visible [label] and platform icons.
  const AdaptiveNavigationDestination({
    required this.label,
    required this.icons,
    this.semanticsLabel,
  });

  /// Visible short label for the destination.
  final String label;

  /// Accessibility label, falling back to [label] when omitted.
  final String? semanticsLabel;

  /// Material and Cupertino default and selected icons.
  final NavigationDestinationIcons icons;

  /// Label used by semantics.
  String get effectiveSemanticsLabel => semanticsLabel ?? label;
}
