import 'package:flutter/material.dart';

/// Optional colors and label type for a Material sidebar row.
///
/// Pass one to [MaterialWideNavigationRailButton] or
/// [MaterialSidebarNavigation]. A null field keeps the navigation-rail theme,
/// then the color scheme. The same style covers the collapsed icon rail and
/// the expanded labels.
///
/// [labelStyle] replaces only the fields it sets. The resolved selection
/// color replaces [TextStyle.color].
class MaterialSidebarItemStyle {
  /// Creates a partial override.
  const MaterialSidebarItemStyle({
    this.selectedColor,
    this.selectedForegroundColor,
    this.foregroundColor,
    this.labelStyle,
  });

  /// Fill of the selected indicator.
  final Color? selectedColor;

  /// Label and icon color while the row is selected.
  final Color? selectedForegroundColor;

  /// Label and icon color while the row is not selected.
  final Color? foregroundColor;

  /// Label typography merged over the row's default style.
  final TextStyle? labelStyle;

  /// [selectedColor], or [fallback] when this style omits it.
  static Color selectedColorOf(
    MaterialSidebarItemStyle? style,
    Color fallback,
  ) {
    return style?.selectedColor ?? fallback;
  }

  /// The label color for [selected], using each fallback when unset.
  static Color foregroundOf(
    MaterialSidebarItemStyle? style, {
    required bool selected,
    required Color selectedFallback,
    required Color unselectedFallback,
  }) {
    if (selected) {
      return style?.selectedForegroundColor ?? selectedFallback;
    }
    return style?.foregroundColor ?? unselectedFallback;
  }

  /// [labelStyle] merged over [fallback], then colored with [color].
  static TextStyle labelStyleOf(
    MaterialSidebarItemStyle? style, {
    required TextStyle fallback,
    required Color color,
  }) {
    return fallback.merge(style?.labelStyle).copyWith(color: color);
  }
}
