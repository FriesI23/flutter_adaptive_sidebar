import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;

import '../adaptive_navigation_controller.dart';
import '../navigation_obstruction.dart';
import '../side_navigation_extent.dart';
import '../sidebar_constants.dart';
import '../sidebar_leading_scope.dart';
import 'cupertino_sidebar_button.dart';
import 'cupertino_sidebar_panel.dart';

// Measured from UITabBarController.mode = .tabSidebar on iPadOS 26.5: the
// floating Sidebar surface is inset 10pt from every window edge.
const double _kSidebarSurfaceMargin = 10;

/// Hideable Cupertino sidebar placed beside [child].
///
/// The sidebar can be completely hidden, but it never collapses to an
/// icon-only rail. Visibility is [AdaptiveNavigationController.expanded].
/// [content] fills the panel. Use `CupertinoSidebarNavigation` for the
/// default destination list.
class CupertinoSidebar extends StatefulWidget {
  /// Creates a Cupertino sidebar around [child].
  const CupertinoSidebar({
    super.key,
    required this.controller,
    required this.content,
    required this.child,
    this.extent = const SideNavigationExtent(200),
    this.dragHandleBuilder,
    this.expandLabel,
    this.collapseLabel,
    this.tooltipBuilder,
    this.backgroundColor,
  });

  /// Shared selection, visibility, and width.
  final AdaptiveNavigationController controller;

  /// Interior of the sidebar panel.
  final Widget content;

  /// Content laid out beside the sidebar.
  final Widget child;

  /// Automatic and manually resizable panel-width policy.
  final SideNavigationExtent extent;

  /// Optional visual displayed inside the resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Action label used while the sidebar is hidden.
  final String? expandLabel;

  /// Action label used while the sidebar is visible.
  final String? collapseLabel;

  /// Optional tooltip wrapper for the show and hide button.
  final NavigationTooltipBuilder? tooltipBuilder;

  /// Shared background for the sidebar panel and the content beside it.
  ///
  /// When null, both use [CupertinoThemeData.scaffoldBackgroundColor]. The
  /// package also applies that color to the content's bar background, so the
  /// page does not tint itself with a separate translucent bar color.
  final Color? backgroundColor;

  @override
  State<CupertinoSidebar> createState() => _CupertinoSidebarState();
}

