import 'package:flutter/cupertino.dart';

import '../side_navigation_extent.dart';
import '../sidebar_constants.dart';
import 'cupertino_floating_surface.dart';

/// Floating surface for a Cupertino sidebar.
class CupertinoSidebarPanel extends StatelessWidget {
  /// Creates the sidebar panel.
  const CupertinoSidebarPanel({
    super.key,
    required this.width,
    this.backgroundColor,
    required this.contentActive,
    required this.content,
    required this.dragging,
    required this.dragHandleBuilder,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  });

  static const double _resizeHandleWidth = 16;
  static const double _resizeHandleCornerInset = 25;

  /// Current panel width.
  final double width;

  /// Panel surface color. Null uses the Cupertino bar background.
  final Color? backgroundColor;

  /// Whether [content] accepts input and semantics.
  final bool contentActive;

  /// Interior of the panel.
  final Widget content;

  /// Whether a resize drag is active.
  final bool dragging;

  /// Optional visual for the resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Called when a resize drag starts.
  final VoidCallback onResizeStart;

  /// Called with the logical horizontal delta of a resize drag.
  final ValueChanged<double> onResizeUpdate;

  /// Called when a resize drag ends.
  final VoidCallback onResizeEnd;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final destinationLayer = Positioned.fill(
      child: IgnorePointer(
        ignoring: !contentActive,
        child: ExcludeSemantics(
          excluding: !contentActive,
          child: DefaultTextStyle(style: textStyle, child: content),
        ),
      ),
    );
    final surface = CupertinoFloatingGlassSurface(
      key: const ValueKey('cupertino-sidebar-surface'),
      backgroundColor: backgroundColor,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      child: Stack(fit: StackFit.expand, children: [destinationLayer]),
    );
    final resizeHandle = PositionedDirectional(
      end: 0,
      top: _resizeHandleCornerInset,
      bottom: _resizeHandleCornerInset,
      child: IgnorePointer(
        ignoring: !contentActive,
        child: SideNavigationResizeHandle(
          key: const ValueKey('cupertino-sidebar-resize-handle'),
          hitExtent: _resizeHandleWidth,
          dragHandleBuilder: dragHandleBuilder,
          onResizeStart: onResizeStart,
          onResizeUpdate: onResizeUpdate,
          onResizeEnd: onResizeEnd,
        ),
      ),
    );
    final panel = SizedBox(
      key: const ValueKey('cupertino-sidebar-panel'),
      width: width,
      height: double.infinity,
      child: Stack(fit: StackFit.expand, children: [surface, resizeHandle]),
    );

    return AnimatedSize(
      duration: dragging
          ? const Duration(milliseconds: 1)
          : kSidebarAnimationDuration,
      curve: Curves.easeOut,
      alignment: AlignmentDirectional.centerStart,
      child: panel,
    );
  }
}
