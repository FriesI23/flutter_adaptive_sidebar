import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import 'ios_navigation_obstruction.dart';

part 'example_app.dart';

void main() {
  runApp(const AdaptiveSidebarExampleApp());
}

/// Demonstrates style switching and size-based sidebar placement.
class AdaptiveSidebarExample extends StatefulWidget {
  /// Creates the example page.
  const AdaptiveSidebarExample({
    super.key,
    required this.cupertino,
    required this.themeMode,
    required this.themeColor,
    required this.onThemeModeChanged,
    required this.onThemeColorChanged,
  });

  /// Forces the Cupertino sidebar when true, and Material when false.
  ///
  /// Null follows the host platform.
  final bool? cupertino;

  /// Active light, dark, or system appearance.
  final ThemeMode themeMode;

  /// Cupertino theme color demonstrated by both sidebar forms.
  final ExampleThemeColor themeColor;

  /// Updates [themeMode].
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// Updates [themeColor].
  final ValueChanged<ExampleThemeColor> onThemeColorChanged;

  @override
  State<AdaptiveSidebarExample> createState() => _AdaptiveSidebarExampleState();
}

class _AdaptiveSidebarExampleState extends State<AdaptiveSidebarExample> {
  static const int _homeItemCount = 9999;

  static const List<AdaptiveNavigationDestination> _destinations = [
    AdaptiveNavigationDestination(
      label: 'Home',
      icons: NavigationDestinationIcons(
        material: Icon(Icons.home_outlined),
        materialSelected: Icon(Icons.home),
        cupertino: Icon(CupertinoIcons.house),
        cupertinoSelected: Icon(CupertinoIcons.house_fill),
      ),
    ),
    AdaptiveNavigationDestination(
      label: 'Search',
      icons: NavigationDestinationIcons(
        material: Icon(Icons.search),
        materialSelected: Icon(Icons.search),
        cupertino: Icon(CupertinoIcons.search),
        cupertinoSelected: Icon(CupertinoIcons.search),
      ),
    ),
  ];

  static const AdaptiveNavigationDestination _settingsDestination =
      AdaptiveNavigationDestination(
        label: 'Settings',
        icons: NavigationDestinationIcons(
          material: Icon(Icons.settings_outlined),
          materialSelected: Icon(Icons.settings),
          cupertino: Icon(CupertinoIcons.gear),
          cupertinoSelected: Icon(CupertinoIcons.gear_solid),
        ),
      );