class _CupertinoSidebarState extends State<CupertinoSidebar>
    with SingleTickerProviderStateMixin {
  static const double _contentGap = 12;
  static const double _edgeGestureWidth = 20;
  static const double _appBarLeadingPadding = 16;
  static const double _panelToggleTrailingPadding = 8;

  late final AnimationController _animation = AnimationController(
    vsync: this,
    value: widget.controller.expanded ? 1 : 0,
  );
  late final Animation<double> _curvedAnimation = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeOut,
  );
  final FocusNode _toggleFocusNode = FocusNode(
    debugLabel: 'cupertino-sidebar-toggle',
  );
  double _edgeDragDistance = 0;

  AdaptiveNavigationController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : kSidebarAnimationDuration;
  }

  @override
  void didUpdateWidget(covariant CupertinoSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
    _syncExpandedAnimation();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _toggleFocusNode.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _syncExpandedAnimation();
    if (mounted) setState(() {});
  }

  void _syncExpandedAnimation() {
    if (widget.controller.expanded) {
      _animation.forward();
    } else {
      _animation.reverse();
    }
  }

  void _handleResizeStart(double windowWidth) {
    _controller.beginResize(widget.extent, windowWidth: windowWidth);
  }

  void _handleResizeUpdate(double logicalDelta, double windowWidth) {
    _controller.updateResize(
      logicalDelta,
      widget.extent,
      windowWidth: windowWidth,
    );
  }

  void _handleEdgeDragStart() => _edgeDragDistance = 0;

  void _handleEdgeDragUpdate(double logicalDelta) {
    _edgeDragDistance += logicalDelta;
  }

  void _handleEdgeDragEnd(double logicalVelocity) {
    final shouldOpen =
        _edgeDragDistance >= kTouchSlop || logicalVelocity >= kMinFlingVelocity;
    _edgeDragDistance = 0;
    if (!shouldOpen || _controller.expanded) return;
    _controller.expanded = true;
  }

  void _handleEdgeDragCancel() => _edgeDragDistance = 0;

  @override
  Widget build(BuildContext context) {
    final expandNavigationLabel =
        widget.expandLabel ??
        Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        )?.collapsedIconTapHint ??
        'Expand';
    final collapseNavigationLabel =
        widget.collapseLabel ??
        Localizations.of<MaterialLocalizations>(
          context,
          MaterialLocalizations,
        )?.expandedIconTapHint ??
        'Collapse';
    final windowWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = _controller.effectiveWidth(
      widget.extent,
      windowWidth: windowWidth,
    );
    final mediaPadding = MediaQuery.paddingOf(context);
    final direction = Directionality.of(context);
    final obstruction = NavigationObstructionScope.of(context);
    final leadingSafeMargin = math.max(
      _kSidebarSurfaceMargin,
      direction == TextDirection.ltr ? mediaPadding.left : mediaPadding.right,
    );
    // The traffic-light row is the ordinary toolbar, not the extra vertical
    // corner avoidance. Horizontal avoidance still shifts the button aside.
    final buttonTop = math.max(_kSidebarSurfaceMargin, mediaPadding.top);
    final sideNavigationStart = direction == TextDirection.ltr
        ? obstruction.sidebar.left
        : obstruction.sidebar.right;
    final sideNavigationEnd = direction == TextDirection.ltr
        ? obstruction.sidebar.right
        : obstruction.sidebar.left;
    final visibleButtonStart =
        leadingSafeMargin +
        panelWidth -
        math.max(sideNavigationEnd, _panelToggleTrailingPadding) -
        SidebarLeadingScope.buttonExtent;
    final hiddenButtonStart = sideNavigationStart + _appBarLeadingPadding;
    final branchMediaQuery = MediaQuery.of(
      context,
    ).copyWith(padding: mediaPadding.copyWith(top: buttonTop));
    final branchMediaQueryWithoutLeadingPadding = branchMediaQuery
        .removePadding(
          removeLeft: direction == TextDirection.ltr,
          removeRight: direction == TextDirection.rtl,
        );
    final sharedBackground = CupertinoDynamicColor.resolve(
      widget.backgroundColor ??
          CupertinoTheme.of(context).scaffoldBackgroundColor,
      context,
    );
    final content = CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        scaffoldBackgroundColor: sharedBackground,
        barBackgroundColor: sharedBackground,
      ),
      child: widget.child,
    );
    return AnimatedBuilder(
      animation: _curvedAnimation,
      child: content,
      builder: (context, child) {
        final expandedProgress = _curvedAnimation.value;
        final panelActive = _animation.value > 0;
        final appBarProgress = 1 - expandedProgress;
        final toolbarAvoidance = EdgeInsets.fromLTRB(
          obstruction.toolbar.left * appBarProgress,
          0,
          obstruction.toolbar.right * appBarProgress,
          0,
        );
        final buttonStart =
            hiddenButtonStart +
            (visibleButtonStart - hiddenButtonStart) * expandedProgress;
        final effectiveBranchMediaQuery = branchMediaQuery.copyWith(
          padding: EdgeInsets.lerp(
            branchMediaQuery.padding,
            branchMediaQueryWithoutLeadingPadding.padding,
            expandedProgress,
          ),
          viewPadding: EdgeInsets.lerp(
            branchMediaQuery.viewPadding,
            branchMediaQueryWithoutLeadingPadding.viewPadding,
            expandedProgress,
          ),
        );
        final branch = _CupertinoSidebarBranch(
          occupiedSpan:
              (leadingSafeMargin + panelWidth + _contentGap) * expandedProgress,
          child: SidebarLeadingScope(
            toolbarAvoidance: toolbarAvoidance,
            progress: appBarProgress,
            child: MediaQuery(data: effectiveBranchMediaQuery, child: child!),
          ),
        );
        final stack = Stack(
          key: const ValueKey('cupertino-sidebar-beside-host'),
          fit: StackFit.expand,
          children: [
            branch,
            if (panelActive)
              _CupertinoSidebarAnimatedPanel(
                progress: expandedProgress,
                child: CupertinoSidebarPanel(
                  width: panelWidth,
                  backgroundColor: sharedBackground,
                  contentActive: expandedProgress == 1,
                  content: widget.content,
                  dragging: _controller.resizing,
                  dragHandleBuilder: widget.dragHandleBuilder,
                  onResizeStart: () => _handleResizeStart(windowWidth),
                  onResizeUpdate: (delta) =>
                      _handleResizeUpdate(delta, windowWidth),
                  onResizeEnd: _controller.endResize,
                ),
              ),
            PositionedDirectional(
              key: const ValueKey('cupertino-sidebar-toggle-position'),
              start: buttonStart,
              top: buttonTop,
              width: SidebarLeadingScope.buttonExtent,
              height: SidebarLeadingScope.buttonExtent,
              child: CupertinoSidebarButton(
                focusNode: _toggleFocusNode,
                label: _controller.expanded
                    ? collapseNavigationLabel
                    : expandNavigationLabel,
                onPressed: _controller.toggleExpanded,
                buttonKey: const ValueKey('cupertino-sidebar-toggle'),
                tooltipBuilder: widget.tooltipBuilder,
              ),
            ),
          ],
        );
        final hosted = ColoredBox(
          key: const ValueKey('cupertino-sidebar-backdrop'),
          color: sharedBackground,
          child: stack,
        );
        return _CupertinoSidebarEdgeGesture(
          enabled: _animation.value == 0,
          edgeWidth: _edgeGestureWidth,
          onStart: _handleEdgeDragStart,
          onUpdate: _handleEdgeDragUpdate,
          onEnd: _handleEdgeDragEnd,
          onCancel: _handleEdgeDragCancel,
          child: hosted,
        );
      },
    );
  }
}

