import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../adaptive_navigation_destination.dart';
import 'material_rail_destination_group_layout.dart';
import 'material_sidebar_metrics.dart';
import 'material_wide_navigation_rail_button.dart';

/// Scrollable Material destinations with a pinned footer.
///
/// Place this in `MaterialSidebar.content`. A selected auxiliary destination
/// clears the primary highlight.
class MaterialSidebarNavigation extends StatelessWidget {
  /// Creates a destination list for [destinations].
  const MaterialSidebarNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.auxiliaryDestinations = const [],
    this.selectedAuxiliaryIndex,
    this.onAuxiliaryDestinationSelected,
  }) : assert(destinations.length > 0);

  static const double _collapsedDestinationSpacing = 4.0;
  static const double _collapsedAuxiliaryDestinationSpacing = 4.0;
  static const double _minimumLeadingDestinationSpacing = 8.0;
  static const double _maximumLeadingDestinationSpacing = 40.0;

  /// Primary destinations.
  final List<AdaptiveNavigationDestination> destinations;

  /// Selected primary destination.
  ///
  /// Ignored while [selectedAuxiliaryIndex] is non-null.
  final int selectedIndex;

  /// Called with the index of a selected primary destination.
  final ValueChanged<int> onDestinationSelected;

  /// Destinations pinned below the scrolling list.
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;

  /// Selected auxiliary destination, if any.
  final int? selectedAuxiliaryIndex;

  /// Called when an auxiliary destination is selected.
  final ValueChanged<int>? onAuxiliaryDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final metrics = MaterialSidebarMetrics.of(context);
    final animation = NavigationRail.extendedAnimation(context);
    final primaryIndex = selectedAuxiliaryIndex == null ? selectedIndex : -1;
    final destinationList = Column(
      key: const ValueKey('material-rail-primary-destination-list'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, destination) in destinations.indexed) ...[
          MaterialWideNavigationRailButton(
            slotKey: ValueKey('material-rail-destination-slot-$index'),
            buttonKey: ValueKey('material-rail-destination-$index'),
            animation: animation,
            collapsedRailWidth: metrics.collapsedWidth,
            expandedRailWidth: metrics.expandedWidth,
            destination: destination,
            selected: primaryIndex == index,
            onPressed: () => onDestinationSelected(index),
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
            slotKey: ValueKey(
              'material-rail-auxiliary-destination-slot-$index',
            ),
            buttonKey: ValueKey('material-rail-auxiliary-destination-$index'),
            animation: AlwaysStoppedAnimation(metrics.extended ? 1 : 0),
            collapsedRailWidth: metrics.collapsedWidth,
            expandedRailWidth: metrics.expandedWidth,
            destination: destination,
            selected: selectedAuxiliaryIndex == index,
            onPressed: () => onAuxiliaryDestinationSelected?.call(index),
          ),
          if (index != auxiliaryDestinations.length - 1)
            SizedBox(
              height: metrics.extended
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
