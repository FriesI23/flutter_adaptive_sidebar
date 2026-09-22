import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

/// A clipped translucent surface with a backdrop blur.
class CupertinoFloatingGlassSurface extends StatelessWidget {
  /// Creates a floating glass surface around [child].
  const CupertinoFloatingGlassSurface({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.blurSigma = 10,
  });

  static const BoxShadow _shadow = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  /// Content painted above the translucent surface.
  final Widget child;

  /// Surface color. Defaults to the current Cupertino bar background.
  final Color? backgroundColor;

  /// Rounded clipping and shadow shape.
  final BorderRadius borderRadius;

  /// Gaussian backdrop blur strength.
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final resolvedBackground =
        backgroundColor ??
        CupertinoDynamicColor.resolve(
          CupertinoTheme.of(context).barBackgroundColor,
          context,
        );
    Widget surface = ColoredBox(color: resolvedBackground, child: child);
    if (resolvedBackground.a != 1.0 && blurSigma > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      );
    }
    Widget clippedSurface = ClipRRect(
      borderRadius: borderRadius,
      child: surface,
    );
    if (dark) {
      clippedSurface = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: const Color(0x24FFFFFF), width: 0.5),
        ),
        child: clippedSurface,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: const [_shadow],
      ),
      child: clippedSurface,
    );
  }
}
