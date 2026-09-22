import 'package:flutter/cupertino.dart';

import '../adaptive_navigation_destination.dart';

/// A Cupertino sidebar row for one navigation destination.
///
/// ```text
/// idle                 selected
/// o  Label             [ o  Label ]
/// ```
class CupertinoSidebarDestination extends StatelessWidget {
  /// Creates a destination row.
  const CupertinoSidebarDestination({
    super.key,
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  /// Destination rendered by this row.
  final AdaptiveNavigationDestination destination;

  /// Whether this destination is selected.
  final bool selected;

  /// Called when the row is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final foregroundColor = (selected ? primaryColor : labelColor).withValues(
      alpha: 1,
    );
    final icon = selected
        ? destination.icons.cupertinoSelected
        : destination.icons.cupertino;
    final label = Expanded(
      child: Text(
        destination.label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final button = CupertinoButton(
      sizeStyle: CupertinoButtonSize.medium,
      minimumSize: const Size(0, 44),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      alignment: AlignmentDirectional.centerStart,
      color: selected ? primaryColor.withValues(alpha: 0.14) : null,
      foregroundColor: foregroundColor,
      onPressed: onPressed,
      child: Row(children: [icon, const SizedBox(width: 12), label]),
    );

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.effectiveSemanticsLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: SizedBox(width: double.infinity, child: button),
      ),
    );
  }
}
