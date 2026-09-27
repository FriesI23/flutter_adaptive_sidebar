import 'package:flutter/widgets.dart';

/// Clears sidebar focus when a pointer tap lands outside [groupId].
///
/// Regions that share [groupId] count as one target, so a tap on another
/// sidebar control does not count as outside. A tap outside unfocuses only
/// when the primary focus is inside this group. Selection is left alone.
class SidebarFocusRegion extends StatelessWidget {
  /// Creates a focus region for [groupId].
  const SidebarFocusRegion({
    super.key,
    required this.groupId,
    required this.child,
  });

  /// Identity shared by every focusable island of one sidebar.
  final Object groupId;

  /// Focusable sidebar controls.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: groupId,
      onTapOutside: (_) => _unfocusIfInside(groupId),
      child: _SidebarFocusMarker(groupId: groupId, child: child),
    );
  }
}

void _unfocusIfInside(Object groupId) {
  final focus = FocusManager.instance.primaryFocus;
  final context = focus?.context;
  if (context == null || !context.mounted) return;
  final marker = context.findAncestorWidgetOfExactType<_SidebarFocusMarker>();
  if (marker?.groupId != groupId) return;
  focus!.unfocus();
}

class _SidebarFocusMarker extends InheritedWidget {
  const _SidebarFocusMarker({required this.groupId, required super.child});

  final Object groupId;

  @override
  bool updateShouldNotify(_SidebarFocusMarker oldWidget) =>
      groupId != oldWidget.groupId;
}
