import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../adaptive_navigation_destination.dart';
import '../sidebar_destination_selection.dart';
import 'material_rail_destination_group_layout.dart';
import 'material_sidebar_item_style.dart';
import 'material_sidebar_metrics.dart';
import 'material_wide_navigation_rail_button.dart';

/// Scrollable Material destinations with a pinned footer.
///
/// Place this in `MaterialSidebar.content`. [selection] is either a primary
/// destination, an auxiliary destination, or null when nothing is highlighted.
///
/// ```text
/// collapsed           expanded
/// +----+              +------------+
/// | o  |              | o  Home    |
/// | o  |              | o  Search  |
/// |    |              |            |
/// | o  |              | o  Settings|
/// +----+              +------------+
/// ```
class MaterialSidebarNavigation extends StatelessWidget {
  /// Creates a destination list for [destinations].
  const MaterialSidebarNavigation({
    super.key,
    required this.destinations,
    required this.selection,
    required this.onSelectionChanged,
    this.auxiliaryDestinations = const [],
    this.itemStyle,
  }) : assert(destinations.length > 0);

  static const double _collapsedDestinationSpacing = 4.0;
  static const double _collapsedAuxiliaryDestinationSpacing = 4.0;
  static const double _minimumLeadingDestinationSpacing = 8.0;
  static const double _maximumLeadingDestinationSpacing = 40.0;

  /// Primary destinations.
  final List<AdaptiveNavigationDestination> destinations;

  /// Selected destination, or null when nothing in either list is highlighted.
  final SidebarDestinationSelection? selection;

  /// Called with the destination the user tapped.
  final ValueChanged<SidebarDestinationSelection> onSelectionChanged;

  /// Destinations pinned below the scrolling list.
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;

  /// Indicator, label colors, and label type for every row.
  ///
  /// Null keeps the navigation-rail theme.
  final MaterialSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    assert(_selectionInRange(selection, destinations, auxiliaryDestinations));
    final metrics = MaterialSidebarMetrics.of(context);
    final animation = NavigationRail.extendedAnimation(context);
    final primaryIndex = switch (selection) {
      SidebarPrimarySelection(:final index) => index,
      _ => -1,
    };
    final auxiliaryIndex = switch (selection) {
      SidebarAuxiliarySelection(:final index) => index,
      _ => -1,
    };
    final destinationList = Column(
      key: const ValueKey('material-rail-primary-destination-list'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, destination) in destinations.indexed) ...[
          MaterialWideNavigationRailButton(
            key: ValueKey('material-rail-destination-$index'),
            destination: destination,
            selected: primaryIndex == index,
            itemStyle: itemStyle,
            onPressed: () => onSelectionChanged(SidebarPrimarySelection(index)),
          ),
          if (index != destinations.length - 1)
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) => SizedBox(
                height: lerpDouble(
                  _collapsedDestinationSpacing,
                  0,
                  animation.value,
                ),
              ),
            ),
        ],
      ],
    );
    final auxiliaryDestinationList = Column(
      key: const ValueKey('material-rail-auxiliary-destination-list'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, destination) in auxiliaryDestinations.indexed) ...[
          MaterialWideNavigationRailButton(
            key: ValueKey('material-rail-auxiliary-destination-$index'),
            destination: destination,
            selected: auxiliaryIndex == index,
            itemStyle: itemStyle,
            onPressed: () =>
                onSelectionChanged(SidebarAuxiliarySelection(index)),
          ),
          if (index != auxiliaryDestinations.length - 1)
            SizedBox(
              height: metrics.expanded
                  ? 0
                  : _collapsedAuxiliaryDestinationSpacing,
            ),
        ],
      ],
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => SizedBox(
        width: lerpDouble(
          metrics.collapsedWidth,
          metrics.expandedWidth,
          animation.value,
        ),
        child: child,
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              key: const ValueKey('material-rail-primary-scroll-view'),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: MaterialRailDestinationGroupLayout(
                    minimumGap: _minimumLeadingDestinationSpacing,
                    maximumGap: _maximumLeadingDestinationSpacing,
                    child: destinationList,
                  ),
                ),
              ],
            ),
          ),
          if (auxiliaryDestinations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: auxiliaryDestinationList,
            ),
        ],
      ),
    );
  }
}

bool _selectionInRange(
  SidebarDestinationSelection? selection,
  List<AdaptiveNavigationDestination> destinations,
  List<AdaptiveNavigationDestination> auxiliaryDestinations,
) {
  return switch (selection) {
    null => true,
    SidebarPrimarySelection(:final index) => index < destinations.length,
    SidebarAuxiliarySelection(:final index) =>
      index < auxiliaryDestinations.length,
  };
}
