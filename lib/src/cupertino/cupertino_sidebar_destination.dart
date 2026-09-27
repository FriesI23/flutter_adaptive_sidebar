import 'package:flutter/cupertino.dart';

import '../adaptive_navigation_destination.dart';
import 'cupertino_sidebar.dart';
import 'cupertino_sidebar_item_style.dart';

/// Height of the selection capsule. The corner radius is half of this.
const double _kSelectionHeight = 44;

/// Space between the capsule and each side of the sidebar.
///
/// Measured from the iPadOS 26 Files highlight.
const double _kSelectionInset = 16;

/// A Cupertino sidebar row for one navigation destination.
///
/// ```text
/// liquid                   edge
/// o  Label                 o  Label
/// ( o  Label )             ( O  LABEL )
/// tint                     solid, contrasting
/// ```
///
/// Both styles share one capsule. A tap selects the row. The label dims only
/// while the row is held as a long press. The edge fill is used inside
/// [CupertinoSidebar.edge]. [itemStyle] replaces the fill, the label colors,
/// and the label type.
class CupertinoSidebarDestination extends StatelessWidget {
  /// Creates a destination row.
  const CupertinoSidebarDestination({
    super.key,
    required this.destination,
    required this.selected,
    required this.onPressed,
    this.itemStyle,
  });

  /// Destination rendered by this row.
  final AdaptiveNavigationDestination destination;

  /// Whether this destination is selected.
  final bool selected;

  /// Called when the row is pressed.
  final VoidCallback onPressed;

  /// Fill, label colors, and label type. Null keeps the style defaults.
  final CupertinoSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final filled = selected && CupertinoSidebar.filledSelectionOf(context);
    final foregroundColor = CupertinoSidebarItemStyle.foregroundOf(
      itemStyle,
      selected: selected,
      selectedFallback: (filled ? theme.primaryContrastingColor : primaryColor)
          .withValues(alpha: 1),
      unselectedFallback: labelColor.withValues(alpha: 1),
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

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.effectiveSemanticsLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kSelectionInset,
          vertical: 2,
        ),
        child: SizedBox(
          width: double.infinity,
          child: _SidebarCapsuleButton(
            color: !selected
                ? null
                : CupertinoSidebarItemStyle.selectedColorOf(
                    itemStyle,
                    filled
                        ? primaryColor
                        : primaryColor.withValues(alpha: 0.14),
                  ),
            foregroundColor: foregroundColor,
            labelStyle: itemStyle?.labelStyle,
            onPressed: onPressed,
            child: Row(children: [icon, const SizedBox(width: 12), label]),
          ),
        ),
      ),
    );
  }
}

/// Capsule used by every Cupertino sidebar row.
///
/// [CupertinoButton] fades on pointer down and draws a superellipse. A tap
/// here changes nothing until it selects, and the label color changes only
/// after a long press.
class _SidebarCapsuleButton extends StatefulWidget {
  const _SidebarCapsuleButton({
    required this.color,
    required this.foregroundColor,
    required this.labelStyle,
    required this.onPressed,
    required this.child,
  });

  final Color? color;
  final Color foregroundColor;
  final TextStyle? labelStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_SidebarCapsuleButton> createState() => _SidebarCapsuleButtonState();
}

class _SidebarCapsuleButtonState extends State<_SidebarCapsuleButton> {
  bool _held = false;
  bool _showFocusHighlight = false;

  void _hold(bool value) {
    if (_held == value) {
      return;
    }
    setState(() => _held = value);
  }

  void _handleShowFocusHighlight(bool value) {
    if (_showFocusHighlight == value) return;
    setState(() => _showFocusHighlight = value);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _held
        ? widget.foregroundColor.withValues(alpha: 0.4)
        : widget.foregroundColor;
    final textStyle = CupertinoTheme.of(context).textTheme.actionTextStyle
        .merge(widget.labelStyle)
        .copyWith(color: foreground);
    final focusColor = CupertinoTheme.of(
      context,
    ).primaryColor.withValues(alpha: 0.8);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: _handleShowFocusHighlight,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onLongPressStart: (_) => _hold(true),
        onLongPressEnd: (_) => _hold(false),
        onLongPressCancel: () => _hold(false),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.color,
            border: _showFocusHighlight
                ? Border.all(color: focusColor, width: 3)
                : null,
            borderRadius: BorderRadius.circular(_kSelectionHeight / 2),
          ),
          child: SizedBox(
            height: _kSelectionHeight,
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: IconTheme(
                data: IconThemeData(
                  color: foreground,
                  size: (textStyle.fontSize ?? 17) * 1.2,
                ),
                child: DefaultTextStyle(
                  style: textStyle,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
