import 'package:flutter/material.dart';

import '../adaptive_navigation_controller.dart';
import '../navigation_obstruction.dart';
import '../side_navigation_extent.dart';
import '../sidebar_constants.dart';
import '../sidebar_focus.dart';
import 'material_sidebar_metrics.dart';

/// Collapsible, resizable Material sidebar.
///
/// Expansion and width come from [controller]. [content] fills the rail
/// below the expand control. Use `MaterialSidebarNavigation` for the default
/// destination list.
///
/// ```text
/// collapsed              expanded
/// +----+                 +----------+
/// | [=]|                 | [=]      |
/// | o  |                 | o  Label |
/// | o  |                 | o  Label |
/// +----+                 +----------+
/// ```
class MaterialSidebar extends StatefulWidget {
  /// Creates a Material sidebar around [content].
  const MaterialSidebar({
    super.key,
    required this.controller,
    required this.content,
    this.extent = const SideNavigationExtent(200),
    this.collapsedExtent = 96.0,
    this.dragHandleBuilder,
    this.expandLabel,
    this.collapseLabel,
    this.tooltipBuilder,
  }) : assert(collapsedExtent > 0);

  /// Shared selection, expansion, and width.
  final AdaptiveNavigationController controller;

  /// Interior of the rail, below the expand control.
  final Widget content;

  /// Automatic and manually resizable rail-width policy.
  ///
  /// [SideNavigationExtent.minimum] is the expanded panel's lower bound and
  /// must be wider than [collapsedExtent].
  final SideNavigationExtent extent;

  /// Width of the collapsed icon rail.
  final double collapsedExtent;

  /// Visual displayed in the rail's resize target.
  final SideNavigationDragHandleBuilder? dragHandleBuilder;

  /// Action label used while the rail is collapsed.
  final String? expandLabel;

  /// Action label used while the rail is expanded.
  final String? collapseLabel;

  /// Wraps the collapse control. Defaults to a Material tooltip.
  final NavigationTooltipBuilder? tooltipBuilder;

  @override
  State<MaterialSidebar> createState() => _MaterialSidebarState();
}

class _MaterialSidebarState extends State<MaterialSidebar> {
  static const double _collapsedDragOpenThreshold = 16.0;

  double _dragWidth = 0;
  double _dragOpenWidth = 0;
  final Object _focusGroup = Object();

  AdaptiveNavigationController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant MaterialSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.extent.minimum > widget.collapsedExtent);
    final windowWidth = MediaQuery.sizeOf(context).width;
    final resolvedExpandedWidth = _controller.effectiveWidth(
      widget.extent,
      windowWidth: windowWidth,
    );
    final expandedWidth = resolvedExpandedWidth < widget.collapsedExtent
        ? widget.collapsedExtent
        : resolvedExpandedWidth;
    final expanded = _controller.expanded;
    return SidebarFocusRegion(
      groupId: _focusGroup,
      child: AnimatedSize(
        duration: _controller.resizing
            ? const Duration(milliseconds: 1)
            : kSidebarAnimationDuration,
        curve: Curves.easeOut,
        alignment: AlignmentDirectional.centerStart,
        clipBehavior: Clip.hardEdge,
        child: _MaterialSidebarPanel(
          content: widget.content,
          extended: expanded,
          collapsedWidth: widget.collapsedExtent,
          expandedWidth: expandedWidth,
          padding: NavigationObstructionScope.of(context).sidebar,
          dragHandleBuilder: widget.dragHandleBuilder,
          tooltipBuilder: widget.tooltipBuilder,
          expandNavigationLabel: _expandLabel(context),
          collapseNavigationLabel: _collapseLabel(context),
          onToggle: _controller.toggleExpanded,
          onResizeStart: () => _handleResizeStart(windowWidth),
          onResizeUpdate: (delta) => _handleResizeUpdate(delta, windowWidth),
          onResizeEnd: _controller.endResize,
        ),
      ),
    );
  }

  String _expandLabel(BuildContext context) {
    final override = widget.expandLabel;
    if (override != null) return override;
    return MaterialLocalizations.of(context).collapsedIconTapHint;
  }

  String _collapseLabel(BuildContext context) {
    final override = widget.collapseLabel;
    if (override != null) return override;
    return MaterialLocalizations.of(context).expandedIconTapHint;
  }

  void _handleResizeStart(double windowWidth) {
    final effectiveWidth = _controller.effectiveWidth(
      widget.extent,
      windowWidth: windowWidth,
    );
    _dragWidth = _controller.expanded ? effectiveWidth : widget.collapsedExtent;
    _dragOpenWidth = _controller.expanded
        ? widget.extent.minimum
        : widget.collapsedExtent + _collapsedDragOpenThreshold;
    _controller.beginResize(widget.extent, windowWidth: windowWidth);
  }

  void _handleResizeUpdate(double delta, double windowWidth) {
    _dragWidth += delta;
    if (_dragWidth < widget.collapsedExtent) {
      _dragWidth = widget.collapsedExtent;
    }

    if (_controller.expanded) {
      _controller.updateResize(delta, widget.extent, windowWidth: windowWidth);
      if (_dragWidth >= widget.extent.minimum) return;
      _dragOpenWidth = widget.extent.minimum;
      _controller.expanded = false;
      return;
    }

    if (_dragWidth < _dragOpenWidth) return;
    final effectiveWidth = _controller.effectiveWidth(
      widget.extent,
      windowWidth: windowWidth,
    );
    _controller.updateResize(
      widget.extent.minimum - effectiveWidth,
      widget.extent,
      windowWidth: windowWidth,
    );
    _dragWidth = widget.extent.minimum;
    _controller.expanded = true;
  }
}

