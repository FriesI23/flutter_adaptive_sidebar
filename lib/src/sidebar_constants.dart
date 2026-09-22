import 'package:flutter/widgets.dart';

/// Default duration for sidebar expand, collapse, and resize transitions.
const Duration kSidebarAnimationDuration = Duration(milliseconds: 250);

/// Wraps a navigation control with a caller-supplied tooltip.
///
/// Material and Cupertino sidebars both accept this builder. Cupertino does
/// not create a Material tooltip on its own.
typedef NavigationTooltipBuilder =
    Widget Function(BuildContext context, String message, Widget child);
