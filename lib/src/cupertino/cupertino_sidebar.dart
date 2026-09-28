import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter/rendering.dart';

import '../adaptive_navigation_controller.dart';
import '../navigation_obstruction.dart';
import '../side_navigation_extent.dart';
import '../sidebar_constants.dart';
import '../sidebar_focus.dart';
import '../sidebar_leading_scope.dart';
import 'cupertino_sidebar_button.dart';
import 'cupertino_sidebar_chrome.dart';
import 'cupertino_sidebar_collapsed_bar.dart';
import 'cupertino_sidebar_interaction_scope.dart';
import 'cupertino_sidebar_panel.dart';
import 'cupertino_sidebar_toolbar_geometry.dart';

/// Opacity of the collapsed bar's glass fill.
///
/// The bar is painted over the page bar. Two layers at this opacity composite
/// to about [kCupertinoSidebarLiquidFillAlpha].
const double kCupertinoSidebarCollapsedBarGlassAlpha = 0.45;

/// Sidebar glyph drawn inside the collapsed capsule.
///
/// Sized to remain balanced with the capsule and destination labels.
const double _kCollapsedBarGlyphSize = 20;

/// Placement of a collapsed Cupertino sidebar bar.
enum CupertinoSidebarCollapsedBarPlacement {
  /// Follows a [CupertinoSidebarMiddle] in the current page toolbar.
  toolbarAnchor,

  /// Stays centered over the shell's top toolbar row.
  ///
  /// [CupertinoSidebarMiddle] reserves the same space in each page toolbar but
  /// does not create a composited transform target.
  fixedToolbar,
}

/// Controls whether a Cupertino sidebar's collapsed bar is visible.
///
/// A controller can be attached to only one [CupertinoSidebar].
class CupertinoSidebarCollapsedBarController extends ChangeNotifier {
  /// Creates a collapsed-bar visibility controller.
  CupertinoSidebarCollapsedBarController({bool visible = true})
    : _visible = visible,
      _progress = visible ? 1 : 0;

  bool _visible;
  double _progress;

  /// Whether the collapsed bar should be shown.
  bool get visible => _visible;

  set visible(bool value) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }

  /// Animation progress from 0 (hidden) to 1 (shown).
  double get progress => _progress;

  /// Shows the collapsed bar using the sidebar's configured transition.
  void show() => visible = true;

  /// Hides the collapsed bar using the sidebar's configured transition.
  void hide() => visible = false;

  void _setProgress(double value) {
    if (_progress == value) return;
    _progress = value;
    notifyListeners();
  }
}

