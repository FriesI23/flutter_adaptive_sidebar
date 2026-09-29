import 'package:flutter/material.dart';

/// Paints a Cupertino sidebar focus halo over [decoration].
///
/// The package retains focus, keyboard, and platform semantics. The builder
/// only replaces the visual treatment. Its function signature intentionally
/// matches the adaptive-actions focus hook so an app can reuse one painter.
typedef CupertinoSidebarFocusHaloBuilder =
    Widget Function(
      BuildContext context, {
      required Widget child,
      required bool visible,
      required ShapeDecoration decoration,
    });

/// App-theme overrides for Cupertino sidebar surfaces.
@immutable
class CupertinoSidebarThemeData
    extends ThemeExtension<CupertinoSidebarThemeData> {
  /// Creates Cupertino sidebar theme overrides.
  const CupertinoSidebarThemeData({
    this.edgeBackgroundColor,
    this.focusHaloBuilder,
  });

  /// Source tint for the edge sidebar glass.
  ///
  /// The package resolves dynamic colors and applies the edge glass opacity.
  /// Null keeps the package's iPadOS 27 light/dark baseline. The resulting
  /// tint is shared by the expanded panel and collapsed edge capsule.
  final Color? edgeBackgroundColor;

  /// Optional app-owned focus painter used for macOS destination halos.
  ///
  /// Null keeps the package's system-aligned default. iOS and iPadOS
  /// destinations continue to use their platform highlight treatment.
  final CupertinoSidebarFocusHaloBuilder? focusHaloBuilder;

  /// Resolves the nearest sidebar theme, or empty defaults.
  static CupertinoSidebarThemeData of(BuildContext context) {
    return Theme.of(context).extension<CupertinoSidebarThemeData>() ??
        const CupertinoSidebarThemeData();
  }

  @override
  CupertinoSidebarThemeData copyWith({
    Color? edgeBackgroundColor,
    CupertinoSidebarFocusHaloBuilder? focusHaloBuilder,
  }) {
    return CupertinoSidebarThemeData(
      edgeBackgroundColor: edgeBackgroundColor ?? this.edgeBackgroundColor,
      focusHaloBuilder: focusHaloBuilder ?? this.focusHaloBuilder,
    );
  }

  @override
  CupertinoSidebarThemeData lerp(
    covariant CupertinoSidebarThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return CupertinoSidebarThemeData(
      edgeBackgroundColor: Color.lerp(
        edgeBackgroundColor,
        other.edgeBackgroundColor,
        t,
      ),
      focusHaloBuilder: t < 0.5 ? focusHaloBuilder : other.focusHaloBuilder,
    );
  }
}
