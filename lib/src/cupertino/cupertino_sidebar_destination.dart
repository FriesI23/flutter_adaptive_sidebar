import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../adaptive_navigation_destination.dart';
import 'cupertino_focus.dart';
import 'cupertino_sidebar.dart';
import 'cupertino_sidebar_chrome.dart';
import 'cupertino_sidebar_item_style.dart';

/// Height of the selection capsule. The corner radius is half of this.
const double _kSelectionHeight = 44;

/// Space between the capsule and each side of the sidebar.
///
/// Measured from the iPadOS 26 Files highlight.
const double _kSelectionInset = 16;

class _CupertinoSidebarDestinationDefaults {
  const _CupertinoSidebarDestinationDefaults({
    required this.selectedBackgroundColor,
    required this.activeBackgroundColor,
    required this.selectedIconColor,
    required this.unselectedIconColor,
    required this.activeIconColor,
    required this.selectedLabelColor,
    required this.unselectedLabelColor,
    required this.activeLabelColor,
    required this.requestsFocusOnPointerDown,
    required this.showsFocusHalo,
  });

  factory _CupertinoSidebarDestinationDefaults.of(
    CupertinoSidebarStyle style,
    BuildContext context,
  ) {
    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor.withValues(alpha: 1);
    const activeForegroundColor = CupertinoColors.white;
    final usesHalo = defaultTargetPlatform == TargetPlatform.macOS;
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    ).withValues(alpha: 1);
    return switch (style) {
      CupertinoSidebarStyle.liquid => _CupertinoSidebarDestinationDefaults(
        selectedBackgroundColor: primaryColor.withValues(alpha: 0.14),
        activeBackgroundColor: usesHalo
            ? null
            : primaryColor.withValues(alpha: 0.14),
        selectedIconColor: primaryColor,
        unselectedIconColor: labelColor,
        activeIconColor: null,
        selectedLabelColor: primaryColor,
        unselectedLabelColor: labelColor,
        activeLabelColor: null,
        requestsFocusOnPointerDown: false,
        showsFocusHalo: usesHalo,
      ),
      CupertinoSidebarStyle.liquidEdge => _CupertinoSidebarDestinationDefaults(
        selectedBackgroundColor: primaryColor.withValues(alpha: 0.14),
        activeBackgroundColor: usesHalo ? null : primaryColor,
        selectedIconColor: primaryColor,
        unselectedIconColor: primaryColor,
        activeIconColor: usesHalo ? null : activeForegroundColor,
        selectedLabelColor: labelColor,
        unselectedLabelColor: labelColor,
        activeLabelColor: usesHalo ? null : activeForegroundColor,
        requestsFocusOnPointerDown: !usesHalo,
        showsFocusHalo: usesHalo,
      ),
    };
  }

  final Color selectedBackgroundColor;
  final Color? activeBackgroundColor;
  final Color selectedIconColor;
  final Color unselectedIconColor;
  final Color? activeIconColor;
  final Color selectedLabelColor;
  final Color unselectedLabelColor;
  final Color? activeLabelColor;
  final bool requestsFocusOnPointerDown;
  final bool showsFocusHalo;

  Color? backgroundColor({required bool selected, required bool active}) {
    if (active && activeBackgroundColor != null) return activeBackgroundColor;
    return selected ? selectedBackgroundColor : null;
  }

  Color iconColor({required bool selected, required bool active}) {
    if (active && activeIconColor != null) return activeIconColor!;
    return selected ? selectedIconColor : unselectedIconColor;
  }

  Color labelColor({required bool selected, required bool active}) {
    if (active && activeLabelColor != null) return activeLabelColor!;
    return selected ? selectedLabelColor : unselectedLabelColor;
  }
}

/// A Cupertino sidebar row for one navigation destination.
///
/// ```text
/// liquid                   edge
/// o  Label                 o  Label
/// ( o  Label )             ( o  Label )
/// tint                     tint until active
/// ```
///
/// Both styles derive their accent from [CupertinoThemeData.primaryColor].
/// Edge rows retain the last interaction with an opaque accent fill and
/// contrasting content; their unfocused selection keeps a translucent tint.
/// [itemStyle] replaces the fill, icon and label colors, and label type.
class CupertinoSidebarDestination extends StatelessWidget {
  /// Creates a destination row.
  const CupertinoSidebarDestination({
    super.key,
    required this.destination,
    required this.selected,
    this.active = false,
    required this.onPressed,
    this.itemStyle,
  });

