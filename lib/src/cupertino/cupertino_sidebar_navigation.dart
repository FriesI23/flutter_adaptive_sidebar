import 'package:flutter/cupertino.dart';

import '../adaptive_navigation_destination.dart';
import 'cupertino_sidebar_destination.dart';

/// Scrollable Cupertino destinations with a pinned footer.
///
/// Place this in `CupertinoSidebar.content`. A selected auxiliary destination
/// clears the primary highlight. The footer keeps a separator and bottom safe
/// area.
class CupertinoSidebarNavigation extends StatelessWidget {
  /// Creates a destination list for [destinations].
  const CupertinoSidebarNavigation({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.auxiliaryDestinations = const [],
    this.selectedAuxiliaryIndex,
    this.onAuxiliaryDestinationSelected,
  }) : assert(destinations.length > 0);

  static const double _toolbarHeight = kMinInteractiveDimensionCupertino;
  static const double _destinationTopGap = 24;

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
    final primaryIndex = selectedAuxiliaryIndex == null ? selectedIndex : -1;
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
              onPressed: () => onDestinationSelected(index),
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
                      selected: selectedAuxiliaryIndex == index,
                      onPressed: () =>
                          onAuxiliaryDestinationSelected?.call(index),
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
