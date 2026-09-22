import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter/rendering.dart';

import '../adaptive_navigation_controller.dart';
import '../navigation_obstruction.dart';
import '../side_navigation_extent.dart';
import '../sidebar_constants.dart';
import '../sidebar_leading_scope.dart';
import 'cupertino_sidebar_button.dart';
import 'cupertino_sidebar_collapsed_bar.dart';
import 'cupertino_sidebar_panel.dart';

// Measured from UITabBarController.mode = .tabSidebar on iPadOS 26.5: the
// floating Sidebar surface is inset 10pt from every window edge.
const double _kSidebarSurfaceMargin = 10;

/// Opacity of the sidebar panel's glass fill.
const double kCupertinoSidebarGlassAlpha = 0.7;

/// Opacity of the collapsed bar's glass fill.
///
/// The bar is painted over the page bar. Two layers at this opacity composite
/// to about [kCupertinoSidebarGlassAlpha]: `1 - (1 - 0.45) * (1 - 0.45)`.
const double kCupertinoSidebarCollapsedBarGlassAlpha = 0.45;

/// Destination-area width of the previous 44pt collapsed capsule.
///
/// Pair it with [SidebarLeadingScope.buttonExtent]. The sidebar defaults to
/// [kCupertinoSidebarCollapsedBarMeasuredWidth].
const double kCupertinoSidebarCollapsedBarMinimumDestinationExtent = 88;