  /// Destination rendered by this row.
  final AdaptiveNavigationDestination destination;

  /// Whether this destination is selected.
  final bool selected;

  /// Whether this destination owns the retained edge interaction highlight.
  ///
  /// [CupertinoSidebarNavigation] keeps this stable across theme and content
  /// rebuilds. It has no visual effect on the liquid style.
  final bool active;

  /// Called when the row is pressed.
  final VoidCallback onPressed;

  /// Fill, label colors, and label type. Null keeps the style defaults.
  final CupertinoSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    final defaults = _CupertinoSidebarDestinationDefaults.of(
      CupertinoSidebar.styleOf(context),
      context,
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
            selected: selected,
            active: active,
            defaults: defaults,
            itemStyle: itemStyle,
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
/// Tracks pointer, focus, hover, and selection states for one superellipse.
class _SidebarCapsuleButton extends StatefulWidget {
  const _SidebarCapsuleButton({
    required this.selected,
    required this.active,
    required this.defaults,
    required this.itemStyle,
    required this.labelStyle,
    required this.onPressed,
    required this.child,
  });

  final bool selected;
  final bool active;
  final _CupertinoSidebarDestinationDefaults defaults;
  final CupertinoSidebarItemStyle? itemStyle;
  final TextStyle? labelStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_SidebarCapsuleButton> createState() => _SidebarCapsuleButtonState();
}

class _SidebarCapsuleButtonState extends State<_SidebarCapsuleButton> {
  bool _focused = false;
  bool _pressed = false;
  bool _hovered = false;
  bool _showFocusHighlight = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleFocusChange(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  void _handleHoverChange(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _handleShowFocusHighlight(bool value) {
    if (_showFocusHighlight == value) return;
    setState(() => _showFocusHighlight = value);
  }

  void _handlePointerDown(BuildContext focusContext, PointerDownEvent event) {
    _setPressed(true);
    if (widget.defaults.requestsFocusOnPointerDown) {
      Focus.of(focusContext).requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visuallyFocused = widget.active || _focused;
    final states = <WidgetState>{
      if (widget.selected) WidgetState.selected,
      if (visuallyFocused) WidgetState.focused,
      if (_pressed) WidgetState.pressed,
      if (_hovered) WidgetState.hovered,
    };
    final active = visuallyFocused || _pressed;
    final background = CupertinoSidebarItemStyle.backgroundColorOf(
      widget.itemStyle,
      context,
      states: states,
      fallback: widget.defaults.backgroundColor(
        selected: widget.selected,
        active: active,
      ),
    );
    final iconColor = CupertinoSidebarItemStyle.iconColorOf(
      widget.itemStyle,
      context: context,
      states: states,
      selectedFallback: widget.defaults.iconColor(
        selected: true,
        active: active,
      ),
      unselectedFallback: widget.defaults.iconColor(
        selected: false,
        active: active,
      ),
    );
    final foreground = CupertinoSidebarItemStyle.labelColorOf(
      widget.itemStyle,
      context: context,
      states: states,
      selectedFallback: widget.defaults.labelColor(
        selected: true,
        active: active,
      ),
      unselectedFallback: widget.defaults.labelColor(
        selected: false,
        active: active,
      ),
    );
    final textStyle = CupertinoTheme.of(context).textTheme.actionTextStyle
        .merge(widget.labelStyle)
        .copyWith(color: foreground);
    final borderRadius = BorderRadius.circular(_kSelectionHeight / 2);
    final focusable = FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onFocusChange: _handleFocusChange,
      onShowHoverHighlight: _handleHoverChange,
      onShowFocusHighlight: _handleShowFocusHighlight,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Builder(
        builder: (focusContext) => Listener(
          onPointerDown: (event) => _handlePointerDown(focusContext, event),
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onLongPressStart: (_) => _setPressed(true),
            onLongPressEnd: (_) => _setPressed(false),
            onLongPressCancel: () => _setPressed(false),
            onTap: () {
              _setPressed(false);
              widget.onPressed();
            },
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: background,
                shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
              ),
              child: SizedBox(
                height: _kSelectionHeight,
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 12,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: iconColor,
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
        ),
      ),
    );
    return buildCupertinoSidebarFocusHalo(
      context,
      visible: widget.defaults.showsFocusHalo && _showFocusHighlight,
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(borderRadius: borderRadius),
      ),
      child: focusable,
    );
  }
}