/// Hideable Cupertino sidebar placed beside [child].
///
/// The sidebar can be completely hidden, but it never collapses to an
/// icon-only rail. Visibility is [AdaptiveNavigationController.expanded].
/// [content] fills the panel. Use `CupertinoSidebarNavigation` for the
/// default destination list.
///
/// [collapsedBar] shows a horizontal bar in the page navigation bar while the
/// panel is hidden. [collapsedBarPlacement] either follows a
/// [CupertinoSidebarMiddle] or keeps the bar fixed over the shell toolbar.
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
  /// Creates an inset liquid sidebar around [child].
  ///
  /// Selected rows use a translucent primary tint. Pass [style] only to
  /// override that preset. [CupertinoSidebar.edge] is the flush column with
  /// iPadOS 27 selection and active-state colors.
  const CupertinoSidebar({
    super.key,
    required this.controller,
    required this.content,
    required this.child,
    this.collapsedBar,
    this.collapsedBarController,
    this.collapsedBarPlacement =
        CupertinoSidebarCollapsedBarPlacement.toolbarAnchor,
    this.toolbarGeometry = CupertinoSidebarToolbarGeometry.standard,
    double? collapsedBarHeight,
    this.collapsedBarMinimumDestinationExtent =
        kCupertinoSidebarCollapsedBarMeasuredWidth,
    this.collapsedBarSeparator = false,
    this.collapsedBarTransitionBuilder =
        CupertinoSidebarCollapsedBarTransition.drop,
    this.extent = const SideNavigationExtent(200),
    this.style = CupertinoSidebarStyle.liquid,
    this.dragHandleBuilder,
    this.expandLabel,
    this.collapseLabel,
    this.tooltipBuilder,
    this.backgroundColor,
    this.scaffoldBackgroundColor,
  }) : // Keep the public override name while storing its nullable const value.
       // ignore: prefer_initializing_formals
       _collapsedBarHeight = collapsedBarHeight;

  /// Creates a sidebar flush with the window edge.
  ///
  /// The glass is [CupertinoSidebarStyle.liquidEdge]. Selected rows inside
  /// [content] use iPadOS 27 unfocused, focused, and pressed colors.
  const CupertinoSidebar.edge({
    Key? key,
    required AdaptiveNavigationController controller,
    required Widget content,
    required Widget child,
    Widget? collapsedBar,
    CupertinoSidebarCollapsedBarController? collapsedBarController,
    CupertinoSidebarCollapsedBarPlacement collapsedBarPlacement =
        CupertinoSidebarCollapsedBarPlacement.toolbarAnchor,
    CupertinoSidebarToolbarGeometry toolbarGeometry =
        CupertinoSidebarToolbarGeometry.standard,
    double? collapsedBarHeight,
    double collapsedBarMinimumDestinationExtent =
        kCupertinoSidebarCollapsedBarMeasuredWidth,
    bool collapsedBarSeparator = false,
    CupertinoSidebarCollapsedBarTransitionBuilder
        collapsedBarTransitionBuilder =
        CupertinoSidebarCollapsedBarTransition.drop,
    SideNavigationExtent extent = const SideNavigationExtent(200),
    SideNavigationDragHandleBuilder? dragHandleBuilder,
    String? expandLabel,
    String? collapseLabel,
    NavigationTooltipBuilder? tooltipBuilder,
    Color? backgroundColor,
    Color? scaffoldBackgroundColor,
  }) : this(
         key: key,
         controller: controller,
         content: content,
         child: child,
         collapsedBar: collapsedBar,
         collapsedBarController: collapsedBarController,
         collapsedBarPlacement: collapsedBarPlacement,
         toolbarGeometry: toolbarGeometry,
         collapsedBarHeight: collapsedBarHeight,
         collapsedBarMinimumDestinationExtent:
             collapsedBarMinimumDestinationExtent,
         collapsedBarSeparator: collapsedBarSeparator,
         collapsedBarTransitionBuilder: collapsedBarTransitionBuilder,
         extent: extent,
         style: CupertinoSidebarStyle.liquidEdge,
         dragHandleBuilder: dragHandleBuilder,
         expandLabel: expandLabel,
         collapseLabel: collapseLabel,
         tooltipBuilder: tooltipBuilder,
         backgroundColor: backgroundColor,
         scaffoldBackgroundColor: scaffoldBackgroundColor,
       );

  /// Whether selected rows in [context] use the edge interaction treatment.
  ///
  /// True inside [CupertinoSidebar.edge], or a sidebar whose [style] is
  /// [CupertinoSidebarStyle.liquidEdge]. False otherwise.
  static bool filledSelectionOf(BuildContext context) {
    return styleOf(context) == CupertinoSidebarStyle.liquidEdge;
  }

  /// The sidebar presentation inherited by descendants in [context].
  static CupertinoSidebarStyle styleOf(BuildContext context) {
    return CupertinoSidebarStyleScope.styleOf(context);
  }

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
  /// [CupertinoSidebarMiddle] swaps the page title for either the bar anchor or
  /// a matching placeholder, according to [collapsedBarPlacement].
  ///
  /// The bar keeps the sidebar button plus
  /// [collapsedBarMinimumDestinationExtent]. Anything narrower overflows.
  final Widget? collapsedBar;

  /// Controls whether [collapsedBar] is visible independently of the panel.
  final CupertinoSidebarCollapsedBarController? collapsedBarController;

  /// Places [collapsedBar] in a page toolbar or in the fixed shell toolbar.
  final CupertinoSidebarCollapsedBarPlacement collapsedBarPlacement;

  /// Shared vertical geometry for the collapsed bar and page toolbar.
  ///
  /// Use [CupertinoSidebarToolbarGeometry.standard] for the measured iPad
  /// layout and [CupertinoSidebarToolbarGeometry.compact] for desktop.
  final CupertinoSidebarToolbarGeometry toolbarGeometry;

  /// Height of [collapsedBar], and of the toggle inside it.
  ///
  /// Defaults to [toolbarGeometry]'s collapsed-bar height. Pass the same value
  /// to [CupertinoSidebarCollapsedBar.height] when constructing the bar
  /// manually.
  double get collapsedBarHeight =>
      _collapsedBarHeight ?? toolbarGeometry.collapsedBarHeight;

  final double? _collapsedBarHeight;

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

  /// Glass treatment of the expanded panel, and the selection fill.
  ///
  /// Defaults to [CupertinoSidebarStyle.liquid], the inset rounded surface
  /// with a translucent selection. [CupertinoSidebarStyle.liquidEdge], also
  /// selected by [CupertinoSidebar.edge], draws a column that meets the
  /// window edge and uses iPadOS 27 selection colors. The package does not
  /// choose this from the platform.
  final CupertinoSidebarStyle style;

  /// Optional visual displayed inside the resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Action label used while the sidebar is hidden.
  final String? expandLabel;

  /// Action label used while the sidebar is visible.
  final String? collapseLabel;

  /// Optional tooltip wrapper for the show and hide button.
  final NavigationTooltipBuilder? tooltipBuilder;

  /// Background color of the expanded sidebar surface.
  ///
  /// A [CupertinoDynamicColor] is resolved against the current context. When
  /// null, the selected [style] supplies its default fill. Transparent colors
  /// retain the style's backdrop blur; opaque colors skip it.
  final Color? backgroundColor;

  /// Shared scaffold color for the backdrop and the content beside the sidebar.
  ///
  /// When null, both use [CupertinoThemeData.scaffoldBackgroundColor]. The
  /// page keeps that opaque color. The panel fill, blur, shadow, and border
  /// come from [style]. The collapsed bar caps the theme bar color opacity at
  /// [kCupertinoSidebarCollapsedBarGlassAlpha].
  final Color? scaffoldBackgroundColor;

  @override
  State<CupertinoSidebar> createState() => _CupertinoSidebarState();
}

