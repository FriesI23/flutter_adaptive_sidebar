import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'cupertino_sidebar_theme_data.dart';

/// Applies the app override or Flutter's native Cupertino halo default.
///
/// [child] must contain the focusable region so the native fallback can
/// observe focus changes in its descendant subtree.
Widget buildCupertinoSidebarFocusHalo(
  BuildContext context, {
  required Widget child,
  required bool visible,
  required ShapeDecoration decoration,
}) {
  if (defaultTargetPlatform != TargetPlatform.macOS) {
    return child;
  }
  final builder = CupertinoSidebarThemeData.of(context).focusHaloBuilder;
  final overridden = builder?.call(
    context,
    child: child,
    visible: visible,
    decoration: decoration,
  );
  final shape = decoration.shape;
  final result =
      overridden ??
      switch (shape) {
        RoundedSuperellipseBorder() =>
          CupertinoFocusHalo.withRoundedSuperellipse(
            borderRadius: shape.borderRadius,
            child: child,
          ),
        RoundedRectangleBorder() => CupertinoFocusHalo.withRRect(
          borderRadius: shape.borderRadius,
          child: child,
        ),
        _ => CupertinoFocusHalo.withRect(child: child),
      };
  return result;
}
