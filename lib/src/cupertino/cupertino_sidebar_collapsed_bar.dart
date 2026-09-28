import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import '../adaptive_navigation_destination.dart';
import 'cupertino_floating_surface.dart';
import 'cupertino_sidebar_chrome.dart';
import 'cupertino_sidebar_item_style.dart';

/// Height of the measured collapsed capsule, in logical pixels.
///
/// Matches the measured iPad floating tab bar while preserving the standard
/// Cupertino hit area.
const double kCupertinoSidebarCollapsedBarMeasuredHeight = 44;

const double _kCollapsedBarSelectionHeight = 36;

const double _kCollapsedBarEdgeFillAlpha = 0.45;

// Tuned from iPadOS 27.0 Files screenshots at 2x scale. The light reference
// is a composited result, so keep it as a neutral overlay instead of an opaque
// pixel color. This preserves the selection layer over tinted glass hosts.
// The dark reference remains opaque because the native thumb is near-black.
const _cupertinoCollapsedEdgeSelectedColor =
    CupertinoDynamicColor.withBrightness(
      debugLabel: 'cupertinoCollapsedEdgeSelected',
      color: Color(0x12000000),
      darkColor: Color(0xFF070E13),
    );

const _cupertinoCollapsedEdgeSurfaceColor =
    CupertinoDynamicColor.withBrightness(
      debugLabel: 'cupertinoCollapsedEdgeSurface',
      color: Color(0xFFFBFCFD),
      darkColor: Color(0xFF3E3E3E),
    );

const _cupertinoCollapsedEdgeBorderColor = CupertinoDynamicColor.withBrightness(
  debugLabel: 'cupertinoCollapsedEdgeBorder',
  color: Color(0x26000000),
  darkColor: Color(0x38FFFFFF),
);

const _cupertinoCollapsedEdgeShadow = <BoxShadow>[
  BoxShadow(color: Color(0x18000000), blurRadius: 12, offset: Offset(0, 2)),
];

/// Minimum destination width of the measured collapsed capsule.
///
/// Scaled from the reference segment using
/// [kCupertinoSidebarCollapsedBarMeasuredHeight].
const double kCupertinoSidebarCollapsedBarMeasuredWidth = 80;

/// Label inside the collapsed capsule.
///
/// Uses the measured weight and tracking instead of the default
/// [CupertinoButton] action style.
const TextStyle _kCollapsedBarLabelStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  height: 1.2,
  letterSpacing: -0.23,
);

