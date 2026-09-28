import 'package:flutter/cupertino.dart';

import '../adaptive_navigation_destination.dart';
import '../sidebar_destination_selection.dart';
import 'cupertino_sidebar.dart';
import 'cupertino_sidebar_chrome.dart';
import 'cupertino_sidebar_destination.dart';
import 'cupertino_sidebar_interaction_scope.dart';
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
class CupertinoSidebarNavigation extends StatefulWidget {
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
  State<CupertinoSidebarNavigation> createState() =>
      _CupertinoSidebarNavigationState();
}

class _CupertinoSidebarNavigationState
    extends State<CupertinoSidebarNavigation> {
  SidebarDestinationSelection? _activeSelection;
  int? _outsideTapGeneration;

  @override
  void initState() {
    super.initState();
    _activeSelection = widget.selection;
  }

  @override
  void didUpdateWidget(CupertinoSidebarNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selection != oldWidget.selection) {
      _activeSelection = widget.selection;
    }
    if (!_selectionInRange(
      _activeSelection,
      widget.destinations,
      widget.auxiliaryDestinations,
    )) {
      _activeSelection = widget.selection;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final generation = CupertinoSidebarInteractionScope.outsideTapGenerationOf(
      context,
    );
    if (_outsideTapGeneration != null && generation != _outsideTapGeneration) {
      _activeSelection = null;
    }
    _outsideTapGeneration = generation;
  }

  void _select(SidebarDestinationSelection selection) {
    if (_activeSelection != selection) {
      setState(() => _activeSelection = selection);
    }
    widget.onSelectionChanged(selection);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _selectionInRange(
        widget.selection,
        widget.destinations,
        widget.auxiliaryDestinations,
      ),
    );
    final edge =
        CupertinoSidebar.styleOf(context) == CupertinoSidebarStyle.liquidEdge;
    final primaryIndex = switch (widget.selection) {
      SidebarPrimarySelection(:final index) => index,
      _ => -1,
    };
    final auxiliaryIndex = switch (widget.selection) {
      SidebarAuxiliarySelection(:final index) => index,
      _ => -1,
    };
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: const ValueKey('cupertino-sidebar-destination-list'),
            padding: const EdgeInsets.only(
              top:
                  CupertinoSidebarNavigation._toolbarHeight +
                  CupertinoSidebarNavigation._destinationTopGap,
              bottom: 8,
            ),
            itemCount: widget.destinations.length,
            itemBuilder: (context, index) {
              final selection = SidebarPrimarySelection(index);
              return CupertinoSidebarDestination(
                key: ValueKey('cupertino-sidebar-destination-$index'),
                destination: widget.destinations[index],
                selected: primaryIndex == index,
                active: edge && _activeSelection == selection,
                itemStyle: widget.itemStyle,
                onPressed: () => _select(selection),
              );
            },
          ),
        ),
        if (widget.auxiliaryDestinations.isNotEmpty) ...[
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
                      in widget.auxiliaryDestinations.indexed)
                    _buildAuxiliaryDestination(
                      edge: edge,
                      index: index,
                      destination: destination,
                      selected: auxiliaryIndex == index,
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuxiliaryDestination({
    required bool edge,
    required int index,
    required AdaptiveNavigationDestination destination,
    required bool selected,
  }) {
    final selection = SidebarAuxiliarySelection(index);
    final active = edge && _activeSelection == selection;
    return CupertinoSidebarDestination(
      key: ValueKey('cupertino-sidebar-auxiliary-destination-$index'),
      destination: destination,
      selected: selected,
      active: active,
      itemStyle: widget.itemStyle,
      onPressed: () => _select(selection),
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
