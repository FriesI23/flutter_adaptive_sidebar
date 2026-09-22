import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

void main() {
  runApp(const AdaptiveSidebarExampleApp());
}

/// Example host for the Material and Cupertino sidebars.
class AdaptiveSidebarExampleApp extends StatefulWidget {
  /// Creates the example app.
  const AdaptiveSidebarExampleApp({super.key});

  @override
  State<AdaptiveSidebarExampleApp> createState() =>
      _AdaptiveSidebarExampleAppState();
}

class _AdaptiveSidebarExampleAppState extends State<AdaptiveSidebarExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: colorScheme.primary,
        scaffoldBackgroundColor: colorScheme.surface,
        applyThemeToAll: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive sidebar',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _themeMode,
      home: IosNavigationObstruction(
        child: AdaptiveSidebarExample(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      ),
    );
  }
}

enum _SidebarStyle { material, cupertino }

enum _ExpansionMode { automatic, collapsed, expanded }

/// Demonstrates style switching and size-based sidebar placement.
class AdaptiveSidebarExample extends StatefulWidget {
  /// Creates the example page.
  const AdaptiveSidebarExample({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  /// Active light, dark, or system appearance.
  final ThemeMode themeMode;

  /// Updates [themeMode].
  final ValueChanged<ThemeMode> onThemeModeChanged;

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
  int? _selectedAuxiliaryIndex;
  _SidebarStyle _style = _SidebarStyle.material;
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
  String? _customPageTitle;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _selectedAuxiliaryIndex = null;
      _customPageTitle = null;
    });
    _controller.select(index);
  }

  void _selectAuxiliary(int index) {
    setState(() {
      _selectedAuxiliaryIndex = index;
      _customPageTitle = null;
    });
  }

  void _selectCustomPage(String title) {
    setState(() {
      _selectedAuxiliaryIndex = null;
      _customPageTitle = title;
    });
  }

  Widget _sidebarContent() {
    if (!_customContent) return _navigation();
    return _CustomSidebarContent(
      style: _style,
      destinations: _destinations,
      settingsDestination: _settingsDestination,
      selectedIndex: _controller.selectedIndex,
      settingsSelected: _selectedAuxiliaryIndex != null,
      selectedLabel: _customPageTitle,
      onDestinationSelected: _selectPrimary,
      onSettingsSelected: () => _selectAuxiliary(0),
      onLabelSelected: _selectCustomPage,
    );
  }

  Widget _navigation() {
    if (_style == _SidebarStyle.material) {
      return MaterialSidebarNavigation(
        destinations: _destinations,
        selectedIndex: _controller.selectedIndex,
        onDestinationSelected: _selectPrimary,
        auxiliaryDestinations: const [_settingsDestination],
        selectedAuxiliaryIndex: _selectedAuxiliaryIndex,
        onAuxiliaryDestinationSelected: _selectAuxiliary,
      );
    }
    return CupertinoSidebarNavigation(
      destinations: _destinations,
      selectedIndex: _controller.selectedIndex,
      onDestinationSelected: _selectPrimary,
      auxiliaryDestinations: const [_settingsDestination],
      selectedAuxiliaryIndex: _selectedAuxiliaryIndex,
      onAuxiliaryDestinationSelected: _selectAuxiliary,
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

  void _toggleStyle() {
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
      selectedIndex: _controller.selectedIndex,
      settingsSelected: _selectedAuxiliaryIndex != null,
      customPageTitle: _customPageTitle,
      itemCount: _homeItemCount,
      themeMode: widget.themeMode,
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
      onToggleStyle: _toggleStyle,
      onToggleDirection: _toggleDirection,
      onModeChanged: _onModeChanged,
      onThemeModeChanged: widget.onThemeModeChanged,
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
    );
    final Widget page;
    if (_style == _SidebarStyle.material) {
      page = Row(
        children: [
          MaterialSidebar(
            controller: _controller,
            content: _sidebarContent(),
            extent: _extent,
            style: MaterialSidebarStyle(collapsedExtent: _collapsedExtent),
            dragHandleBuilder: _dragHandleBuilder,
            tooltipBuilder: _tooltipBuilder,
            expandLabel: _customLabels ? 'Show sidebar' : null,
            collapseLabel: _customLabels ? 'Hide sidebar' : null,
          ),
          Expanded(child: body),
        ],
      );
    } else {
      page = CupertinoSidebar(
        controller: _controller,
        content: _sidebarContent(),
        extent: _extent,
        dragHandleBuilder: _dragHandleBuilder,
        tooltipBuilder: _tooltipBuilder,
        expandLabel: _customLabels ? 'Show sidebar' : null,
        collapseLabel: _customLabels ? 'Hide sidebar' : null,
        child: body,
      );
    }

    return Directionality(textDirection: _textDirection, child: page);
  }
}

