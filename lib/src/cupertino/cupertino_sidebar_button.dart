import 'package:flutter/cupertino.dart';

import '../sidebar_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final button = CupertinoButton(
      key: buttonKey,
      focusNode: focusNode,
      minimumSize: const Size.square(44),
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
        ),
      ),
    );
    final builder = tooltipBuilder;
    if (builder == null) return button;
    return builder(context, label, button);
  }
}
