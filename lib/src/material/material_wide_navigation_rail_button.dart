import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../adaptive_navigation_destination.dart';
import 'material_sidebar_item_style.dart';
import 'material_sidebar_metrics.dart';

/// A Material 3 wide-navigation-rail destination button.
///
/// ```text
/// collapsed      expanded
/// +----+         +--------------+
/// | o  |         | o   Label    |
/// +----+         +--------------+
/// ```
class MaterialWideNavigationRailButton extends StatelessWidget {
  /// Creates a rail destination button.
  ///
  /// The button reads its width and expand animation from the enclosing
  /// [MaterialSidebar]. [itemStyle] replaces the indicator, the label colors,
  /// and the label type.
  const MaterialWideNavigationRailButton({
    super.key,
    required this.destination,
    required this.selected,
    required this.onPressed,
    this.itemStyle,
  });

  static const double _collapsedSlotHeight = 64.0;
  static const double _buttonHeight = 56.0;
  static const double _iconSize = 24.0;
  static const double _collapsedButtonWidth = 56.0;
  static const double _collapsedIndicatorHeight = 32.0;
  static const double _collapsedIconLabelSpacing = 4.0;
  static const double _collapsedBottomSpacing = 12.0;
  static const double _expandedHorizontalMargin = 20.0;
  static const double _expandedContentInset = 16.0;
  static const double _expandedIconLabelSpacing = 8.0;

  /// Destination rendered by this button.
  final AdaptiveNavigationDestination destination;