class _SettingsValues {
  const _SettingsValues({
    required this.preferredWidth,
    required this.minimumWidth,
    required this.maximumWidth,
    required this.collapsedExtent,
    required this.automaticExpandedWidth,
    required this.customDragHandle,
    required this.customTooltip,
    required this.customLabels,
    required this.customContent,
  });

  final double preferredWidth;
  final double minimumWidth;
  final double maximumWidth;
  final double collapsedExtent;
  final double automaticExpandedWidth;
  final bool customDragHandle;
  final bool customTooltip;
  final bool customLabels;
  final bool customContent;
}

class _ExampleBody extends StatelessWidget {
  const _ExampleBody({
    required this.style,
    required this.mode,
    required this.selectedIndex,
    required this.settingsSelected,
    required this.customPageTitle,
    required this.itemCount,
    required this.themeMode,
    required this.textDirection,
    required this.settings,
    required this.onToggleStyle,
    required this.onToggleDirection,
    required this.onModeChanged,
    required this.onThemeModeChanged,
    required this.onPreferredWidthChanged,
    required this.onMinimumWidthChanged,
    required this.onMaximumWidthChanged,
    required this.onCollapsedExtentChanged,
    required this.onAutomaticExpandedWidthChanged,
    required this.onCustomDragHandleChanged,
    required this.onCustomTooltipChanged,
    required this.onCustomLabelsChanged,
    required this.onCustomContentChanged,
  });

  final _SidebarStyle style;
  final _ExpansionMode mode;
  final int selectedIndex;
  final bool settingsSelected;
  final String? customPageTitle;
  final int itemCount;
  final ThemeMode themeMode;
  final TextDirection textDirection;
  final _SettingsValues settings;
  final VoidCallback onToggleStyle;
  final VoidCallback onToggleDirection;
  final ValueChanged<_ExpansionMode> onModeChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<double> onPreferredWidthChanged;
  final ValueChanged<double> onMinimumWidthChanged;
  final ValueChanged<double> onMaximumWidthChanged;
  final ValueChanged<double> onCollapsedExtentChanged;
  final ValueChanged<double> onAutomaticExpandedWidthChanged;
  final ValueChanged<bool> onCustomDragHandleChanged;
  final ValueChanged<bool> onCustomTooltipChanged;
  final ValueChanged<bool> onCustomLabelsChanged;
  final ValueChanged<bool> onCustomContentChanged;

  @override
  Widget build(BuildContext context) {
    final customPageTitle = this.customPageTitle;
    final Widget page;
    if (settingsSelected) {
      page = _SettingsPage(
        style: style,
        settings: settings,
        onPreferredWidthChanged: onPreferredWidthChanged,
        onMinimumWidthChanged: onMinimumWidthChanged,
        onMaximumWidthChanged: onMaximumWidthChanged,
        onCollapsedExtentChanged: onCollapsedExtentChanged,
        onAutomaticExpandedWidthChanged: onAutomaticExpandedWidthChanged,
        onCustomDragHandleChanged: onCustomDragHandleChanged,
        onCustomTooltipChanged: onCustomTooltipChanged,
        onCustomLabelsChanged: onCustomLabelsChanged,
        onCustomContentChanged: onCustomContentChanged,
      );
    } else if (customPageTitle != null) {
      page = Center(child: Text(customPageTitle));
    } else {
      page = switch (selectedIndex) {
        0 => _HomeList(style: style, itemCount: itemCount),
        _ => const Center(child: Text('Search')),
      };
    }
    final controls = _ExpansionControls(
      style: style,
      mode: mode,
      onChanged: onModeChanged,
    );
    final appearance = _AppearanceButton(
      style: style,
      themeMode: themeMode,
      onChanged: onThemeModeChanged,
    );
    final direction = _DirectionButton(
      style: style,
      direction: textDirection,
      onPressed: onToggleDirection,
    );
    if (style == _SidebarStyle.cupertino) {
      final reserved =
          SidebarLeadingScope.maybeOf(context)?.reservedExtent ?? 0;
      final cupertinoText = CupertinoTheme.of(context).textTheme.textStyle;
      return DefaultTextStyle(
        style: cupertinoText,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: reserved == 0 ? null : SizedBox(width: reserved),
            middle: const Text('Adaptive sidebar'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appearance,
                direction,
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onToggleStyle,
                  child: const Icon(CupertinoIcons.device_phone_portrait),
                ),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                controls,
                Expanded(child: page),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive sidebar'),
        actions: [
          appearance,
          direction,
          IconButton(
            tooltip: 'Use Cupertino',
            onPressed: onToggleStyle,
            icon: const Icon(Icons.phone_iphone),
          ),
        ],
      ),
      body: Column(
        children: [
          controls,
          Expanded(child: page),
        ],
      ),
    );
  }
}

