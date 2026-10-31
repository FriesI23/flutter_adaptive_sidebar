import 'package:flutter/widgets.dart';

/// Caller-supplied layout space for sidebar toolbar controls.
///
/// Coordinates are physical logical pixels relative to the sidebar's layout
/// box. They do not follow route paint transforms or mirror in RTL layouts.
/// The caller owns obstruction detection and device policy.
@immutable
final class CupertinoSidebarToolbarRegion {
  /// Creates a toolbar region independent of the panel and page safe areas.
  const CupertinoSidebarToolbarRegion({
    required this.bounds,
    required this.minimumExtent,
    this.maxCollapsedBarWidth,
  });

  /// Available toolbar row, including the full hit area of its controls.
  final Rect bounds;

  /// Minimum protected distance from the layout top to panel content.
  ///
  /// This must reach [bounds]' bottom. It does not change the page's
  /// MediaQuery or reserve space on behalf of a page app bar.
  final double minimumExtent;

  /// Optional hard width limit for the window-centered collapsed capsule.
  ///
  /// Include mandatory page controls in this budget before the first frame.
  /// Null uses the largest centered width that fits [bounds].
  final double? maxCollapsedBarWidth;

  @override
  bool operator ==(Object other) =>
      other is CupertinoSidebarToolbarRegion &&
      bounds == other.bounds &&
      minimumExtent == other.minimumExtent &&
      maxCollapsedBarWidth == other.maxCollapsedBarWidth;

  @override
  int get hashCode => Object.hash(bounds, minimumExtent, maxCollapsedBarWidth);
}
