import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

/// Opacity of [CupertinoSidebarChrome.liquid]'s glass fill.
const double kCupertinoSidebarLiquidFillAlpha = 0.7;

/// Opacity of [CupertinoSidebarChrome.liquidEdge]'s glass fill.
const double kCupertinoSidebarEdgeFillAlpha = 0.9;

/// Glass treatment for a Cupertino sidebar.
///
/// The package does not choose this from the platform. [liquid] is the
/// default.
enum CupertinoSidebarStyle {
  /// Inset floating glass with rounded corners.
  liquid,

  /// Glass column flush with the leading, top, and bottom edges.
  ///
  /// The inner edge is straight.
  liquidEdge,
}

/// Theme color and opacity for a sidebar glass fill.
///
/// [color] is resolved with the current brightness, then [alpha] caps its
/// opacity. A theme color that is already more transparent remains unchanged.
/// A null [color] uses the theme bar background.
class CupertinoSidebarFill {
  /// Creates a fill from [color] at [alpha].
  const CupertinoSidebarFill({this.color, required this.alpha});

  /// Source color. Null uses [CupertinoThemeData.barBackgroundColor].
  final CupertinoDynamicColor? color;

  /// Maximum opacity applied after [color] is resolved.
  final double alpha;

  /// The fill for the current theme brightness.
  Color resolve(BuildContext context) {
    final source = color ?? CupertinoTheme.of(context).barBackgroundColor;
    final resolved = CupertinoDynamicColor.resolve(source, context);
    return resolved.withValues(alpha: math.min(resolved.a, alpha));
  }
}

/// Edge stroke for a sidebar glass preset.
enum CupertinoSidebarBorder {
  /// 0.5 white hairline in dark mode. Light mode draws nothing.
  darkHairline,

  /// Separator on the inner edge in both brightnesses.
  innerSeparator;

  /// The stroke for the current theme, or null when this preset draws none.
  BoxBorder? resolve(BuildContext context) {
    return switch (this) {
      CupertinoSidebarBorder.darkHairline =>
        CupertinoTheme.brightnessOf(context) == Brightness.dark
            ? Border.all(color: const Color(0x24FFFFFF), width: 0.5)
            : null,
      CupertinoSidebarBorder.innerSeparator => BorderDirectional(
        end: BorderSide(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.separator,
            context,
          ),
          width: 0.5,
        ),
      ),
    };
  }
}

/// Geometry and material for a [CupertinoSidebarStyle].
///
/// The sidebar layout and the panel share this so both styles use one layout.
/// It is not part of the package's public API.
class CupertinoSidebarChrome {
  /// Creates chrome for one sidebar style.
  const CupertinoSidebarChrome({
    required this.surfaceMargin,
    required this.borderRadius,
    required this.contentGap,
    required this.resizeHandleCornerInset,
    required this.flushToWindowEdge,
    required this.fill,
    required this.blurSigma,
    required this.boxShadow,
    required this.border,
  });

  /// Drop shadow of the inset floating glass.
  static const List<BoxShadow> floatingShadow = <BoxShadow>[
    BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// Inset floating glass.
  ///
  /// The 10pt margin is measured from `UITabBarController.mode = .tabSidebar`
  /// on iPadOS 26.5: the floating surface is inset 10pt from every window
  /// edge. The corner radius is 25 and the page sits 12pt past the surface.
  static const CupertinoSidebarChrome liquid = CupertinoSidebarChrome(
    surfaceMargin: 10,
    borderRadius: BorderRadius.all(Radius.circular(25)),
    contentGap: 12,
    resizeHandleCornerInset: 25,
    flushToWindowEdge: false,
    fill: CupertinoSidebarFill(alpha: kCupertinoSidebarLiquidFillAlpha),
    blurSigma: 10,
    boxShadow: floatingShadow,
    border: CupertinoSidebarBorder.darkHairline,
  );

  /// Glass column that meets the window edge.
  ///
  /// The page starts at the inner edge. The fill is the themed secondary
  /// background, and [border] draws the separator on the inner edge.
  static const CupertinoSidebarChrome liquidEdge = CupertinoSidebarChrome(
    surfaceMargin: 0,
    borderRadius: BorderRadius.zero,
    contentGap: 0,
    resizeHandleCornerInset: 0,
    flushToWindowEdge: true,
    fill: CupertinoSidebarFill(
      color: CupertinoColors.secondarySystemBackground,
      alpha: kCupertinoSidebarEdgeFillAlpha,
    ),
    blurSigma: 10,
    boxShadow: <BoxShadow>[],
    border: CupertinoSidebarBorder.innerSeparator,
  );

  /// Chrome for [style].
  factory CupertinoSidebarChrome.of(CupertinoSidebarStyle style) {
    return switch (style) {
      CupertinoSidebarStyle.liquid => liquid,
      CupertinoSidebarStyle.liquidEdge => liquidEdge,
    };
  }

  /// Inset of the glass from each window edge.
  final double surfaceMargin;

  /// Corner radius of the glass. Zero is a straight column.
  final BorderRadius borderRadius;

  /// Space between the glass and the page.
  final double contentGap;

  /// Vertical inset of the resize handle, clear of rounded corners.
  final double resizeHandleCornerInset;

  /// Whether the glass meets the window edge.
  ///
  /// When true, the glass extends under the status bar and home indicator.
  /// The toggle and the panel content clear that safe area themselves.
  final bool flushToWindowEdge;

  /// Glass tint and opacity.
  final CupertinoSidebarFill fill;

  /// Backdrop blur strength. Zero draws no blur.
  final double blurSigma;

  /// Drop shadow. An empty list draws none.
  final List<BoxShadow> boxShadow;

  /// Stroke painted over the glass.
  final CupertinoSidebarBorder border;
}