  final AdaptiveNavigationController _controller =
      AdaptiveNavigationController();
  late _SidebarStyle _style;
  _CollapsedBarTransition _collapsedBarTransition =
      _CollapsedBarTransition.drop;
  CupertinoSidebarCollapsedBarPlacement _collapsedBarPlacement =
      CupertinoSidebarCollapsedBarPlacement.toolbarAnchor;
  bool _collapsedBarSeparator = false;
  bool _collapsedBarIcons = false;
  CupertinoSidebarStyle _cupertinoStyle = CupertinoSidebarStyle.liquid;
  _ToolbarTopInsetMode _toolbarTopInsetMode = _ToolbarTopInsetMode.automatic;
  double _customToolbarTopInset =
      CupertinoSidebarToolbarGeometry.compact.topInset;
  _ExpansionMode _mode = _ExpansionMode.automatic;
  bool _autoPaused = false;
  bool _applyingExpansion = false;
  bool _trackedExpanded = true;
  double _preferredWidth = 200;
  double _minimumWidth = 180;
  double _maximumWidth = 360;
  double _collapsedExtent = 96;
  double _automaticExpandedWidth = 800;
  bool _customDragHandle = false;
  bool _customTooltip = false;
  bool _customLabels = false;
  bool _customContent = false;
  bool _customSideStyle = false;
  bool _customBarStyle = false;
  String? _customPageTitle;
  bool _placementDemoVisible = false;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _style = switch (widget.cupertino) {
      true => _SidebarStyle.cupertino,
      false => _SidebarStyle.material,
      null => _platformSidebarStyle(),
    };
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final expandedChanged = _controller.expanded != _trackedExpanded;
    _trackedExpanded = _controller.expanded;
    if (!_applyingExpansion &&
        expandedChanged &&
        _mode == _ExpansionMode.automatic) {
      _autoPaused = true;
    }
    if (mounted) setState(() {});
  }

  bool _sizeWantsExpanded(Size size) => size.width >= _automaticExpandedWidth;

  void _setExpanded(bool value) {
    _applyingExpansion = true;
    _controller.expanded = value;
    _applyingExpansion = false;
  }

  void _scheduleAutomaticExpansion() {
    if (_mode != _ExpansionMode.automatic || _autoPaused) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mode != _ExpansionMode.automatic || _autoPaused) return;
      final expanded = _sizeWantsExpanded(MediaQuery.sizeOf(context));
      if (_controller.expanded == expanded) return;
      _setExpanded(expanded);
    });
  }

  void _selectPrimary(int index) {
    _onSelectionChanged(SidebarPrimarySelection(index));
  }

  void _selectAuxiliary(int index) {
    _onSelectionChanged(SidebarAuxiliarySelection(index));
  }

  void _onSelectionChanged(SidebarDestinationSelection selection) {
    setState(() {
      _customPageTitle = null;
      _placementDemoVisible = false;
    });
    _controller.select(selection);
  }

  void _selectCustomPage(String title) {
    setState(() => _customPageTitle = title);
  }

  bool get _settingsSelected =>
      _customPageTitle == null &&
      _controller.selection is SidebarAuxiliarySelection;

  int get _primaryIndex => _controller.selection.primaryIndex ?? 0;

  Widget _sidebarContent() {
    if (!_customContent) return _navigation();
    return _CustomSidebarContent(
      style: _style,
      destinations: _destinations,
      settingsDestination: _settingsDestination,
      selectedIndex: _primaryIndex,
      settingsSelected: _settingsSelected,
      selectedLabel: _customPageTitle,
      itemStyle: _customSideStyle ? _kCustomSideItemStyle : null,
      materialItemStyle: _customSideStyle ? _kCustomMaterialItemStyle : null,
      onDestinationSelected: _selectPrimary,
      onSettingsSelected: () => _selectAuxiliary(0),
      onLabelSelected: _selectCustomPage,
    );
  }

  Widget _navigation() {
    if (_style == _SidebarStyle.material) {
      return MaterialSidebarNavigation(
        destinations: _destinations,
        selection: _controller.selection,
        onSelectionChanged: _onSelectionChanged,
        auxiliaryDestinations: const [_settingsDestination],
        itemStyle: _customSideStyle ? _kCustomMaterialItemStyle : null,
      );
    }
    return CupertinoSidebarNavigation(
      destinations: _destinations,
      selection: _controller.selection,
      onSelectionChanged: _onSelectionChanged,
      auxiliaryDestinations: const [_settingsDestination],
      itemStyle: _customSideStyle ? _kCustomSideItemStyle : null,
    );
  }

  void _onModeChanged(_ExpansionMode mode) {
    setState(() {
      _mode = mode;
      _autoPaused = false;
    });
    switch (mode) {
      case _ExpansionMode.automatic:
        _setExpanded(_sizeWantsExpanded(MediaQuery.sizeOf(context)));
      case _ExpansionMode.collapsed:
        _setExpanded(false);
      case _ExpansionMode.expanded:
        _setExpanded(true);
    }
  }

  void _toggleDirection() {
    setState(() {
      _textDirection = _textDirection == TextDirection.ltr
          ? TextDirection.rtl
          : TextDirection.ltr;
    });
  }

  Widget _cupertinoSidebar(Widget body) {
    final toolbarGeometry = _toolbarGeometry;
    final showingPrimary =
        _controller.selection is SidebarPrimarySelection &&
        _customPageTitle == null;
    final collapsedBar = _customContent
        ? null
        : CupertinoSidebarCollapsedBar(
            destinations: _destinations,
            selectedIndex: showingPrimary ? _primaryIndex : null,
            showIcons: _collapsedBarIcons,
            itemStyle: _customBarStyle ? _kCustomBarItemStyle : null,
            onDestinationSelected: _selectPrimary,
          );
    final transition = switch (_collapsedBarTransition) {
      _CollapsedBarTransition.drop =>
        CupertinoSidebarCollapsedBarTransition.drop,
      _CollapsedBarTransition.fade =>
        CupertinoSidebarCollapsedBarTransition.fade,
    };
    // One constructor sets the glass and the selection fill together.
    return switch (_cupertinoStyle) {
      CupertinoSidebarStyle.liquid => CupertinoSidebar(
        controller: _controller,
        content: _sidebarContent(),
        scaffoldBackgroundColor: Colors.transparent,
        collapsedBarPlacement: _collapsedBarPlacement,
        collapsedBarSeparator: _collapsedBarSeparator,
        collapsedBar: collapsedBar,
        collapsedBarTransitionBuilder: transition,
        toolbarGeometry: toolbarGeometry,
        extent: _extent,
        dragHandleBuilder: _dragHandleBuilder,
        tooltipBuilder: _tooltipBuilder,
        expandLabel: _customLabels ? 'Show sidebar' : null,
        collapseLabel: _customLabels ? 'Hide sidebar' : null,
        child: body,
      ),
      CupertinoSidebarStyle.liquidEdge => CupertinoSidebar.edge(
        controller: _controller,
        content: _sidebarContent(),
        scaffoldBackgroundColor: Colors.transparent,
        collapsedBarPlacement: _collapsedBarPlacement,
        collapsedBarSeparator: _collapsedBarSeparator,
        collapsedBar: collapsedBar,
        collapsedBarTransitionBuilder: transition,
        toolbarGeometry: toolbarGeometry,
        extent: _extent,
        dragHandleBuilder: _dragHandleBuilder,
        tooltipBuilder: _tooltipBuilder,
        expandLabel: _customLabels ? 'Show sidebar' : null,
        collapseLabel: _customLabels ? 'Hide sidebar' : null,
        child: body,
      ),
    };
  }

  void _toggleStyle() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _style = _style == _SidebarStyle.material
          ? _SidebarStyle.cupertino
          : _SidebarStyle.material;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleAutomaticExpansion();
  }

  SideNavigationExtent get _extent => SideNavigationExtent(
    _preferredWidth,
    minimum: _minimumWidth,
    maximum: _maximumWidth,
  );

  CupertinoSidebarToolbarGeometry get _toolbarGeometry =>
      switch (_toolbarTopInsetMode) {
        _ToolbarTopInsetMode.automatic =>
          CupertinoSidebarToolbarGeometry.standard,
        _ToolbarTopInsetMode.unified => CupertinoSidebarToolbarGeometry(
          contentHeight: CupertinoSidebarToolbarGeometry.standard.contentHeight,
          collapsedBarHeight:
              CupertinoSidebarToolbarGeometry.standard.collapsedBarHeight,
          height: CupertinoSidebarToolbarGeometry.standard.height,
          topInset: CupertinoSidebarToolbarGeometry.compact.topInset,
        ),
        _ToolbarTopInsetMode.custom => CupertinoSidebarToolbarGeometry(
          contentHeight: CupertinoSidebarToolbarGeometry.standard.contentHeight,
          collapsedBarHeight:
              CupertinoSidebarToolbarGeometry.standard.collapsedBarHeight,
          height: CupertinoSidebarToolbarGeometry.standard.height,
          topInset: _customToolbarTopInset,
        ),
      };

  void _setAutomaticExpandedWidth(double value) {
    setState(() => _automaticExpandedWidth = value);
    if (_mode != _ExpansionMode.automatic || _autoPaused) return;
    _setExpanded(_sizeWantsExpanded(MediaQuery.sizeOf(context)));
  }

  void _setPreferredWidth(double value) {
    setState(() => _preferredWidth = value);
    _controller.clearManualWidth();
  }

  void _setMinimumWidth(double value) {
    setState(() {
      _minimumWidth = value;
      if (_maximumWidth < _minimumWidth) _maximumWidth = _minimumWidth;
      if (_preferredWidth < _minimumWidth) _preferredWidth = _minimumWidth;
    });
    _controller.clearManualWidth();
  }

  void _setMaximumWidth(double value) {
    setState(() {
      _maximumWidth = value;
      if (_preferredWidth > _maximumWidth) _preferredWidth = _maximumWidth;
    });
    _controller.clearManualWidth();
  }

  NavigationTooltipBuilder? get _tooltipBuilder {
    if (!_customTooltip) return null;
    return (context, message, child) => DecoratedBox(
      key: const ValueKey('custom-tooltip'),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00897B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  SideNavigationDragHandleBuilder? get _dragHandleBuilder {
    if (!_customDragHandle) return null;
    return (context, states) {
      final active =
          states.contains(WidgetState.dragged) ||
          states.contains(WidgetState.hovered);
      return Center(
        child: Container(
          key: const ValueKey('custom-drag-handle'),
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF00897B) : const Color(0x6600897B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final body = _ExampleBody(
      style: _style,
      mode: _mode,
      selectedIndex: _primaryIndex,
      settingsSelected: _settingsSelected,
      customPageTitle: _customPageTitle,
      itemCount: _homeItemCount,
      themeMode: widget.themeMode,
      themeColor: widget.themeColor,
      textDirection: _textDirection,
      settings: _SettingsValues(
        preferredWidth: _preferredWidth,
        minimumWidth: _minimumWidth,
        maximumWidth: _maximumWidth,
        collapsedExtent: _collapsedExtent,
        automaticExpandedWidth: _automaticExpandedWidth,
        customDragHandle: _customDragHandle,
        customTooltip: _customTooltip,
        customLabels: _customLabels,
        customContent: _customContent,
      ),
      toolbarGeometry: _toolbarGeometry,
      toolbarTopInsetMode: _toolbarTopInsetMode,
      customToolbarTopInset: _customToolbarTopInset,
      onToolbarTopInsetModeChanged: (value) =>
          setState(() => _toolbarTopInsetMode = value),
      onCustomToolbarTopInsetChanged: (value) => setState(() {
        _toolbarTopInsetMode = _ToolbarTopInsetMode.custom;
        _customToolbarTopInset = value;
      }),
      onToggleStyle: _toggleStyle,
      onToggleDirection: _toggleDirection,
      onModeChanged: _onModeChanged,
      onThemeModeChanged: widget.onThemeModeChanged,
      onThemeColorChanged: widget.onThemeColorChanged,
      onPreferredWidthChanged: _setPreferredWidth,
      onMinimumWidthChanged: _setMinimumWidth,
      onMaximumWidthChanged: _setMaximumWidth,
      onCollapsedExtentChanged: (value) =>
          setState(() => _collapsedExtent = value),
      onAutomaticExpandedWidthChanged: _setAutomaticExpandedWidth,
      onCustomDragHandleChanged: (value) =>
          setState(() => _customDragHandle = value),
      onCustomTooltipChanged: (value) => setState(() => _customTooltip = value),
      onCustomLabelsChanged: (value) => setState(() => _customLabels = value),
      onCustomContentChanged: (value) => setState(() => _customContent = value),
      customSideStyle: _customSideStyle,
      onCustomSideStyleChanged: (value) =>
          setState(() => _customSideStyle = value),
      customBarStyle: _customBarStyle,
      onCustomBarStyleChanged: (value) =>
          setState(() => _customBarStyle = value),
      collapsedBarTransition: _collapsedBarTransition,
      onCollapsedBarTransitionChanged: (value) =>
          setState(() => _collapsedBarTransition = value),
      collapsedBarPlacement: _collapsedBarPlacement,
      onCollapsedBarPlacementChanged: (value) =>
          setState(() => _collapsedBarPlacement = value),
      onOpenPlacementDemo: () => setState(() => _placementDemoVisible = true),
      collapsedBarSeparator: _collapsedBarSeparator,
      onCollapsedBarSeparatorChanged: (value) =>
          setState(() => _collapsedBarSeparator = value),
      collapsedBarIcons: _collapsedBarIcons,
      onCollapsedBarIconsChanged: (value) =>
          setState(() => _collapsedBarIcons = value),
      cupertinoStyle: _cupertinoStyle,
      onCupertinoStyleChanged: (value) =>
          setState(() => _cupertinoStyle = value),
    );
    final Widget page;
    if (_style == _SidebarStyle.material) {
      page = Row(
        children: [
          MaterialSidebar(
            controller: _controller,
            content: _sidebarContent(),
            extent: _extent,
            collapsedExtent: _collapsedExtent,
            dragHandleBuilder: _dragHandleBuilder,
            tooltipBuilder: _tooltipBuilder,
            expandLabel: _customLabels ? 'Show sidebar' : null,
            collapseLabel: _customLabels ? 'Hide sidebar' : null,
          ),
          Expanded(child: body),
        ],
      );
    } else {
      page = _cupertinoSidebar(
        Navigator(
          key: const ValueKey('cupertino-placement-demo-navigator'),
          pages: [
            _PlacementDemoRoutePage(
              key: const ValueKey('cupertino-example-root-page'),
              child: body,
            ),
            if (_placementDemoVisible)
              _PlacementDemoRoutePage(
                key: const ValueKey('cupertino-placement-demo-page'),
                child: _PlacementDemoPage(
                  placement: _collapsedBarPlacement,
                  toolbarGeometry: _toolbarGeometry,
                ),
              ),
          ],
          onDidRemovePage: (page) {
            if (page.key != const ValueKey('cupertino-placement-demo-page') ||
                !_placementDemoVisible) {
              return;
            }
            setState(() => _placementDemoVisible = false);
          },
        ),
      );
    }

    return Directionality(
      textDirection: _textDirection,
      child: _ExampleBackground(themeColor: widget.themeColor, child: page),
    );
  }
}