  /// Whether this destination is selected.
  final bool selected;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// Indicator, label colors, and label type. Null keeps the rail theme.
  final MaterialSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    final metrics = MaterialSidebarMetrics.of(context);
    final animation = NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final slotWidth = lerpDouble(
          metrics.collapsedWidth,
          metrics.expandedWidth,
          progress,
        )!;
        final buttonWidth = lerpDouble(
          _collapsedButtonWidth,
          metrics.expandedWidth - _expandedHorizontalMargin * 2,
          progress,
        )!;
        final buttonHeight = lerpDouble(
          _collapsedIndicatorHeight,
          _buttonHeight,
          progress,
        )!;
        final collapsedSlotHeight = _collapsedHeightFor(context);
        final slotHeight = lerpDouble(
          collapsedSlotHeight,
          _buttonHeight,
          progress,
        )!;
        return SizedBox(
          width: slotWidth,
          height: slotHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                width: buttonWidth,
                height: buttonHeight,
                child: _MaterialWideNavigationRailButtonSurface(
                  destination: destination,
                  selected: selected,
                  progress: progress,
                  itemStyle: itemStyle,
                  onPressed: onPressed,
                ),
              ),
              PositionedDirectional(
                start: (slotWidth - _collapsedButtonWidth) / 2,
                top: _collapsedIndicatorHeight + _collapsedIconLabelSpacing,
                width: _collapsedButtonWidth,
                child: ExcludeSemantics(
                  child: Opacity(
                    key: const ValueKey('material-rail-collapsed-label'),
                    opacity: 1 - progress,
                    child: _MaterialWideNavigationRailLabel(
                      destination: destination,
                      selected: selected,
                      expanded: false,
                      itemStyle: itemStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _collapsedHeightFor(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: destination.label,
        style: _materialRailLabelStyle(
          context,
          selected: selected,
          expanded: false,
          itemStyle: itemStyle,
        ),
      ),
      maxLines: 2,
      locale: Localizations.maybeLocaleOf(context),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: _collapsedButtonWidth);
    final contentHeight =
        _collapsedIndicatorHeight +
        _collapsedIconLabelSpacing +
        painter.height +
        _collapsedBottomSpacing;
    return contentHeight < _collapsedSlotHeight
        ? _collapsedSlotHeight
        : contentHeight;
  }
}

class _MaterialWideNavigationRailButtonSurface extends StatelessWidget {
  const _MaterialWideNavigationRailButtonSurface({
    required this.destination,
    required this.selected,
    required this.progress,
    required this.itemStyle,
    required this.onPressed,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final double progress;
  final MaterialSidebarItemStyle? itemStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final railTheme = NavigationRailTheme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedIconTheme =
        railTheme.selectedIconTheme ??
        IconThemeData(
          color: colorScheme.onSecondaryContainer,
          size: MaterialWideNavigationRailButton._iconSize,
        );
    final unselectedIconTheme =
        railTheme.unselectedIconTheme ??
        IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: MaterialWideNavigationRailButton._iconSize,
        );
    final indicatorColor = MaterialSidebarItemStyle.selectedColorOf(
      itemStyle,
      railTheme.indicatorColor ?? colorScheme.secondaryContainer,
    );
    final indicatorShape = railTheme.indicatorShape ?? const StadiumBorder();
    final iconStart = lerpDouble(
      (MaterialWideNavigationRailButton._collapsedButtonWidth -
              MaterialWideNavigationRailButton._iconSize) /
          2,
      MaterialWideNavigationRailButton._expandedContentInset,
      progress,
    )!;
    final iconTop = lerpDouble(4, 16, progress)!;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.effectiveSemanticsLabel,
      excludeSemantics: true,
      onTap: onPressed,
      child: TextButton(
        onPressed: onPressed,
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          minimumSize: WidgetStatePropertyAll(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: WidgetStatePropertyAll(StadiumBorder()),
        ),
        child: Stack(
          children: [
            _MaterialWideNavigationRailIndicator(
              selected: selected,
              color: indicatorColor,
              shape: indicatorShape,
            ),
            PositionedDirectional(
              start: iconStart,
              top: iconTop,
              width: MaterialWideNavigationRailButton._iconSize,
              height: MaterialWideNavigationRailButton._iconSize,
              child: _MaterialWideNavigationRailIcon(
                destination: destination,
                selected: selected,
                selectedTheme: _iconTheme(
                  selectedIconTheme,
                  itemStyle?.selectedForegroundColor,
                ),
                unselectedTheme: _iconTheme(
                  unselectedIconTheme,
                  itemStyle?.foregroundColor,
                ),
              ),
            ),
            PositionedDirectional(
              start:
                  MaterialWideNavigationRailButton._expandedContentInset +
                  MaterialWideNavigationRailButton._iconSize +
                  MaterialWideNavigationRailButton._expandedIconLabelSpacing,
              end: MaterialWideNavigationRailButton._expandedContentInset,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Opacity(
                  key: const ValueKey('material-rail-expanded-label'),
                  opacity: progress,
                  child: _MaterialWideNavigationRailLabel(
                    destination: destination,
                    selected: selected,
                    expanded: true,
                    itemStyle: itemStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialWideNavigationRailIndicator extends StatelessWidget {
  const _MaterialWideNavigationRailIndicator({
    required this.selected,
    required this.color,
    required this.shape,
  });

  final bool selected;
  final Color color;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        key: const ValueKey('material-rail-indicator'),
        width: double.infinity,
        height: double.infinity,
        child: AnimatedOpacity(
          opacity: selected ? 1 : 0,
          duration: kThemeAnimationDuration,
          curve: Curves.easeInOut,
          child: DecoratedBox(
            decoration: ShapeDecoration(color: color, shape: shape),
          ),
        ),
      ),
    );
  }
}

class _MaterialWideNavigationRailIcon extends StatelessWidget {
  const _MaterialWideNavigationRailIcon({
    required this.destination,
    required this.selected,
    required this.selectedTheme,
    required this.unselectedTheme,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final IconThemeData selectedTheme;
  final IconThemeData unselectedTheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: IconTheme(
        key: ValueKey(selected),
        data: selected ? selectedTheme : unselectedTheme,
        child: selected
            ? destination.icons.materialSelected
            : destination.icons.material,
      ),
    );
  }
}

class _MaterialWideNavigationRailLabel extends StatelessWidget {
  const _MaterialWideNavigationRailLabel({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.itemStyle,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final bool expanded;
  final MaterialSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      destination.label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: expanded ? null : TextAlign.center,
      style: _materialRailLabelStyle(
        context,
        selected: selected,
        expanded: expanded,
        itemStyle: itemStyle,
      ),
    );
  }
}

IconThemeData _iconTheme(IconThemeData theme, Color? color) {
  if (color == null) return theme;
  return theme.copyWith(color: color);
}

TextStyle _materialRailLabelStyle(
  BuildContext context, {
  required bool selected,
  required bool expanded,
  MaterialSidebarItemStyle? itemStyle,
}) {
  final theme = Theme.of(context);
  final railTheme = NavigationRailTheme.of(context);
  final baseStyle = expanded
      ? theme.textTheme.labelLarge
      : theme.textTheme.labelMedium;
  final fallback = (baseStyle ?? const TextStyle()).merge(
    selected
        ? railTheme.selectedLabelTextStyle
        : railTheme.unselectedLabelTextStyle,
  );
  return MaterialSidebarItemStyle.labelStyleOf(
    itemStyle,
    fallback: fallback,
    color: MaterialSidebarItemStyle.foregroundOf(
      itemStyle,
      selected: selected,
      selectedFallback: theme.colorScheme.secondary,
      unselectedFallback: theme.colorScheme.onSurfaceVariant,
    ),
  );
}