class _MaterialSidebarPanel extends StatelessWidget {
  const _MaterialSidebarPanel({
    required this.content,
    required this.extended,
    required this.collapsedWidth,
    required this.expandedWidth,
    required this.padding,
    required this.tooltipBuilder,
    required this.expandNavigationLabel,
    required this.collapseNavigationLabel,
    required this.onToggle,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    this.dragHandleBuilder,
  });

  static const double _minimumRailButtonExtent = 44.0;

  /// NavigationRail inserts an 8dp spacer above its leading slot. A 48dp
  /// icon button then centers 4dp below a standard toolbar, the row iPadOS
  /// uses for its window controls.
  static const double _toolbarCenterLift = 4.0;

  final Widget content;
  final bool extended;
  final double collapsedWidth;
  final double expandedWidth;
  final EdgeInsets padding;
  final NavigationTooltipBuilder? tooltipBuilder;
  final SideNavigationDragHandleBuilder? dragHandleBuilder;
  final String expandNavigationLabel;
  final String collapseNavigationLabel;
  final VoidCallback onToggle;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResizeUpdate;
  final VoidCallback onResizeEnd;

  Widget _wrapTooltip(BuildContext context, String message, Widget child) {
    final builder = tooltipBuilder;
    if (builder != null) return builder(context, message, child);
    return Tooltip(message: message, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final width = extended ? expandedWidth : collapsedWidth;
    final toggleAnchorWidth = width < collapsedWidth ? width : collapsedWidth;
    final safeWidth = toggleAnchorWidth - padding.left - padding.right;
    final useVerticalFallback = safeWidth < _minimumRailButtonExtent;
    final leadingHorizontalAvoidance = useVerticalFallback
        ? EdgeInsets.zero
        : EdgeInsets.only(left: padding.left, right: padding.right);
    final leadingTopAvoidance = useVerticalFallback ? padding.top : 0.0;
    final toggle = SizedBox(
      width: toggleAnchorWidth,
      child: Padding(
        key: const ValueKey('rail-leading-safe-span'),
        padding: EdgeInsets.only(
          left: leadingHorizontalAvoidance.left,
          top: leadingTopAvoidance,
          right: leadingHorizontalAvoidance.right,
        ),
        child: Align(
          heightFactor: 1,
          child: Transform.translate(
            offset: const Offset(0, -_toolbarCenterLift),
            child: _wrapTooltip(
              context,
              extended ? collapseNavigationLabel : expandNavigationLabel,
              IconButton(
                key: const ValueKey('rail-toggle-button'),
                icon: Icon(extended ? Icons.menu_open : Icons.menu),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ),
    );
    final primaryDestinationRail = _MaterialNavigationRail(
      key: const ValueKey('rail-panel'),
      extended: extended,
      minWidth: collapsedWidth,
      minExtendedWidth: expandedWidth,
      leading: toggle,
      content: content,
    );
    final navigationResizeHandle = PositionedDirectional(
      end: 0,
      top: 0,
      bottom: 0,
      child: _MaterialSidebarResizeHandle(
        extended: extended,
        dragHandleBuilder: dragHandleBuilder,
        onResizeStart: onResizeStart,
        onResizeUpdate: onResizeUpdate,
        onResizeEnd: onResizeEnd,
      ),
    );

    return MaterialSidebarMetrics(
      expanded: extended,
      collapsedWidth: collapsedWidth,
      expandedWidth: expandedWidth,
      child: Stack(children: [primaryDestinationRail, navigationResizeHandle]),
    );
  }
}

class _MaterialNavigationRail extends StatelessWidget {
  const _MaterialNavigationRail({
    super.key,
    required this.extended,
    required this.minWidth,
    required this.minExtendedWidth,
    required this.leading,
    required this.content,
  });

  final bool extended;
  final double minWidth;
  final double minExtendedWidth;
  final Widget leading;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: null,
      extended: extended,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      leadingAtTop: false,
      trailingAtBottom: true,
      scrollable: false,
      mainAxisAlignment: MainAxisAlignment.start,
      leading: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            Expanded(child: content),
          ],
        ),
      ),
      destinations: const [],
    );
  }
}

class _MaterialSidebarResizeHandle extends StatelessWidget {
  const _MaterialSidebarResizeHandle({
    required this.extended,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    this.dragHandleBuilder,
  });

  final bool extended;
  final SideNavigationDragHandleBuilder? dragHandleBuilder;
  final VoidCallback onResizeStart;
  final ValueChanged<double> onResizeUpdate;
  final VoidCallback onResizeEnd;

  @override
  Widget build(BuildContext context) {
    return SideNavigationResizeHandle(
      key: const ValueKey('rail-resize-gesture-handle'),
      hitExtent: 16,
      dragHandleBuilder: (context, states) => _MaterialSidebarDragHandle(
        extended: extended,
        states: states,
        builder: dragHandleBuilder,
      ),
      onResizeStart: onResizeStart,
      onResizeUpdate: onResizeUpdate,
      onResizeEnd: onResizeEnd,
    );
  }
}

class _MaterialSidebarDragHandle extends StatelessWidget {
  const _MaterialSidebarDragHandle({
    required this.extended,
    required this.states,
    this.builder,
  });

  final bool extended;
  final Set<WidgetState> states;
  final SideNavigationDragHandleBuilder? builder;

  @override
  Widget build(BuildContext context) {
    if (!extended) {
      return const SizedBox(
        key: ValueKey('rail-collapsed-resize-handle'),
        width: 16,
        height: 48,
      );
    }
    return KeyedSubtree(
      key: const ValueKey('rail-resize-handle'),
      child:
          builder?.call(context, states) ??
          SizedBox(
            key: const ValueKey('material-side-navigation-drag-bar'),
            width: 4,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
    );
  }
}