class _CupertinoSidebarEdgeGesture extends StatelessWidget {
  const _CupertinoSidebarEdgeGesture({
    required this.enabled,
    required this.edgeWidth,
    required this.onStart,
    required this.onUpdate,
    required this.onEnd,
    required this.onCancel,
    required this.child,
  });

  final bool enabled;
  final double edgeWidth;
  final VoidCallback onStart;
  final ValueChanged<double> onUpdate;
  final ValueChanged<double> onEnd;
  final VoidCallback onCancel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final viewWidth = MediaQuery.sizeOf(context).width;
    return RawGestureDetector(
      key: const ValueKey('cupertino-sidebar-edge-gesture'),
      behavior: HitTestBehavior.translucent,
      gestures: enabled
          ? <Type, GestureRecognizerFactory>{
              _CupertinoSidebarEdgeDragRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    _CupertinoSidebarEdgeDragRecognizer
                  >(_CupertinoSidebarEdgeDragRecognizer.new, (recognizer) {
                    recognizer
                      ..edgeWidth = edgeWidth
                      ..viewWidth = viewWidth
                      ..textDirection = direction
                      ..onStart = (_) {
                        onStart();
                      }
                      ..onUpdate = (details) {
                        final logicalDelta = direction == TextDirection.ltr
                            ? details.delta.dx
                            : -details.delta.dx;
                        onUpdate(logicalDelta);
                      }
                      ..onEnd = (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        final logicalVelocity = direction == TextDirection.ltr
                            ? velocity
                            : -velocity;
                        onEnd(logicalVelocity);
                      }
                      ..onCancel = onCancel;
                  }),
            }
          : const <Type, GestureRecognizerFactory>{},
      child: child,
    );
  }
}

class _CupertinoSidebarEdgeDragRecognizer
    extends HorizontalDragGestureRecognizer {
  double edgeWidth = 0;
  double viewWidth = 0;
  TextDirection textDirection = TextDirection.ltr;

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (!super.isPointerAllowed(event)) return false;
    return switch (textDirection) {
      TextDirection.ltr => event.position.dx <= edgeWidth,
      TextDirection.rtl => event.position.dx >= viewWidth - edgeWidth,
    };
  }

  @override
  String get debugDescription => 'cupertino sidebar edge drag';
}

class _CupertinoSidebarBranch extends StatelessWidget {
  const _CupertinoSidebarBranch({
    required this.occupiedSpan,
    required this.child,
  });

  final double occupiedSpan;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('cupertino-sidebar-branch-safe-span'),
      padding: EdgeInsetsDirectional.only(start: occupiedSpan),
      child: child,
    );
  }
}

class _CupertinoSidebarAnimatedPanel extends StatelessWidget {
  const _CupertinoSidebarAnimatedPanel({
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return SafeArea(
      minimum: const EdgeInsets.all(_kSidebarSurfaceMargin),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionalTranslation(
          translation: Offset(
            (direction == TextDirection.ltr ? -1 : 1) * (1 - progress),
            0,
          ),
          child: Opacity(opacity: progress, child: child),
        ),
      ),
    );
  }
}
