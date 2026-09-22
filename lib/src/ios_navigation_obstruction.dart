import 'package:flutter/widgets.dart';
import 'package:ios_window_control_layout/ios_window_control_layout.dart';

import 'navigation_obstruction.dart';

/// Fills a [NavigationObstructionScope] from iPadOS window-control layout.
///
/// Unsupported platforms contribute an empty obstruction. Callers that compute
/// avoidance themselves can provide [NavigationObstructionScope] directly and
/// skip this widget.
class IosNavigationObstruction extends StatelessWidget {
  /// Creates an iPadOS obstruction bridge around [child].
  const IosNavigationObstruction({super.key, required this.child});

  /// Navigation subtree that should avoid window controls.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IosWindowControlLayout(
      child: Builder(
        builder: (context) {
          final data = IosWindowControlLayout.of(context);
          if (!data.isAvailable) {
            return NavigationObstructionScope(
              obstruction: const NavigationObstruction(),
              child: child,
            );
          }
          final direction = Directionality.of(context);
          final sidebar = switch (direction) {
            TextDirection.ltr => EdgeInsets.only(
              left: data.horizontalAvoidance.left,
              top: data.verticalAvoidance.top,
            ),
            TextDirection.rtl => EdgeInsets.only(
              right: data.horizontalAvoidance.right,
              top: data.verticalAvoidance.top,
            ),
          };
          return NavigationObstructionScope(
            obstruction: NavigationObstruction(
              sidebar: sidebar,
              toolbar: data.horizontalAvoidance,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
