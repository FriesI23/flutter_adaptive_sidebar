import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

/// A clipped translucent surface with a backdrop blur.
///
/// The surface paints [backgroundColor], [blurSigma], [boxShadow], and
/// [border] as given. It does not choose a sidebar preset.
class CupertinoFloatingGlassSurface extends StatelessWidget {
  /// Creates a floating glass surface around [child].
  const CupertinoFloatingGlassSurface({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.blurSigma = 10,
    this.boxShadow = const <BoxShadow>[],
    this.border,
    this.clipContent = true,
  });

  /// Content painted above the translucent surface.
  final Widget child;

  /// Surface color. Defaults to the current Cupertino bar background.
  final Color? backgroundColor;

  /// Rounded clipping and shadow shape.
  final BorderRadius borderRadius;

  /// Gaussian backdrop blur strength. Zero draws no blur.
  final double blurSigma;

  /// Drop shadow. An empty list draws none.
  final List<BoxShadow> boxShadow;

  /// Border painted over the surface. Null draws none.
  final BoxBorder? border;

  /// Whether [child] is clipped to [borderRadius] with the glass background.
  ///
  /// Set this to false when the child paints accessibility feedback, such as
  /// a keyboard focus halo, outside its layout bounds. The background, blur,
  /// and border remain clipped to the configured shape.
  final bool clipContent;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground =
        backgroundColor ??
        CupertinoDynamicColor.resolve(
          CupertinoTheme.of(context).barBackgroundColor,
          context,
        );
    Widget surface = ColoredBox(
      color: resolvedBackground,
      child: clipContent ? child : const SizedBox.expand(),
    );
    if (resolvedBackground.a != 1.0 && blurSigma > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      );
    }
    final clippedBackground = ClipRRect(
      borderRadius: borderRadius,
      child: surface,
    );
    Widget clippedSurface = clipContent
        ? clippedBackground
        : Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(child: clippedBackground),
              child,
            ],
          );
    final resolvedBorder = border;
    if (resolvedBorder != null) {
      // A one-sided separator cannot share a radius with BoxDecoration.
      // The clip above already applies [borderRadius].
      final uniformBorder = resolvedBorder.isUniform;
      clippedSurface = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: uniformBorder ? borderRadius : null,
          border: resolvedBorder,
        ),
        child: clippedSurface,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: clippedSurface,
    );
  }
}