/// Horizontal destinations for a collapsed Cupertino sidebar.
///
/// Place this in [CupertinoSidebar.collapsedBar]. The sidebar pins its toggle
/// ahead of these destinations and shows the group in [CupertinoSidebarMiddle]
/// while the panel is hidden.
///
/// Press the selection and drag. The highlight follows the pointer. The
/// selection changes when the pointer is released, and the highlight snaps to
/// that destination. [itemStyle] replaces the highlight, the label colors,
/// and the label type.
///
/// ```text
/// selected                 none
/// | Home | Search |       | Home | Search |
/// [======]
/// ```
class CupertinoSidebarCollapsedBar extends StatelessWidget {
  /// Creates a horizontal destination bar.
  const CupertinoSidebarCollapsedBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.showIcons = false,
    this.height = kCupertinoSidebarCollapsedBarMeasuredHeight,
    this.minimumDestinationExtent = kCupertinoSidebarCollapsedBarMeasuredWidth,
    this.itemStyle,
  }) : assert(destinations.length > 0);

  /// Primary destinations shown in the bar.
  final List<AdaptiveNavigationDestination> destinations;

  /// Selected destination index.
  ///
  /// Null selects nothing. Use that when the page is not one of
  /// [destinations]; a later tap can select one again.
  final int? selectedIndex;

  /// Called with the index of a tapped destination.
  final ValueChanged<int> onDestinationSelected;

  /// Whether each destination draws its Cupertino icon beside the label.
  ///
  /// Defaults to false, so the bar shows labels only.
  final bool showIcons;

  /// Height of each destination. Match [CupertinoSidebar.collapsedBarHeight].
  final double height;

  /// Minimum width of each destination.
  ///
  /// Defaults to [kCupertinoSidebarCollapsedBarMeasuredWidth], matching the
  /// measured iPad tab segment while allowing longer labels to grow.
  final double minimumDestinationExtent;

  /// Highlight, label colors, and label type. Null keeps the measured capsule.
  final CupertinoSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    final style = CupertinoSidebarStyleScope.styleOf(context);
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final fallbackHighlight = switch (style) {
      CupertinoSidebarStyle.liquid => primaryColor.withValues(alpha: 0.14),
      CupertinoSidebarStyle.liquidEdge => CupertinoDynamicColor.resolve(
        _cupertinoCollapsedEdgeSelectedColor,
        context,
      ),
    };
    final highlight = CupertinoSidebarItemStyle.backgroundColorOf(
      itemStyle,
      context,
      states: const {WidgetState.selected},
      fallback: fallbackHighlight,
    )!;
    return _DraggableCollapsedSelection(
      selectedIndex: selectedIndex,
      height: height,
      highlight: highlight,
      onSelected: onDestinationSelected,
      children: [
        for (final (index, destination) in destinations.indexed)
          _CollapsedDestination(
            key: ValueKey('cupertino-sidebar-collapsed-destination-$index'),
            destination: destination,
            selected: selectedIndex == index,
            showIcon: showIcons,
            height: height,
            minimumExtent: minimumDestinationExtent,
            itemStyle: itemStyle,
            onPressed: () => onDestinationSelected(index),
          ),
      ],
    );
  }
}

class _CollapsedDestination extends StatelessWidget {
  const _CollapsedDestination({
    super.key,
    required this.destination,
    required this.selected,
    required this.showIcon,
    required this.height,
    required this.minimumExtent,
    required this.itemStyle,
    required this.onPressed,
  });