class _AppearanceButton extends StatelessWidget {
  const _AppearanceButton({
    required this.style,
    required this.themeMode,
    required this.onChanged,
  });

  final _SidebarStyle style;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  void _cycle() {
    final next = switch (themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (themeMode) {
      ThemeMode.system =>
        style == _SidebarStyle.cupertino
            ? CupertinoIcons.circle_lefthalf_fill
            : Icons.brightness_auto,
      ThemeMode.light =>
        style == _SidebarStyle.cupertino
            ? CupertinoIcons.sun_max
            : Icons.light_mode,
      ThemeMode.dark =>
        style == _SidebarStyle.cupertino
            ? CupertinoIcons.moon
            : Icons.dark_mode,
    };
    if (style == _SidebarStyle.cupertino) {
      return CupertinoButton(
        key: const ValueKey('appearance-button'),
        padding: EdgeInsets.zero,
        onPressed: _cycle,
        child: Icon(icon),
      );
    }
    return IconButton(
      key: const ValueKey('appearance-button'),
      tooltip: 'Appearance',
      onPressed: _cycle,
      icon: Icon(icon),
    );
  }
}

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({
    required this.style,
    required this.direction,
    required this.onPressed,
  });

  final _SidebarStyle style;
  final TextDirection direction;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final leftToRight = direction == TextDirection.ltr;
    final icon = leftToRight
        ? Icons.format_textdirection_l_to_r
        : Icons.format_textdirection_r_to_l;
    final tooltip = leftToRight ? 'Use right-to-left' : 'Use left-to-right';
    if (style == _SidebarStyle.cupertino) {
      return CupertinoButton(
        key: const ValueKey('direction-button'),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Icon(icon),
      );
    }
    return IconButton(
      key: const ValueKey('direction-button'),
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _ExpansionControls extends StatelessWidget {
  const _ExpansionControls({
    required this.style,
    required this.mode,
    required this.onChanged,
  });

  final _SidebarStyle style;
  final _ExpansionMode mode;
  final ValueChanged<_ExpansionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _ExpansionMode.automatic: 'Auto',
      _ExpansionMode.collapsed: 'Coll',
      _ExpansionMode.expanded: 'Expand',
    };
    if (style == _SidebarStyle.cupertino) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: CupertinoSlidingSegmentedControl<_ExpansionMode>(
          groupValue: mode,
          children: {
            for (final entry in labels.entries)
              entry.key: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(entry.value),
              ),
          },
          onValueChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SegmentedButton<_ExpansionMode>(
        segments: [
          for (final entry in labels.entries)
            ButtonSegment(value: entry.key, label: Text(entry.value)),
        ],
        selected: {mode},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}

class _CustomSidebarContent extends StatelessWidget {
  const _CustomSidebarContent({
    required this.style,
    required this.destinations,
    required this.settingsDestination,
    required this.selectedIndex,
    required this.settingsSelected,
    required this.selectedLabel,
    required this.onDestinationSelected,
    required this.onSettingsSelected,
    required this.onLabelSelected,
  });

  final _SidebarStyle style;
  final List<AdaptiveNavigationDestination> destinations;
  final AdaptiveNavigationDestination settingsDestination;
  final int selectedIndex;
  final bool settingsSelected;
  final String? selectedLabel;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSettingsSelected;
  final ValueChanged<String> onLabelSelected;

  @override
  Widget build(BuildContext context) {
    if (style == _SidebarStyle.cupertino) return _cupertino(context);
    return _material(context);
  }

  Widget _material(BuildContext context) {
    final metrics = MaterialSidebarMetrics.of(context);
    final animation = NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => SizedBox(
        width: lerpDouble(
          metrics.collapsedWidth,
          metrics.expandedWidth,
          animation.value,
        ),
        child: child,
      ),
      child: ListView(
        key: const ValueKey('custom-sidebar-content'),
        children: [
          for (final (index, destination) in destinations.indexed)
            MaterialWideNavigationRailButton(
              slotKey: ValueKey('custom-sidebar-destination-slot-$index'),
              buttonKey: ValueKey('custom-sidebar-destination-$index'),
              animation: animation,
              collapsedRailWidth: metrics.collapsedWidth,
              expandedRailWidth: metrics.expandedWidth,
              destination: destination,
              selected:
                  selectedLabel == null &&
                  !settingsSelected &&
                  selectedIndex == index,
              onPressed: () => onDestinationSelected(index),
            ),
          _MaterialNoteButton(
            animation: animation,
            selected: selectedLabel == 'Note',
            onPressed: () => onLabelSelected('Note'),
          ),
          MaterialWideNavigationRailButton(
            slotKey: const ValueKey('custom-sidebar-settings-slot'),
            buttonKey: const ValueKey('custom-sidebar-settings'),
            animation: animation,
            collapsedRailWidth: metrics.collapsedWidth,
            expandedRailWidth: metrics.expandedWidth,
            destination: settingsDestination,
            selected: settingsSelected,
            onPressed: onSettingsSelected,
          ),
          _ReminderLists(
            expansion: animation,
            cupertino: false,
            selectedLabel: selectedLabel,
            onSelected: onLabelSelected,
          ),
        ],
      ),
    );
  }

  Widget _cupertino(BuildContext context) {
    final primary = CupertinoTheme.of(context).primaryColor;
    return ListView(
      key: const ValueKey('custom-sidebar-content'),
      padding: const EdgeInsets.only(
        top: kMinInteractiveDimensionCupertino + 24,
      ),
      children: [
        for (final (index, destination) in destinations.indexed)
          CupertinoSidebarDestination(
            key: ValueKey('custom-sidebar-destination-$index'),
            destination: destination,
            selected:
                selectedLabel == null &&
                !settingsSelected &&
                selectedIndex == index,
            onPressed: () => onDestinationSelected(index),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: CupertinoButton(
            key: const ValueKey('custom-sidebar-note'),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            minimumSize: const Size(0, 44),
            alignment: AlignmentDirectional.centerStart,
            color: selectedLabel == 'Note'
                ? primary.withValues(alpha: 0.14)
                : null,
            onPressed: () => onLabelSelected('Note'),
            child: const Row(
              children: [
                Icon(CupertinoIcons.pencil),
                SizedBox(width: 12),
                Text('Note'),
              ],
            ),
          ),
        ),
        CupertinoSidebarDestination(
          key: const ValueKey('custom-sidebar-settings'),
          destination: settingsDestination,
          selected: settingsSelected,
          onPressed: onSettingsSelected,
        ),
        _ReminderLists(
          expansion: const AlwaysStoppedAnimation(1),
          cupertino: true,
          selectedLabel: selectedLabel,
          onSelected: onLabelSelected,
        ),
      ],
    );
  }
}

class _MaterialNoteButton extends StatelessWidget {
  const _MaterialNoteButton({
    required this.animation,
    required this.selected,
    required this.onPressed,
  });

