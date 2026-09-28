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
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
    this.selectedColor,
    this.selectedForegroundColor,
    this.foregroundColor,
    this.labelStyle,
  });

  /// Capsule fill resolved from the row's current widget states.
  ///
  /// This takes precedence over [selectedColor]. Returning null draws no
  /// capsule for that state.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Icon color resolved from the row's current widget states.
  ///
  /// This takes precedence over [selectedForegroundColor] and
  /// [foregroundColor].
  final WidgetStateProperty<Color>? iconColor;

  /// Label color resolved from the row's current widget states.
  ///
  /// This takes precedence over [selectedForegroundColor] and
  /// [foregroundColor].
  final WidgetStateProperty<Color>? labelColor;

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

  /// The legacy shared foreground for [selected].
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

  /// Resolves the capsule fill for [states].
  static Color? backgroundColorOf(
    CupertinoSidebarItemStyle? style,
    BuildContext context, {
    required Set<WidgetState> states,
    required Color? fallback,
  }) {
    final stateColor = style?.backgroundColor;
    final color = stateColor == null
        ? states.contains(WidgetState.selected)
              ? style?.selectedColor ?? fallback
              : fallback
        : stateColor.resolve(states);
    return color == null ? null : CupertinoDynamicColor.resolve(color, context);
  }

  /// The icon color for [states], using each fallback when unset.
  static Color iconColorOf(
    CupertinoSidebarItemStyle? style, {
    required BuildContext context,
    required Set<WidgetState> states,
    required Color selectedFallback,
    required Color unselectedFallback,
  }) {
    final fallback = states.contains(WidgetState.selected)
        ? style?.selectedForegroundColor ?? selectedFallback
        : style?.foregroundColor ?? unselectedFallback;
    final color = style?.iconColor?.resolve(states) ?? fallback;
    return CupertinoDynamicColor.resolve(color, context);
  }

  /// The label color for [states], using each fallback when unset.
  static Color labelColorOf(
    CupertinoSidebarItemStyle? style, {
    required BuildContext context,
    required Set<WidgetState> states,
    required Color selectedFallback,
    required Color unselectedFallback,
  }) {
    final fallback = states.contains(WidgetState.selected)
        ? style?.selectedForegroundColor ?? selectedFallback
        : style?.foregroundColor ?? unselectedFallback;
    final color = style?.labelColor?.resolve(states) ?? fallback;
    return CupertinoDynamicColor.resolve(color, context);
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
