import 'package:flutter/cupertino.dart';

import '../side_navigation_extent.dart';
import '../sidebar_constants.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_sidebar_chrome.dart';

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
    this.chrome = CupertinoSidebarChrome.liquid,
  });

  static const double _resizeHandleWidth = 16;

  /// Current panel width.
  final double width;

  /// Panel surface color. Null uses [CupertinoSidebarChrome.fill].
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

  /// Edge treatment for the glass.
  final CupertinoSidebarChrome chrome;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final resolvedBackgroundColor = backgroundColor == null
        ? chrome.fill.resolve(context)
        : CupertinoDynamicColor.resolve(backgroundColor!, context);
    final destinationLayer = Positioned.fill(
      child: IgnorePointer(
        ignoring: !contentActive,
        child: ExcludeSemantics(
          excluding: !contentActive,
          child: DefaultTextStyle(
            style: textStyle,
            child: _insetContent(context, content),
          ),
        ),
      ),
    );
    final surface = CupertinoFloatingGlassSurface(
      key: const ValueKey('cupertino-sidebar-surface'),
      backgroundColor: resolvedBackgroundColor,
      borderRadius: chrome.borderRadius,
      blurSigma: chrome.blurSigma,
      boxShadow: chrome.boxShadow,
      border: chrome.border.resolve(context),
      child: Stack(fit: StackFit.expand, children: [destinationLayer]),
    );
    final resizeHandle = PositionedDirectional(
      end: 0,
      top: chrome.resizeHandleCornerInset,
      bottom: chrome.resizeHandleCornerInset,
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

  /// Keeps destinations clear of the status bar, home indicator, and leading
  /// safe area while the glass itself stays flush with the window.
  Widget _insetContent(BuildContext context, Widget content) {
    if (!chrome.flushToWindowEdge) return content;
    final padding = MediaQuery.paddingOf(context);
    final direction = Directionality.of(context);
    final leading = direction == TextDirection.ltr
        ? padding.left
        : padding.right;
    return MediaQuery(
      data: MediaQuery.of(context).removePadding(
        removeTop: true,
        removeBottom: true,
        removeLeft: direction == TextDirection.ltr,
        removeRight: direction == TextDirection.rtl,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: padding.top,
          bottom: padding.bottom,
          left: direction == TextDirection.ltr ? leading : 0,
          right: direction == TextDirection.rtl ? leading : 0,
        ),
        child: content,
      ),
    );
  }
}