  final Animation<double> animation;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    final iconColor = selected ? Theme.of(context).colorScheme.primary : color;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final showLabel = animation.value > 0.6;
        return InkWell(
          key: const ValueKey('custom-sidebar-note'),
          onTap: onPressed,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                const SizedBox(width: 36),
                Icon(Icons.note_alt_outlined, color: iconColor),
                if (showLabel) ...[
                  const SizedBox(width: 12),
                  const Text('Note'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReminderEntry {
  const _ReminderEntry({
    required this.label,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.color,
    this.count,
  });

  final String label;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final Color color;
  final int? count;
}

const List<_ReminderEntry> _smartLists = [
  _ReminderEntry(
    label: 'Today',
    materialIcon: Icons.calendar_today_outlined,
    cupertinoIcon: CupertinoIcons.calendar,
    color: Color(0xFF007AFF),
  ),
  _ReminderEntry(
    label: 'Scheduled',
    materialIcon: Icons.schedule,
    cupertinoIcon: CupertinoIcons.clock,
    color: Color(0xFFFF3B30),
  ),
  _ReminderEntry(
    label: 'All',
    materialIcon: Icons.inbox_outlined,
    cupertinoIcon: CupertinoIcons.tray,
    color: Color(0xFF8E8E93),
  ),
  _ReminderEntry(
    label: 'Flagged',
    materialIcon: Icons.flag_outlined,
    cupertinoIcon: CupertinoIcons.flag,
    color: Color(0xFFFF9500),
  ),
];

const List<_ReminderEntry> _myLists = [
  _ReminderEntry(
    label: 'Groceries',
    materialIcon: Icons.circle,
    cupertinoIcon: CupertinoIcons.circle_fill,
    color: Color(0xFFFFCC00),
    count: 4,
  ),
  _ReminderEntry(
    label: 'Errands',
    materialIcon: Icons.circle,
    cupertinoIcon: CupertinoIcons.circle_fill,
    color: Color(0xFFAF52DE),
    count: 2,
  ),
];

class _ReminderLists extends StatelessWidget {
  const _ReminderLists({
    required this.expansion,
    required this.cupertino,
    required this.selectedLabel,
    required this.onSelected,
  });

  final Animation<double> expansion;
  final bool cupertino;
  final String? selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expansion,
      builder: (context, _) {
        final showLabels = expansion.value > 0.6;
        return Column(
          key: const ValueKey('custom-sidebar-lists'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLabels) const _ReminderHeader('Lists'),
            for (final entry in _smartLists)
              _ReminderRow(
                entry: entry,
                cupertino: cupertino,
                showLabel: showLabels,
                selected: selectedLabel == entry.label,
                onPressed: () => onSelected(entry.label),
              ),
            if (showLabels) const _ReminderHeader('My Lists'),
            for (final entry in _myLists)
              _ReminderRow(
                entry: entry,
                cupertino: cupertino,
                showLabel: showLabels,
                selected: selectedLabel == entry.label,
                onPressed: () => onSelected(entry.label),
              ),
            if (showLabels)
              const _ReminderSummary()
            else
              _CollapsedSummary(cupertino: cupertino),
          ],
        );
      },
    );
  }
}

class _ReminderHeader extends StatelessWidget {
  const _ReminderHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.entry,
    required this.cupertino,
    required this.showLabel,
    required this.selected,
    required this.onPressed,
  });