  final AdaptiveNavigationDestination destination;
  final bool selected;
  final bool showIcon;
  final double height;
  final double minimumExtent;
  final CupertinoSidebarItemStyle? itemStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final labelColor = CupertinoDynamicColor.resolve(
      CupertinoColors.label,
      context,
    );
    final states = <WidgetState>{if (selected) WidgetState.selected};
    final selectedForeground = primaryColor.withValues(alpha: 1);
    final foregroundColor = CupertinoSidebarItemStyle.labelColorOf(
      itemStyle,
      context: context,
      states: states,
      selectedFallback: selectedForeground,
      unselectedFallback: labelColor.withValues(alpha: 1),
    );
    final iconColor = CupertinoSidebarItemStyle.iconColorOf(
      itemStyle,
      context: context,
      states: states,
      selectedFallback: selectedForeground,
      unselectedFallback: labelColor.withValues(alpha: 1),
    );
    final icon = selected
        ? destination.icons.cupertinoSelected
        : destination.icons.cupertino;
    final innerHeight = math.min(_kCollapsedBarSelectionHeight, height);
    final label = Text(
      destination.label,
      maxLines: 1,
      style: CupertinoSidebarItemStyle.labelStyleOf(
        itemStyle,
        fallback: _kCollapsedBarLabelStyle,
        color: foregroundColor,
      ),
    );
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.effectiveSemanticsLabel,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minimumExtent),
        child: SizedBox(
          height: height,
          child: Align(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CupertinoButton(
                minimumSize: Size(0, innerHeight),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                borderRadius: BorderRadius.circular(innerHeight / 2),
                foregroundColor: foregroundColor,
                onPressed: onPressed,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showIcon) ...[
                      IconTheme.merge(
                        data: IconThemeData(color: iconColor),
                        child: icon,
                      ),
                      const SizedBox(width: 6),
                    ],
                    label,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThumbDragRecognizer extends HorizontalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'collapsed bar thumb drag';
}

class _DraggableCollapsedSelection extends StatefulWidget {
  const _DraggableCollapsedSelection({
    required this.selectedIndex,
    required this.height,
    required this.highlight,
    required this.onSelected,
    required this.children,
  });

  final int? selectedIndex;
  final double height;
  final Color highlight;
  final ValueChanged<int> onSelected;
  final List<Widget> children;

  @override
  State<_DraggableCollapsedSelection> createState() =>
      _DraggableCollapsedSelectionState();
}

class _DraggableCollapsedSelectionState
    extends State<_DraggableCollapsedSelection>
    with SingleTickerProviderStateMixin {
  final GlobalKey _rowKey = GlobalKey();
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final _ThumbDragRecognizer _drag;
  double? _dragX;
  double? _snapFrom;
  double? _snapTo;

  @override
  void initState() {
    super.initState();
    // Claim the pointer on press, the same way a segmented control's thumb
    // drag wins the arena without waiting for a long-press timeout.
    _drag = _ThumbDragRecognizer()
      ..onUpdate = _onMove
      ..onEnd = _onEnd
      ..onCancel = _onCancel;
    _snap.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _drag.dispose();
    _snap.dispose();
    super.dispose();
  }

  _RenderCollapsedSelection? get _row {
    return _rowKey.currentContext?.findRenderObject()
        as _RenderCollapsedSelection?;
  }

  double? get _visualDragX {
    if (_snapFrom != null && _snapTo != null && _snap.isAnimating) {
      final t = Curves.easeOut.transform(_snap.value);
      return _snapFrom! + (_snapTo! - _snapFrom!) * t;
    }
    return _dragX;
  }

  void _onPointerDown(PointerDownEvent event) {
    final row = _row;
    final box = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (row == null || box == null || !row.hasSize) return;
    if (widget.selectedIndex == null) return;
    final localX = box.globalToLocal(event.position).dx;
    // Dragging starts on the selected destination, as it does for the segmented
    // thumb. Other destinations keep their tap and can still scroll the bar.
    if (row.indexAt(localX) != widget.selectedIndex) return;
    _drag.addPointer(event);
  }

  void _onMove(DragUpdateDetails details) {
    final row = _row;
    final box = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (row == null || box == null) return;
    final localX = box.globalToLocal(details.globalPosition).dx;
    setState(() {
      _snap.stop();
      _snapFrom = null;
      _snapTo = null;
      _dragX = localX;
    });
  }

  void _onEnd(DragEndDetails details) {
    final row = _row;
    final dragX = _dragX;
    if (row == null || dragX == null) {
      setState(() => _dragX = null);
      return;
    }
    final index = row.indexAt(dragX);
    final target = row.childCenter(index);
    if (index != widget.selectedIndex) widget.onSelected(index);
    if (target == null) {
      setState(() => _dragX = null);
      return;
    }
    setState(() {
      _snapFrom = dragX;
      _snapTo = target;
      _dragX = null;
    });
    _snap.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _snapFrom = null;
        _snapTo = null;
      });
    });
  }

  void _onCancel() {
    if (!mounted) return;
    setState(() {
      _dragX = null;
      _snapFrom = null;
      _snapTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final innerHeight = math.min(_kCollapsedBarSelectionHeight, widget.height);
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      child: _CollapsedSelectionRow(
        key: _rowKey,
        selectedIndex: widget.selectedIndex,
        dragX: _visualDragX,
        textDirection: Directionality.of(context),
        children: [
          ExcludeSemantics(
            child: IgnorePointer(
              child: DecoratedBox(
                key: const ValueKey(
                  'cupertino-sidebar-collapsed-selection-highlight',
                ),
                decoration: BoxDecoration(
                  color: widget.highlight,
                  borderRadius: BorderRadius.circular(innerHeight / 2),
                ),
              ),
            ),
          ),
          ...widget.children,
        ],
      ),
    );
  }
}

class _CollapsedSelectionRow extends MultiChildRenderObjectWidget {
  const _CollapsedSelectionRow({
    super.key,
    required this.selectedIndex,
    required this.dragX,
    required this.textDirection,
    required super.children,
  });

