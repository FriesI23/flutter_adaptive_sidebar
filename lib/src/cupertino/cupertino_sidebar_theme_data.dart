import 'package:flutter/material.dart';

/// App-theme overrides for Cupertino sidebar surfaces.
@immutable
class CupertinoSidebarThemeData
    extends ThemeExtension<CupertinoSidebarThemeData> {
  /// Creates Cupertino sidebar theme overrides.
  const CupertinoSidebarThemeData({this.edgeBackgroundColor});

  /// Source tint for the edge sidebar glass.
  ///
  /// The package resolves dynamic colors and applies the edge glass opacity.
  /// Null keeps the package's iPadOS 27 light/dark baseline. The resulting
  /// tint is shared by the expanded panel and collapsed edge capsule.
  final Color? edgeBackgroundColor;

  /// Resolves the nearest sidebar theme, or empty defaults.
  static CupertinoSidebarThemeData of(BuildContext context) {
    return Theme.of(context).extension<CupertinoSidebarThemeData>() ??
        const CupertinoSidebarThemeData();
  }

  @override
  CupertinoSidebarThemeData copyWith({Color? edgeBackgroundColor}) {
    return CupertinoSidebarThemeData(
      edgeBackgroundColor: edgeBackgroundColor ?? this.edgeBackgroundColor,
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
    );
  }
}