class _CupertinoSidebarState extends State<CupertinoSidebar>
    with TickerProviderStateMixin {
  static const double _edgeGestureWidth = 20;
  static const double _appBarLeadingPadding = 16;
  static const double _panelToggleTrailingPadding = 8;

  late final AnimationController _animation = AnimationController(
    vsync: this,
    value: widget.controller.expanded ? 1 : 0,
  );
  late final AnimationController _collapsedBarVisibility = AnimationController(
    vsync: this,
    value: widget.collapsedBarController?.visible == false ? 0 : 1,
  )..addListener(_reportCollapsedBarVisibility);
  late final Animation<double> _curvedCollapsedBarVisibility = CurvedAnimation(
    parent: _collapsedBarVisibility,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeOut,
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
  final Object _focusGroup = Object();
  double _edgeDragDistance = 0;
  int _outsideTapGeneration = 0;

  AdaptiveNavigationController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _animation.addListener(_reportCollapsedBarVisibility);
    widget.collapsedBarController?.addListener(
      _onCollapsedBarControllerChanged,
    );
    _reportCollapsedBarVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : kSidebarAnimationDuration;
    _collapsedBarVisibility.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : kSidebarAnimationDuration;
  }

  @override
  void didUpdateWidget(covariant CupertinoSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncExpandedAnimation();
    }
    if (oldWidget.collapsedBarController != widget.collapsedBarController) {
      oldWidget.collapsedBarController?.removeListener(
        _onCollapsedBarControllerChanged,
      );
      widget.collapsedBarController?.addListener(
        _onCollapsedBarControllerChanged,
      );
      _syncCollapsedBarVisibility();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    widget.collapsedBarController?.removeListener(
      _onCollapsedBarControllerChanged,
    );
    _toggleFocusNode.dispose();
    _animation.removeListener(_reportCollapsedBarVisibility);
    _collapsedBarVisibility
      ..removeListener(_reportCollapsedBarVisibility)
      ..dispose();
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

  void _onCollapsedBarControllerChanged() {
    _syncCollapsedBarVisibility();
  }

  void _syncCollapsedBarVisibility() {
    final visible = widget.collapsedBarController?.visible ?? true;
    if (visible) {
      if (_collapsedBarVisibility.value == 1) return;
      _collapsedBarVisibility.forward();
    } else {
      if (_collapsedBarVisibility.value == 0) return;
      _collapsedBarVisibility.reverse();
    }
  }

  void _reportCollapsedBarVisibility() {
    widget.collapsedBarController?._setProgress(
      (1 - _curvedAnimation.value) * _curvedCollapsedBarVisibility.value,
    );
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

  void _handleTapOutside() {
    if (widget.style != CupertinoSidebarStyle.liquidEdge) return;
    setState(() => _outsideTapGeneration += 1);
  }

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
    final chrome = CupertinoSidebarChrome.of(widget.style);
    final leadingMediaPadding = direction == TextDirection.ltr
        ? mediaPadding.left
        : mediaPadding.right;
    // A flush column starts at the window edge. The floating surface keeps
    // its inset, which is at least the measured margin and the safe area.
    final panelOrigin = chrome.flushToWindowEdge
        ? 0.0
        : math.max(chrome.surfaceMargin, leadingMediaPadding);
    // The traffic-light row is the ordinary toolbar, not the extra vertical
    // corner avoidance. Horizontal avoidance still shifts the button aside.
    final buttonTop = math.max(
      math.max(chrome.surfaceMargin, widget.toolbarGeometry.topInset),
      mediaPadding.top,
    );
    final sideNavigationStart = direction == TextDirection.ltr
        ? obstruction.sidebar.left
        : obstruction.sidebar.right;
    final sideNavigationEnd = direction == TextDirection.ltr
        ? obstruction.sidebar.right
        : obstruction.sidebar.left;
    final visibleButtonStart =
        panelOrigin +
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
      widget.scaffoldBackgroundColor ??
          CupertinoTheme.of(context).scaffoldBackgroundColor,
      context,
    );
    // Resolved above the content theme, which replaces the bar color with the
    // opaque scaffold fill. The collapsed bar uses that bar color. The panel
    // fill comes from [chrome].
    final barBackground = CupertinoDynamicColor.resolve(
      CupertinoTheme.of(context).barBackgroundColor,
      context,
    );
    final collapsedBarGlass = barBackground.withValues(
      alpha: math.min(barBackground.a, kCupertinoSidebarCollapsedBarGlassAlpha),
    );
    final content = CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        scaffoldBackgroundColor: sharedBackground,
        barBackgroundColor: sharedBackground,
      ),
      child: widget.child,
    );
    return AnimatedBuilder(
      animation: Listenable.merge([
        _curvedAnimation,
        _curvedCollapsedBarVisibility,
      ]),
      child: content,
      builder: (context, child) {
        final expandedProgress = _curvedAnimation.value;
        final panelActive = _animation.value > 0;
        final appBarProgress = 1 - expandedProgress;
        final collapsedBarProgress =
            appBarProgress * _curvedCollapsedBarVisibility.value;
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
        final collapsedBar = widget.collapsedBar;
        final collapsedBarEnabled = collapsedBar != null;
        // The toggle stays on the panel until the sidebar is fully hidden,
        // then it is the only mounted toggle and lives in the capsule.
        final toggleInCapsule = collapsedBarEnabled && expandedProgress == 0;
        final capsule = collapsedBar == null
            ? null
            : CupertinoSidebarStyleScope(
                style: widget.style,
                child: CupertinoSidebarCollapsedCapsule(
                  style: widget.style,
                  backgroundColor:
                      widget.style == CupertinoSidebarStyle.liquidEdge
                      ? widget.backgroundColor
                      : collapsedBarGlass,
                  minimumBodyExtent:
                      widget.collapsedBarMinimumDestinationExtent,
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
                          iconSize: _kCollapsedBarGlyphSize,
                        )
                      : _CollapsedTogglePlaceholder(
                          extent: widget.collapsedBarHeight,
                        ),
                  child: collapsedBar,
                ),
              );
        final branch = _CupertinoSidebarBranch(
          occupiedSpan:
              (panelOrigin + panelWidth + chrome.contentGap) * expandedProgress,
          child: _CupertinoSidebarCollapsedScope(
            showBar: capsule != null,
            barLink: _collapsedBarLink,
            placement: widget.collapsedBarPlacement,
            barSize: _collapsedBarSize,
            slotWidth: _collapsedBarSlotWidth,
            collapseProgress: collapsedBarProgress,
            reportSlotWidth: _reportCollapsedBarSlotWidth,
            barHeight: widget.collapsedBarHeight,
            child: SidebarLeadingScope(
              toolbarAvoidance: toolbarAvoidance,
              progress: collapsedBarEnabled ? 0 : appBarProgress,
              child: MediaQuery(
                data: effectiveBranchMediaQuery,
                child: child ?? content,
              ),
            ),
          ),
        );
        final collapsedBarOverlay = capsule == null
            ? null
            : switch (widget.collapsedBarPlacement) {
                CupertinoSidebarCollapsedBarPlacement.toolbarAnchor =>
                  Positioned(
                    left: 0,
                    top: 0,
                    child: CompositedTransformFollower(
                      link: _collapsedBarLink,
                      showWhenUnlinked: false,
                      child: _buildCollapsedBarHost(
                        capsule,
                        collapsedBarProgress,
                        maxWidth: _collapsedBarSlotWidth ?? double.infinity,
                      ),
                    ),
                  ),
                CupertinoSidebarCollapsedBarPlacement.fixedToolbar =>
                  Positioned(
                    key: const ValueKey('cupertino-sidebar-fixed-toolbar-host'),
                    left: 0,
                    right: 0,
                    top: buttonTop,
                    height: widget.toolbarGeometry.contentHeight,
                    child: Center(
                      child: _buildCollapsedBarHost(
                        capsule,
                        collapsedBarProgress,
                      ),
                    ),
                  ),
              };
        final stack = Stack(
          key: const ValueKey('cupertino-sidebar-beside-host'),
          fit: StackFit.expand,
          children: [
            branch,
            ?collapsedBarOverlay,
            if (panelActive)
              SidebarFocusRegion(
                groupId: _focusGroup,
                onTapOutside: _handleTapOutside,
                child: _CupertinoSidebarAnimatedPanel(
                  progress: expandedProgress,
                  chrome: chrome,
                  child: CupertinoSidebarPanel(
                    chrome: chrome,
                    width: panelWidth,
                    backgroundColor: widget.backgroundColor,
                    contentActive: expandedProgress == 1,
                    content: CupertinoSidebarInteractionScope(
                      outsideTapGeneration: _outsideTapGeneration,
                      child: CupertinoSidebarStyleScope(
                        style: widget.style,
                        child: widget.content,
                      ),
                    ),
                    dragging: _controller.resizing,
                    dragHandleBuilder: widget.dragHandleBuilder,
                    onResizeStart: () => _handleResizeStart(windowWidth),
                    onResizeUpdate: (delta) =>
                        _handleResizeUpdate(delta, windowWidth),
                    onResizeEnd: _controller.endResize,
                  ),
                ),
              ),
            if (!toggleInCapsule)
              PositionedDirectional(
                key: const ValueKey('cupertino-sidebar-toggle-position'),
                start: collapsedBarEnabled ? visibleButtonStart : buttonStart,
                top: buttonTop,
                width: SidebarLeadingScope.buttonExtent,
                height: SidebarLeadingScope.buttonExtent,
                child: SidebarFocusRegion(
                  groupId: _focusGroup,
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

  Widget _buildCollapsedBarHost(
    Widget capsule,
    double progress, {
    double maxWidth = double.infinity,
  }) {
    return SidebarFocusRegion(
      groupId: _focusGroup,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: _ReportSize(
          onSize: _reportCollapsedBarSize,
          child: IgnorePointer(
            ignoring: progress < 1,
            child: ExcludeSemantics(
              excluding: progress < 1,
              child: widget.collapsedBarTransitionBuilder(
                context,
                progress,
                capsule,
              ),
            ),
          ),
        ),
      ),
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
    required this.chrome,
    required this.child,
  });

  final double progress;
  final CupertinoSidebarChrome chrome;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final sliding = Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionalTranslation(
        key: const ValueKey('cupertino-sidebar-panel-transition'),
        translation: Offset(
          (direction == TextDirection.ltr ? -1 : 1) * (1 - progress),
          0,
        ),
        child: Opacity(opacity: progress, child: child),
      ),
    );
    if (chrome.flushToWindowEdge) return sliding;
    return SafeArea(
      minimum: EdgeInsets.all(chrome.surfaceMargin),
      child: sliding,
    );
  }
}

/// Positions a collapsed Cupertino bar while the sidebar hides or shows.
///
/// [progress] is 0 when the bar is hidden and 1 when it is fully shown.
typedef CupertinoSidebarCollapsedBarTransitionBuilder =
    Widget Function(BuildContext context, double progress, Widget child);

/// Built-in transitions for [CupertinoSidebar.collapsedBarTransitionBuilder].
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
    required this.placement,
    required this.barSize,
    required this.slotWidth,
    required this.collapseProgress,
    required this.reportSlotWidth,
    required this.barHeight,
    required super.child,
  });

  final bool showBar;
  final LayerLink barLink;
  final CupertinoSidebarCollapsedBarPlacement placement;
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
        oldWidget.placement != placement ||
        oldWidget.barHeight != barHeight;
  }
}

/// Slot that swaps the page title for collapsed horizontal bar space.
///
/// Shows [title] while the sidebar is open. When
/// [CupertinoSidebar.collapsedBar] is set, the hidden sidebar replaces [title]
/// with that horizontal bar. For
/// [CupertinoSidebarCollapsedBarPlacement.fixedToolbar], this widget reserves
/// the measured bar size while the shell paints the bar itself.
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
    final middle = Stack(
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
        if (scope.placement ==
            CupertinoSidebarCollapsedBarPlacement.toolbarAnchor)
          CompositedTransformTarget(
            link: scope.barLink,
            child: SizedBox.fromSize(
              size: scope.barSize ?? Size(0, scope.barHeight),
            ),
          )
        else
          SizedBox.fromSize(
            key: const ValueKey('cupertino-sidebar-fixed-toolbar-placeholder'),
            size: scope.barSize ?? Size(0, scope.barHeight),
          ),
      ],
    );
    if (scope.placement == CupertinoSidebarCollapsedBarPlacement.fixedToolbar) {
      return middle;
    }
    return _ReportSlotWidth(onWidth: scope.reportSlotWidth, child: middle);
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
        size: _kCollapsedBarGlyphSize,
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