  final int? selectedIndex;
  final double? dragX;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCollapsedSelection(
      selectedIndex: selectedIndex,
      dragX: dragX,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderCollapsedSelection renderObject,
  ) {
    renderObject
      ..selectedIndex = selectedIndex
      ..dragX = dragX
      ..textDirection = textDirection;
  }
}

class _CollapsedSelectionParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderCollapsedSelection extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CollapsedSelectionParentData>,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          _CollapsedSelectionParentData
        > {
  _RenderCollapsedSelection({
    required this._selectedIndex,
    required this._dragX,
    required this._textDirection,
  });

  static const double _horizontalInset = 2;
  static const double _highlightHeight = _kCollapsedBarSelectionHeight;

  int? _selectedIndex;
  double? _dragX;
  TextDirection _textDirection;

  int? get selectedIndex => _selectedIndex;

  set selectedIndex(int? value) {
    if (_selectedIndex == value) return;
    _selectedIndex = value;
    markNeedsLayout();
  }

  double? get dragX => _dragX;

  set dragX(double? value) {
    if (_dragX == value) return;
    _dragX = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CollapsedSelectionParentData) {
      child.parentData = _CollapsedSelectionParentData();
    }
  }

  RenderBox? get _highlight => firstChild;

  Iterable<RenderBox> get _items sync* {
    var child = firstChild == null ? null : childAfter(firstChild!);
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  int get _itemCount {
    var count = 0;
    for (final _ in _items) {
      count++;
    }
    return count;
  }

  RenderBox? _itemAt(int? index) {
    if (index == null) return null;
    var cursor = 0;
    for (final item in _items) {
      if (cursor == index) return item;
      cursor++;
    }
    return null;
  }

  /// Destination index whose horizontal span contains [x].
  int indexAt(double x) {
    final count = _itemCount;
    if (count == 0) return 0;
    var index = 0;
    var leftmost = 0;
    var rightmost = 0;
    var left = double.infinity;
    var right = double.negativeInfinity;
    for (final item in _items) {
      final data = item.parentData! as _CollapsedSelectionParentData;
      final start = data.offset.dx;
      final end = start + item.size.width;
      if (x >= start && x < end) return index;
      if (start < left) {
        left = start;
        leftmost = index;
      }
      if (end > right) {
        right = end;
        rightmost = index;
      }
      index++;
    }
    if (x < left) return leftmost;
    return rightmost;
  }

  /// Horizontal center of the destination at [index], if it has been laid out.
  double? childCenter(int index) {
    final item = _itemAt(index);
    if (item == null || !item.hasSize) return null;
    final data = item.parentData! as _CollapsedSelectionParentData;
    return data.offset.dx + item.size.width / 2;
  }

  Rect _itemHighlight(RenderBox item) {
    final data = item.parentData! as _CollapsedSelectionParentData;
    final highlightHeight = math.min(_highlightHeight, item.size.height);
    return Rect.fromLTWH(
      data.offset.dx + _horizontalInset,
      data.offset.dy + (item.size.height - highlightHeight) / 2,
      math.max(0.0, item.size.width - _horizontalInset * 2),
      highlightHeight,
    );
  }

  Rect? _highlightRect() {
    final highlight = _highlight;
    if (highlight == null || _itemCount == 0) return null;
    final dragX = _dragX;
    if (dragX != null) {
      final item = _itemAt(indexAt(dragX));
      if (item == null) return null;
      final resting = _itemHighlight(item);
      const minLeft = _horizontalInset;
      final maxLeft = math.max(
        minLeft,
        size.width - resting.width - _horizontalInset,
      );
      final left = (dragX - resting.width / 2).clamp(minLeft, maxLeft);
      return Rect.fromLTWH(left, resting.top, resting.width, resting.height);
    }
    final item = _itemAt(_selectedIndex);
    if (item == null) return null;
    return _itemHighlight(item);
  }

  @override
  void performLayout() {
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    var width = 0.0;
    var height = 0.0;
    for (final item in _items) {
      item.layout(loose, parentUsesSize: true);
      width += item.size.width;
      height = math.max(height, item.size.height);
    }
    size = constraints.constrain(Size(width, height));
    var cursor = switch (_textDirection) {
      TextDirection.ltr => 0.0,
      TextDirection.rtl => size.width,
    };
    for (final item in _items) {
      final data = item.parentData! as _CollapsedSelectionParentData;
      final childY = (size.height - item.size.height) / 2;
      switch (_textDirection) {
        case TextDirection.ltr:
          data.offset = Offset(cursor, childY);
          cursor += item.size.width;
        case TextDirection.rtl:
          cursor -= item.size.width;
          data.offset = Offset(cursor, childY);
      }
    }
    final highlight = _highlight;
    if (highlight == null) return;
    final rect = _highlightRect();
    if (rect == null) {
      highlight.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
      (highlight.parentData! as _CollapsedSelectionParentData).offset =
          Offset.zero;
      return;
    }
    highlight.layout(BoxConstraints.tight(rect.size), parentUsesSize: true);
    (highlight.parentData! as _CollapsedSelectionParentData).offset =
        rect.topLeft;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

/// Glass capsule that keeps [leading] pinned while [child] scrolls.
///
/// The sidebar uses this to place the toggle at the start of the collapsed
/// bar. It is not part of the package's exported API.
///
/// The capsule's minimum width is [leading] plus [minimumBodyExtent]. A
/// narrower slot overflows.
class CupertinoSidebarCollapsedCapsule extends StatelessWidget {
  /// Creates a capsule around [leading] and [child].
  const CupertinoSidebarCollapsedCapsule({
    super.key,
    required this.leading,
    required this.child,
    required this.style,
    required this.backgroundColor,
    required this.minimumBodyExtent,
    required this.height,
    this.showSeparator = false,
  });

  /// Control pinned at the start, usually the sidebar toggle.
  final Widget leading;

  /// Destinations laid out after [leading].
  final Widget child;

  /// Sidebar style used to resolve this collapsed surface.
  final CupertinoSidebarStyle style;

  /// Optional tint. Null uses the measured edge preset.
  ///
  /// Liquid callers provide their already-resolved theme bar tint.
  final Color? backgroundColor;

  /// Minimum width of [child], after [leading].
  final double minimumBodyExtent;

  /// Height of the capsule. The corner radius is half of this height.
  final double height;

  /// Draws a hairline between [leading] and [child].
  final bool showSeparator;

  @override
  Widget build(BuildContext context) {
    final edge = style == CupertinoSidebarStyle.liquidEdge;
    final sourceBackground = edge
        ? backgroundColor ??
              CupertinoDynamicColor.resolve(
                _cupertinoCollapsedEdgeSurfaceColor,
                context,
              )
        : backgroundColor!;
    final resolvedBackground = CupertinoDynamicColor.resolve(
      sourceBackground,
      context,
    );
    final effectiveBackground = edge
        ? resolvedBackground.withValues(
            alpha: math.min(resolvedBackground.a, _kCollapsedBarEdgeFillAlpha),
          )
        : resolvedBackground;
    final border = edge
        ? Border.all(
            color: CupertinoDynamicColor.resolve(
              _cupertinoCollapsedEdgeBorderColor,
              context,
            ),
            width: 0.5,
          )
        : CupertinoSidebarChrome.liquid.border.resolve(context);
    return CupertinoFloatingGlassSurface(
      key: const ValueKey('cupertino-sidebar-collapsed-capsule'),
      backgroundColor: effectiveBackground,
      borderRadius: BorderRadius.circular(height / 2),
      blurSigma: CupertinoSidebarChrome.liquid.blurSigma,
      boxShadow: edge
          ? _cupertinoCollapsedEdgeShadow
          : CupertinoSidebarChrome.liquid.boxShadow,
      border: border,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _PinnedCapsuleRow(
            minimumBodyExtent: minimumBodyExtent,
            leading: leading,
            separator: showSeparator ? const _CapsuleSeparator() : null,
            body: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                primary: false,
                physics: const ClampingScrollPhysics(),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsuleSeparator extends StatelessWidget {
  const _CapsuleSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('cupertino-sidebar-collapsed-separator'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 1,
        height: 20,
        child: ColoredBox(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.separator,
            context,
          ),
        ),
      ),
    );
  }
}

class _PinnedCapsuleRow extends MultiChildRenderObjectWidget {
  _PinnedCapsuleRow({
    required this.minimumBodyExtent,
    required Widget leading,
    required Widget? separator,
    required Widget body,
  }) : super(children: [leading, ?separator, body]);

  final double minimumBodyExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPinnedCapsuleRow(
      textDirection: Directionality.of(context),
      minimumBodyExtent: minimumBodyExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPinnedCapsuleRow renderObject,
  ) {
    renderObject
      ..textDirection = Directionality.of(context)
      ..minimumBodyExtent = minimumBodyExtent;
  }
}

class _CapsuleParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderPinnedCapsuleRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CapsuleParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CapsuleParentData>,
        DebugOverflowIndicatorMixin {
  _RenderPinnedCapsuleRow({
    required this._textDirection,
    required this._minimumBodyExtent,
  });

  TextDirection _textDirection;
  double _minimumBodyExtent;
  double _overflow = 0;
  Rect _overflowChildRect = Rect.zero;

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  double get minimumBodyExtent => _minimumBodyExtent;

  set minimumBodyExtent(double value) {
    if (_minimumBodyExtent == value) return;
    _minimumBodyExtent = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CapsuleParentData) {
      child.parentData = _CapsuleParentData();
    }
  }

  @override
  void performLayout() {
    final leading = firstChild!;
    final next = childAfter(leading)!;
    final afterNext = childAfter(next);
    final RenderBox? separator;
    final RenderBox body;
    if (afterNext == null) {
      separator = null;
      body = next;
    } else {
      separator = next;
      body = afterNext;
    }
    final height = constraints.maxHeight;
    final looseHeight = BoxConstraints(
      maxWidth: constraints.maxWidth,
      maxHeight: height,
    );

    leading.layout(looseHeight, parentUsesSize: true);
    separator?.layout(looseHeight, parentUsesSize: true);
    final used = leading.size.width + (separator?.size.width ?? 0);
    final available = constraints.maxWidth.isFinite
        ? math.max(0.0, constraints.maxWidth - used)
        : double.infinity;
    final bodyExtent = !available.isFinite || available >= _minimumBodyExtent
        ? available
        : _minimumBodyExtent;
    body.layout(
      BoxConstraints(
        minWidth: _minimumBodyExtent,
        maxWidth: bodyExtent,
        maxHeight: height,
      ),
      parentUsesSize: true,
    );

    final contentWidth = used + body.size.width;
    size = constraints.constrain(Size(contentWidth, height));
    _overflow = math.max(0.0, contentWidth - size.width);
    final shift = textDirection == TextDirection.rtl
        ? size.width - contentWidth
        : 0.0;
    _overflowChildRect = Rect.fromLTWH(shift, 0, contentWidth, size.height);
    var cursor = switch (textDirection) {
      TextDirection.ltr => 0.0,
      TextDirection.rtl => contentWidth,
    };
    for (final child in [leading, ?separator, body]) {
      final childParentData = child.parentData! as _CapsuleParentData;
      final childY = (size.height - child.size.height) / 2;
      switch (textDirection) {
        case TextDirection.ltr:
          childParentData.offset = Offset(cursor + shift, childY);
          cursor += child.size.width;
        case TextDirection.rtl:
          cursor -= child.size.width;
          childParentData.offset = Offset(cursor + shift, childY);
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
    if (_overflow <= 0) return;
    assert(() {
      paintOverflowIndicator(
        context,
        offset,
        Offset.zero & size,
        _overflowChildRect,
      );
      return true;
    }());
  }
}