/// Hideable Cupertino sidebar placed beside [child].
///
/// The sidebar can be completely hidden, but it never collapses to an
/// icon-only rail. Visibility is [AdaptiveNavigationController.expanded].
/// [content] fills the panel. Use `CupertinoSidebarNavigation` for the
/// default destination list.
///
/// [collapsedBar] shows a horizontal bar in the page navigation bar while the
/// panel is hidden. Place [CupertinoSidebarMiddle] in that bar's middle slot.
///
/// ```text
/// open                    hidden, no bar
/// +------+------------+   [=] +--------------+
/// | side |   child    |       |    child     |
/// +------+------------+       +--------------+
///
/// hidden, collapsed bar
///         +----------------------+
///         | [=] Home   Search   |
///         +----------------------+
/// +------------------------------------------+
/// |                 child                    |
/// +------------------------------------------+
/// ```
class CupertinoSidebar extends StatefulWidget {
  /// Creates a Cupertino sidebar around [child].
  const CupertinoSidebar({
    super.key,
    required this.controller,
    required this.content,
    required this.child,
    this.collapsedBar,
    this.collapsedBarHeight = kCupertinoSidebarCollapsedBarMeasuredHeight,
    this.collapsedBarMinimumDestinationExtent =
        kCupertinoSidebarCollapsedBarMeasuredWidth,
    this.collapsedBarSeparator = false,
    this.collapsedBarTransitionBuilder =
        CupertinoSidebarCollapsedBarTransition.drop,
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

  /// Horizontal bar shown while the sidebar is hidden.
  ///
  /// Null keeps the sidebar fully hidden and leaves the toggle in the page's
  /// leading slot. When set, the toggle moves to the start of this bar and
  /// [CupertinoSidebarMiddle] swaps it with the page title.
  ///
  /// The bar keeps the sidebar button plus
  /// [collapsedBarMinimumDestinationExtent]. Anything narrower overflows.
  final Widget? collapsedBar;

  /// Height of [collapsedBar], and of the toggle inside it.
  ///
  /// Defaults to [kCupertinoSidebarCollapsedBarMeasuredHeight]. Pass
  /// [SidebarLeadingScope.buttonExtent] for the previous 44pt capsule, and
  /// the same value to [CupertinoSidebarCollapsedBar.height].
  ///
  /// ```text
  /// measured                 previous
  /// +----------------+       +----------------------+
  /// | [=] Recents    |       | [=]  Home            |
  /// +----------------+       +----------------------+
  /// 36 tall, 80 wide         44 tall, 88 wide
  /// ```
  final double collapsedBarHeight;

  /// Minimum width of the destination area in [collapsedBar].
  ///
  /// Defaults to [kCupertinoSidebarCollapsedBarMeasuredWidth]. The collapsed
  /// bar does not shrink below the sidebar button plus this extent. A narrower
  /// slot paints Flutter's overflow warning.
  ///
  /// ```text
  /// | [=] <-- destination extent -->|
  /// narrower: | [=] Home ||||
  /// ```
  final double collapsedBarMinimumDestinationExtent;

  /// Draws a hairline between the sidebar button and [collapsedBar].
  ///
  /// Off by default, so the button sits directly beside the destinations.
  ///
  /// ```text
  /// off                          on
  /// | [=] Home  Search |         | [=] | Home  Search |
  /// ```
  final bool collapsedBarSeparator;

  /// Animates [collapsedBar] while the sidebar hides or shows.
  ///
  /// [progress] passed to the builder is 0 while the bar is hidden and 1 while
  /// it is fully shown. [CupertinoSidebarCollapsedBarTransition.drop] is the
  /// default. Pass [CupertinoSidebarCollapsedBarTransition.fade] for a fade in
  /// place, or supply a custom builder. The builder wraps the bar only.
  ///
  /// ```text
  /// drop                         fade
  ///    [bar]                     [bar]
  ///      v                       (opacity)
  ///   title                      title
  /// ```
  final CupertinoSidebarCollapsedBarTransitionBuilder
  collapsedBarTransitionBuilder;

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

  /// Shared background for the backdrop and the content beside the sidebar.
  ///
  /// When null, both use [CupertinoThemeData.scaffoldBackgroundColor]. The
  /// page keeps that opaque color. The panel uses [kCupertinoSidebarGlassAlpha]
  /// and the collapsed bar uses [kCupertinoSidebarCollapsedBarGlassAlpha], both
  /// taken from the theme bar color.
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
  final LayerLink _collapsedBarLink = LayerLink();
  Size? _collapsedBarSize;
  double? _collapsedBarSlotWidth;

  void _reportCollapsedBarSize(Size size) {
    if (!mounted || _collapsedBarSize == size) return;
    setState(() => _collapsedBarSize = size);
  }

  void _reportCollapsedBarSlotWidth(double width) {
    if (!mounted || _collapsedBarSlotWidth == width) return;
    setState(() => _collapsedBarSlotWidth = width);
  }

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
    // Resolved above the content theme, which replaces the bar color with the
    // opaque scaffold fill. The panel and the collapsed bar share that bar
    // color and use different opacities.
    final barBackground = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).barBackgroundColor,
      context,
    );
    final panelGlass = barBackground.withValues(
      alpha: kCupertinoSidebarGlassAlpha,
    );
    final collapsedBarGlass = barBackground.withValues(
      alpha: kCupertinoSidebarCollapsedBarGlassAlpha,
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
        final collapsedBarEnabled = widget.collapsedBar != null;
        // The toggle stays on the panel until the sidebar is fully hidden,
        // then it is the only mounted toggle and lives in the capsule.
        final toggleInCapsule = collapsedBarEnabled && expandedProgress == 0;
        final capsule = collapsedBarEnabled
            ? CupertinoSidebarCollapsedCapsule(
                backgroundColor: collapsedBarGlass,
                minimumBodyExtent: widget.collapsedBarMinimumDestinationExtent,
                height: widget.collapsedBarHeight,
                showSeparator: widget.collapsedBarSeparator,
                leading: toggleInCapsule
                    ? CupertinoSidebarButton(
                        focusNode: _toggleFocusNode,
                        label: expandNavigationLabel,
                        onPressed: _controller.toggleExpanded,
                        buttonKey: const ValueKey('cupertino-sidebar-toggle'),
                        tooltipBuilder: widget.tooltipBuilder,
                        extent: widget.collapsedBarHeight,
                      )
                    : _CollapsedTogglePlaceholder(
                        extent: widget.collapsedBarHeight,
                      ),
                child: widget.collapsedBar!,
              )
            : null;
        final branch = _CupertinoSidebarBranch(
          occupiedSpan:
              (leadingSafeMargin + panelWidth + _contentGap) * expandedProgress,
          child: _CupertinoSidebarCollapsedScope(
            showBar: capsule != null,
            barLink: _collapsedBarLink,
            barSize: _collapsedBarSize,
            slotWidth: _collapsedBarSlotWidth,
            collapseProgress: appBarProgress,
            reportSlotWidth: _reportCollapsedBarSlotWidth,
            barHeight: widget.collapsedBarHeight,
            child: SidebarLeadingScope(
              toolbarAvoidance: toolbarAvoidance,
              progress: collapsedBarEnabled ? 0 : appBarProgress,
              child: MediaQuery(data: effectiveBranchMediaQuery, child: child!),
            ),
          ),
        );
        final collapsedBarVisible = capsule != null;
        final stack = Stack(
          key: const ValueKey('cupertino-sidebar-beside-host'),
          fit: StackFit.expand,
          children: [
            branch,
            if (collapsedBarVisible)
              Positioned(
                left: 0,
                top: 0,
                child: CompositedTransformFollower(
                  link: _collapsedBarLink,
                  showWhenUnlinked: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _collapsedBarSlotWidth ?? double.infinity,
                    ),
                    child: _ReportSize(
                      onSize: _reportCollapsedBarSize,
                      child: IgnorePointer(
                        ignoring: appBarProgress < 1,
                        child: ExcludeSemantics(
                          excluding: appBarProgress < 1,
                          child: widget.collapsedBarTransitionBuilder(
                            context,
                            appBarProgress,
                            capsule,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (panelActive)
              _CupertinoSidebarAnimatedPanel(
                progress: expandedProgress,
                child: CupertinoSidebarPanel(
                  width: panelWidth,
                  backgroundColor: panelGlass,
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
            if (!toggleInCapsule)
              PositionedDirectional(
                key: const ValueKey('cupertino-sidebar-toggle-position'),
                start: collapsedBarEnabled ? visibleButtonStart : buttonStart,
                top: buttonTop,
                width: SidebarLeadingScope.buttonExtent,
                height: SidebarLeadingScope.buttonExtent,
                child: Opacity(
                  opacity: collapsedBarEnabled ? expandedProgress : 1,
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
          key: const ValueKey('cupertino-sidebar-panel-transition'),
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

/// Positions a collapsed Cupertino bar while the sidebar hides or shows.
///
/// [progress] is 0 when the bar is hidden and 1 when it is fully shown.
typedef CupertinoSidebarCollapsedBarTransitionBuilder =
    Widget Function(BuildContext context, double progress, Widget child);

/// Built-in transitions for [CupertinoSidebar.collapsedBar].
///
/// ```text
/// drop                         fade
///    [bar]                     [bar]
///      v                       (opacity)
///   title                      title
/// ```
abstract final class CupertinoSidebarCollapsedBarTransition {
  /// Slides the bar down from above while fading it in.
  static Widget drop(BuildContext context, double progress, Widget child) {
    return FractionalTranslation(
      key: const ValueKey('cupertino-sidebar-collapsed-transition'),
      translation: Offset(0, progress - 1),
      child: Opacity(opacity: progress.clamp(0, 1), child: child),
    );
  }

  /// Fades the bar in place.
  static Widget fade(BuildContext context, double progress, Widget child) {
    return Opacity(
      key: const ValueKey('cupertino-sidebar-collapsed-transition'),
      opacity: progress.clamp(0, 1),
      child: child,
    );
  }
}

class _CupertinoSidebarCollapsedScope extends InheritedWidget {
  const _CupertinoSidebarCollapsedScope({
    required this.showBar,
    required this.barLink,
    required this.barSize,
    required this.slotWidth,
    required this.collapseProgress,
    required this.reportSlotWidth,
    required this.barHeight,
    required super.child,
  });

  final bool showBar;
  final LayerLink barLink;
  final Size? barSize;
  final double? slotWidth;
  final double collapseProgress;
  final ValueChanged<double> reportSlotWidth;
  final double barHeight;

  static _CupertinoSidebarCollapsedScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoSidebarCollapsedScope>();
  }

  @override
  bool updateShouldNotify(_CupertinoSidebarCollapsedScope oldWidget) {
    return oldWidget.collapseProgress != collapseProgress ||
        oldWidget.showBar != showBar ||
        oldWidget.barSize != barSize ||
        oldWidget.slotWidth != slotWidth ||
        oldWidget.barLink != barLink ||
        oldWidget.barHeight != barHeight;
  }
}

/// Slot that swaps the page title for the collapsed horizontal bar.
///
/// Shows [title] while the sidebar is open. When
/// [CupertinoSidebar.collapsedBar] is set, the hidden sidebar replaces [title]
/// with that horizontal bar.
/// The bar uses [CupertinoSidebar.collapsedBarTransitionBuilder].
///
/// ```text
/// open, or no bar          hidden, bar set
///        Title             ( [=] Home  Search )
/// ```
class CupertinoSidebarMiddle extends StatelessWidget {
  /// Creates a middle slot that can swap [title] for the collapsed bar.
  const CupertinoSidebarMiddle({super.key, required this.title});

  /// Page title shown while the sidebar is visible or no collapsed bar is set.
  final Widget title;

  @override
  Widget build(BuildContext context) {
    final scope = _CupertinoSidebarCollapsedScope.maybeOf(context);
    if (scope == null || !scope.showBar) return title;
    final collapse = scope.collapseProgress.clamp(0.0, 1.0);
    return _ReportSlotWidth(
      onWidth: scope.reportSlotWidth,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          IgnorePointer(
            ignoring: collapse > 0,
            child: ExcludeSemantics(
              excluding: collapse > 0,
              child: Opacity(opacity: 1 - collapse, child: title),
            ),
          ),
          CompositedTransformTarget(
            link: scope.barLink,
            child: SizedBox.fromSize(
              size: scope.barSize ?? Size(0, scope.barHeight),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedTogglePlaceholder extends StatelessWidget {
  const _CollapsedTogglePlaceholder({required this.extent});

  final double extent;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return SizedBox(
      width: extent,
      height: extent,
      child: Icon(
        direction == TextDirection.ltr
            ? CupertinoIcons.sidebar_left
            : CupertinoIcons.sidebar_right,
        color: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }
}

class _ReportSlotWidth extends SingleChildRenderObjectWidget {
  const _ReportSlotWidth({required this.onWidth, required super.child});

  final ValueChanged<double> onWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderReportSlotWidth(onWidth);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderReportSlotWidth renderObject,
  ) {
    renderObject.onWidth = onWidth;
  }
}

class _RenderReportSlotWidth extends RenderProxyBox {
  _RenderReportSlotWidth(this.onWidth);

  ValueChanged<double> onWidth;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final double next = constraints.maxWidth;
    if (!next.isFinite || _reported == next) return;
    _reported = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached && _reported == next) onWidth(next);
    });
  }
}

class _ReportSize extends SingleChildRenderObjectWidget {
  const _ReportSize({required this.onSize, required super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderReportSize(onSize);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderReportSize renderObject,
  ) {
    renderObject.onSize = onSize;
  }
}

class _RenderReportSize extends RenderProxyBox {
  _RenderReportSize(this.onSize);

  ValueChanged<Size> onSize;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final Size next = child?.size ?? size;
    if (_reported == next) return;
    _reported = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached && _reported == next) onSize(next);
    });
  }
}
