import 'package:flutter/cupertino.dart';

import '../adaptive_navigation_destination.dart';
import '../sidebar_destination_selection.dart';
import 'cupertino_sidebar_destination.dart';
import 'cupertino_sidebar_item_style.dart';

/// Scrollable Cupertino destinations with a pinned footer.
///
/// Place this in `CupertinoSidebar.content`. [selection] is either a primary
/// destination, an auxiliary destination, or null when nothing is highlighted.
/// The footer keeps a separator and bottom safe area.
///
/// ```text
/// +------------------+
/// | Home             |
/// | Search           |
/// |                  |
/// +------------------+
/// | Settings         |
/// +------------------+
/// ```
class CupertinoSidebarNavigation extends StatelessWidget {
  /// Creates a destination list for [destinations].
  const CupertinoSidebarNavigation({
    super.key,
    required this.destinations,
    required this.selection,
    required this.onSelectionChanged,
    this.auxiliaryDestinations = const [],
    this.itemStyle,
  }) : assert(destinations.length > 0);

  static const double _toolbarHeight = kMinInteractiveDimensionCupertino;
  static const double _destinationTopGap = 24;

  /// Primary destinations.
  final List<AdaptiveNavigationDestination> destinations;

  /// Selected destination, or null when nothing in either list is highlighted.
  final SidebarDestinationSelection? selection;

  /// Called with the destination the user tapped.
  final ValueChanged<SidebarDestinationSelection> onSelectionChanged;

  /// Destinations pinned below the scrolling list.
  final List<AdaptiveNavigationDestination> auxiliaryDestinations;

  /// Fill, label colors, and label type for every row.
  ///
  /// Null keeps the liquid tint or the edge fill.
  final CupertinoSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    assert(_selectionInRange(selection, destinations, auxiliaryDestinations));
    final primaryIndex = switch (selection) {
      SidebarPrimarySelection(:final index) => index,
      _ => -1,
    };
    final auxiliaryIndex = switch (selection) {
      SidebarAuxiliarySelection(:final index) => index,
      _ => -1,
    };
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: const ValueKey('cupertino-sidebar-destination-list'),
            padding: const EdgeInsets.only(
              top: _toolbarHeight + _destinationTopGap,
              bottom: 8,
            ),
            itemCount: destinations.length,
            itemBuilder: (context, index) => CupertinoSidebarDestination(
              key: ValueKey('cupertino-sidebar-destination-$index'),
              destination: destinations[index],
              selected: primaryIndex == index,
              itemStyle: itemStyle,
              onPressed: () =>
                  onSelectionChanged(SidebarPrimarySelection(index)),
            ),
          ),
        ),
        if (auxiliaryDestinations.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 1,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.separator,
                context,
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, destination)
                      in auxiliaryDestinations.indexed)
                    CupertinoSidebarDestination(
                      key: ValueKey(
                        'cupertino-sidebar-auxiliary-destination-$index',
                      ),
                      destination: destination,
                      selected: auxiliaryIndex == index,
                      itemStyle: itemStyle,
                      onPressed: () =>
                          onSelectionChanged(SidebarAuxiliarySelection(index)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
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
