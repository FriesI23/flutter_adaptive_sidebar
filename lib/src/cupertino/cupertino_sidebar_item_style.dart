import 'package:flutter/cupertino.dart';

/// Optional colors and label type for a Cupertino sidebar row.
///
/// Pass one to [CupertinoSidebarDestination], [CupertinoSidebarNavigation], or
/// [CupertinoSidebarCollapsedBar]. A null field keeps that row's default: the
/// side capsule follows liquid or edge, and the collapsed bar keeps its
/// measured label style.
///
/// [labelStyle] replaces only the fields it sets. The resolved selection
/// color replaces [TextStyle.color].
class CupertinoSidebarItemStyle {
  /// Creates a partial override.
  const CupertinoSidebarItemStyle({
    this.selectedColor,
    this.selectedForegroundColor,
    this.foregroundColor,
    this.labelStyle,
  });

  /// Fill of the selected capsule, or of the collapsed highlight.
  final Color? selectedColor;

  /// Label and icon color while the row is selected.
  final Color? selectedForegroundColor;

  /// Label and icon color while the row is not selected.
  final Color? foregroundColor;

  /// Label typography merged over the row's default style.
  final TextStyle? labelStyle;

  /// [selectedColor], or [fallback] when this style omits it.
  static Color selectedColorOf(
    CupertinoSidebarItemStyle? style,
    Color fallback,
  ) {
    return style?.selectedColor ?? fallback;
  }

  /// The label color for [selected], using each fallback when unset.
  static Color foregroundOf(
    CupertinoSidebarItemStyle? style, {
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
    CupertinoSidebarItemStyle? style, {
    required TextStyle fallback,
    required Color color,
  }) {
    return fallback.merge(style?.labelStyle).copyWith(color: color);
  }
}
