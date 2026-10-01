import 'package:flutter/cupertino.dart';

import '../sidebar_constants.dart';

/// Builds the package-default Cupertino sidebar toggle in [context].
typedef CupertinoSidebarToggleDefaultBuilder =
    Widget Function(BuildContext context);

/// Optionally wraps or replaces the Cupertino sidebar toggle presentation.
///
/// Call [defaultBuilder] from a descendant [BuildContext] to retain the
/// package-owned button, semantics, focus, tooltip, and interaction behavior.
typedef CupertinoSidebarToggleBuilder =
    Widget Function(
      BuildContext context,
      CupertinoSidebarToggleDefaultBuilder defaultBuilder,
    );

/// Button that shows or hides the Cupertino sidebar.
class CupertinoSidebarButton extends StatelessWidget {
  /// Creates a sidebar toggle button.
  const CupertinoSidebarButton({
    super.key,
    required this.focusNode,
    required this.label,
    required this.onPressed,
    required this.buttonKey,
    this.tooltipBuilder,
    this.builder,
    this.extent = kMinInteractiveDimensionCupertino,
    this.iconSize,
  });

  /// Focus node owned by the sidebar host.
  final FocusNode focusNode;

  /// Accessibility label, also passed to [tooltipBuilder].
  final String label;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Key applied to the button.
  final Key buttonKey;

  /// Optional tooltip wrapper. Cupertino does not supply a Material tooltip.
  final NavigationTooltipBuilder? tooltipBuilder;

  /// Optional presentation override for the package-default toggle.
  final CupertinoSidebarToggleBuilder? builder;

  /// Square size of the button. The collapsed capsule passes its height.
  final double extent;

  /// Glyph size. Null uses the button's icon theme.
  final double? iconSize;

  @override
  Widget build(BuildContext context) =>
      builder?.call(context, _buildDefaultButton) ??
      _buildDefaultButton(context);

  Widget _buildDefaultButton(BuildContext context) {
    final direction = Directionality.of(context);
    final button = CupertinoButton(
      key: buttonKey,
      focusNode: focusNode,
      minimumSize: Size.square(extent),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Icon(
          direction == TextDirection.ltr
              ? CupertinoIcons.sidebar_left
              : CupertinoIcons.sidebar_right,
          size: iconSize,
        ),
      ),
    );
    final tooltipBuilder = this.tooltipBuilder;
    if (tooltipBuilder == null) return button;
    return tooltipBuilder(context, label, button);
  }
}