  final _ReminderEntry entry;
  final bool cupertino;
  final bool showLabel;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      cupertino ? entry.cupertinoIcon : entry.materialIcon,
      color: entry.color,
      size: 22,
    );
    final background = selected ? entry.color.withValues(alpha: 0.16) : null;
    if (!showLabel) {
      return InkWell(
        onTap: onPressed,
        child: ColoredBox(
          color: background ?? const Color(0x00000000),
          child: SizedBox(height: 44, child: Center(child: icon)),
        ),
      );
    }
    final row = Row(
      children: [
        const SizedBox(width: 16),
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (entry.count != null) Text('${entry.count}'),
        const SizedBox(width: 16),
      ],
    );
    if (cupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        color: background,
        onPressed: onPressed,
        child: SizedBox(width: double.infinity, child: row),
      );
    }
    return InkWell(
      onTap: onPressed,
      child: ColoredBox(
        color: background ?? const Color(0x00000000),
        child: SizedBox(height: 40, child: row),
      ),
    );
  }
}

class _ReminderSummary extends StatelessWidget {
  const _ReminderSummary();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _SummaryChip(label: '3 due')),
              SizedBox(width: 8),
              Expanded(child: _SummaryChip(label: '1 flagged')),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x14007AFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _CollapsedSummary extends StatelessWidget {
  const _CollapsedSummary({required this.cupertino});

  final bool cupertino;

  @override
  Widget build(BuildContext context) {
    final icons = cupertino
        ? const [CupertinoIcons.calendar, CupertinoIcons.flag]
        : const [Icons.calendar_today_outlined, Icons.flag_outlined];
    return Column(
      children: [
        for (final icon in icons)
          SizedBox(height: 32, child: Center(child: Icon(icon, size: 18))),
      ],
    );
  }
}

