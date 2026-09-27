import 'package:flutter/foundation.dart';

/// Vertical geometry shared by a collapsed Cupertino sidebar and its toolbar.
///
/// [standard] preserves the measured iPad layout. [compact] provides a denser
/// desktop layout.
@immutable
final class CupertinoSidebarToolbarGeometry {
  /// Creates toolbar geometry for a collapsed Cupertino sidebar.
  const CupertinoSidebarToolbarGeometry({
    required this.contentHeight,
    required this.collapsedBarHeight,
    required this.height,
    this.topInset = 0,
  }) : assert(contentHeight > 0),
       assert(collapsedBarHeight > 0),
       assert(collapsedBarHeight <= contentHeight),
       assert(height >= contentHeight),
       assert(topInset >= 0);

  /// Measured iPad toolbar geometry.
  static const CupertinoSidebarToolbarGeometry standard =
      CupertinoSidebarToolbarGeometry(
        contentHeight: 44,
        collapsedBarHeight: 44,
        height: 54,
      );

  /// Compact desktop toolbar geometry.
  static const CupertinoSidebarToolbarGeometry compact =
      CupertinoSidebarToolbarGeometry(
        contentHeight: 44,
        collapsedBarHeight: 36,
        height: 44,
        topInset: 10,
      );

  /// Height of the toolbar content row that hosts the collapsed bar.
  final double contentHeight;

  /// Height of the horizontal collapsed sidebar capsule.
  final double collapsedBarHeight;

  /// Total host height, excluding any safe-area inset.
  final double height;

  /// Minimum space above the toolbar content row.
  ///
  /// The window safe area or sidebar surface may increase this value.
  final double topInset;

  @override
  bool operator ==(Object other) =>
      other is CupertinoSidebarToolbarGeometry &&
      contentHeight == other.contentHeight &&
      collapsedBarHeight == other.collapsedBarHeight &&
      height == other.height &&
      topInset == other.topInset;

  @override
  int get hashCode =>
      Object.hash(contentHeight, collapsedBarHeight, height, topInset);
}
