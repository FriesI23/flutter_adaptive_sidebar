import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'side_navigation_extent.dart';
import 'sidebar_destination_selection.dart';

/// Persistent sidebar state.
///
/// The controller keeps the selected destination, whether the sidebar is
/// expanded, and any manually dragged width. A caller can read the same
/// values when it builds its own compact chrome.
class AdaptiveNavigationController extends ChangeNotifier {
  /// Creates a controller.
  ///
  /// [initialManualWidth] is the remembered drag width. When null, sidebars
  /// use [SideNavigationExtent.resolve].
  AdaptiveNavigationController({
    SidebarDestinationSelection initialSelection =
        const SidebarPrimarySelection(0),
    bool initialExpanded = true,
    double? initialManualWidth,
  }) : _selection = initialSelection,
       _expanded = initialExpanded,
       _manualWidth = initialManualWidth;

  SidebarDestinationSelection _selection;
  bool _expanded;
  double? _manualWidth;
  bool _manualAboveAuto = false;
  double _dragCurrentWidth = 0;
  bool _resizing = false;

  /// Selected primary or auxiliary destination.
  SidebarDestinationSelection get selection => _selection;

  /// Selects [value] and notifies listeners when it changes.
  set selection(SidebarDestinationSelection value) {
    if (_selection == value) return;
    _selection = value;
    notifyListeners();
  }

  /// Selects [value].
  void select(SidebarDestinationSelection value) => selection = value;

  /// Whether the sidebar should use its open, full-width presentation.
  ///
  /// Material reads this as an extended rail. Cupertino reads it as sidebar
  /// visibility.
  bool get expanded => _expanded;

  /// Updates the sidebar presentation and notifies listeners when it changes.
  set expanded(bool value) {
    if (_expanded == value) return;
    _expanded = value;
    notifyListeners();
  }

  /// Flips [expanded].
  void toggleExpanded() => expanded = !_expanded;

  /// Remembered sidebar width in logical pixels, or null when unset.
  double? get manualWidth => _manualWidth;

  /// Whether a sidebar resize drag is active.
  bool get resizing => _resizing;

  /// Resolves the sidebar width at [windowWidth] without dropping a manual
  /// width.
  double effectiveWidth(
    SideNavigationExtent extent, {
    required double windowWidth,
  }) {
    final manualWidth = _manualWidth;
    if (manualWidth == null) return extent.resolve(windowWidth);
    final bound = _manualAboveAuto
        ? extent.upperBoundAt(windowWidth)
        : extent.resolve(windowWidth);
    return math.min(manualWidth, bound);
  }

  /// Starts a resize from the current effective width.
  void beginResize(SideNavigationExtent extent, {required double windowWidth}) {
    _resizing = true;
    _dragCurrentWidth = effectiveWidth(extent, windowWidth: windowWidth);
    notifyListeners();
  }

  /// Applies a logical horizontal [delta] and remembers the resulting width.
  void updateResize(
    double delta,
    SideNavigationExtent extent, {
    required double windowWidth,
  }) {
    assert(_resizing);
    _dragCurrentWidth = extent.clamp(
      _dragCurrentWidth + delta,
      windowWidth: windowWidth,
    );
    _manualWidth = _dragCurrentWidth;
    _manualAboveAuto = _dragCurrentWidth > extent.resolve(windowWidth);
    notifyListeners();
  }

  /// Ends the active resize while preserving its last width.
  void endResize() {
    if (!_resizing) return;
    _resizing = false;
    notifyListeners();
  }

  /// Drops the remembered drag width.
  ///
  /// Sidebars then use [SideNavigationExtent.resolve] until the next resize.
  void clearManualWidth() {
    if (_manualWidth == null && !_manualAboveAuto) return;
    _manualWidth = null;
    _manualAboveAuto = false;
    notifyListeners();
  }
}