class _HomeList extends StatelessWidget {
  const _HomeList({required this.style, required this.itemCount});

  final _SidebarStyle style;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey('home-list'),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final title = 'Item $index';
        if (style == _SidebarStyle.cupertino) {
          return CupertinoListTile(title: Text(title));
        }
        return ListTile(title: Text(title));
      },
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.style,
    required this.settings,
    required this.onPreferredWidthChanged,
    required this.onMinimumWidthChanged,
    required this.onMaximumWidthChanged,
    required this.onCollapsedExtentChanged,
    required this.onAutomaticExpandedWidthChanged,
    required this.onCustomDragHandleChanged,
    required this.onCustomTooltipChanged,
    required this.onCustomLabelsChanged,
    required this.onCustomContentChanged,
  });

  final _SidebarStyle style;
  final _SettingsValues settings;
  final ValueChanged<double> onPreferredWidthChanged;
  final ValueChanged<double> onMinimumWidthChanged;
  final ValueChanged<double> onMaximumWidthChanged;
  final ValueChanged<double> onCollapsedExtentChanged;
  final ValueChanged<double> onAutomaticExpandedWidthChanged;
  final ValueChanged<bool> onCustomDragHandleChanged;
  final ValueChanged<bool> onCustomTooltipChanged;
  final ValueChanged<bool> onCustomLabelsChanged;
  final ValueChanged<bool> onCustomContentChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('sidebar-settings'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _WidthControl(
          style: style,
          label: 'Preferred width',
          value: settings.preferredWidth,
          min: settings.minimumWidth,
          max: settings.maximumWidth,
          onChanged: onPreferredWidthChanged,
        ),
        _WidthControl(
          style: style,
          label: 'Minimum width',
          value: settings.minimumWidth,
          min: 120,
          max: settings.maximumWidth,
          onChanged: onMinimumWidthChanged,
        ),
        _WidthControl(
          style: style,
          label: 'Maximum width',
          value: settings.maximumWidth,
          min: settings.minimumWidth,
          max: 480,
          onChanged: onMaximumWidthChanged,
        ),
        _WidthControl(
          style: style,
          label: 'Collapsed rail width',
          value: settings.collapsedExtent,
          min: 72,
          max: 140,
          onChanged: onCollapsedExtentChanged,
        ),
        _WidthControl(
          style: style,
          label: 'Auto width',
          value: settings.automaticExpandedWidth,
          min: 480,
          max: 1400,
          onChanged: onAutomaticExpandedWidthChanged,
        ),
        _SwitchControl(
          style: style,
          label: 'Custom resize handle',
          value: settings.customDragHandle,
          onChanged: onCustomDragHandleChanged,
        ),
        _SwitchControl(
          style: style,
          label: 'Custom tooltip',
          value: settings.customTooltip,
          onChanged: onCustomTooltipChanged,
        ),
        _SwitchControl(
          style: style,
          label: 'Custom show and hide labels',
          value: settings.customLabels,
          onChanged: onCustomLabelsChanged,
        ),
        _SwitchControl(
          style: style,
          label: 'Custom sidebar content',
          value: settings.customContent,
          onChanged: onCustomContentChanged,
        ),
      ],
    );
  }
}

class _WidthControl extends StatelessWidget {
  const _WidthControl({
    required this.style,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final _SidebarStyle style;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final rounded = value.round().toString();
    final sliderValue = value.clamp(min, max);
    if (style == _SidebarStyle.cupertino) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label  $rounded'),
            CupertinoSlider(
              value: sliderValue,
              min: min,
              max: max,
              onChanged: min >= max ? null : onChanged,
            ),
          ],
        ),
      );
    }
    return ListTile(
      title: Text(label),
      subtitle: Slider(
        value: sliderValue,
        min: min,
        max: max,
        label: rounded,
        onChanged: min >= max ? null : onChanged,
      ),
      trailing: Text(rounded),
    );
  }
}

class _SwitchControl extends StatelessWidget {
  const _SwitchControl({
    required this.style,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final _SidebarStyle style;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (style == _SidebarStyle.cupertino) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            CupertinoSwitch(value: value, onChanged: onChanged),
          ],
        ),
      );
    }
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
