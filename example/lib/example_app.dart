part of 'main.dart';

/// Example host for the Material and Cupertino sidebars.
class AdaptiveSidebarExampleApp extends StatefulWidget {
  /// Creates the example app.
  ///
  /// [cupertino] forces a sidebar style. When it is null, iOS and macOS use
  /// the Cupertino sidebar and every other platform uses Material.
  const AdaptiveSidebarExampleApp({super.key, this.cupertino});

  /// Forces the Cupertino sidebar when true, and Material when false.
  final bool? cupertino;

  @override
  State<AdaptiveSidebarExampleApp> createState() =>
      _AdaptiveSidebarExampleAppState();
}

class _AdaptiveSidebarExampleAppState extends State<AdaptiveSidebarExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;
  ExampleThemeColor _themeColor = ExampleThemeColor.system;

  ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _themeColor.color,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: _themeColor.color,
      ),
      extensions: [
        CupertinoSidebarThemeData(
          edgeBackgroundColor: _themeColor == ExampleThemeColor.system
              ? null
              : colorScheme.surfaceContainer,
        ),
      ],
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
          cupertino: widget.cupertino,
          themeMode: _themeMode,
          themeColor: _themeColor,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
          onThemeColorChanged: (color) => setState(() => _themeColor = color),
        ),
      ),
    );
  }
}

enum _SidebarStyle { material, cupertino }

enum _ExpansionMode { automatic, collapsed, expanded }

enum _CollapsedBarTransition { drop, fade }

enum _ToolbarTopInsetMode { automatic, unified, custom }

/// Theme colors demonstrated by the Cupertino sidebar example.
enum ExampleThemeColor {
  system('Default', CupertinoColors.systemBlue),
  purple('Purple', CupertinoColors.systemPurple),
  teal('Teal', CupertinoColors.systemTeal),
  orange('Orange', CupertinoColors.systemOrange);

  const ExampleThemeColor(this.label, this.color);

  final String label;
  final Color color;

  ExampleThemeColor get next => values[(index + 1) % values.length];
}

PreferredSizeWidget? _navigationBarBottomFor(
  CupertinoSidebarToolbarGeometry geometry,
) {
  final height = geometry.height - geometry.contentHeight;
  return height == 0
      ? null
      : PreferredSize(
          preferredSize: Size.fromHeight(height),
          child: const SizedBox.shrink(),
        );
}

const CupertinoSidebarItemStyle _kCustomSideItemStyle =
    CupertinoSidebarItemStyle(
      selectedColor: Color(0xFF6A1B9A),
      selectedForegroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF4A148C),
      labelStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
        height: 1.1,
      ),
    );

const MaterialSidebarItemStyle _kCustomMaterialItemStyle =
    MaterialSidebarItemStyle(
      selectedColor: Color(0xFF6A1B9A),
      selectedForegroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF4A148C),
      labelStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.2,
        height: 1.1,
      ),
    );

const CupertinoSidebarItemStyle _kCustomBarItemStyle =
    CupertinoSidebarItemStyle(
      selectedColor: Color(0xFFE65100),
      selectedForegroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFFBF360C),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        height: 1.1,
      ),
    );

_SidebarStyle _platformSidebarStyle() {
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS => _SidebarStyle.cupertino,
    _ => _SidebarStyle.material,
  };
}

class _ExampleBackground extends StatelessWidget {
  const _ExampleBackground({required this.themeColor, required this.child});

  final ExampleThemeColor themeColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (themeColor == ExampleThemeColor.system) {
      return DecoratedBox(
        key: const ValueKey('example-background'),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.systemBackground,
            context,
          ),
        ),
        child: child,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    return DecoratedBox(
      key: const ValueKey('example-background'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.alphaBlend(
              colorScheme.primary.withValues(alpha: 0.05),
              surface,
            ),
            Color.alphaBlend(
              colorScheme.primary.withValues(alpha: 0.12),
              surface,
            ),
          ],
        ),
      ),
      child: child,
    );
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
    required this.customFocusHalo,
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
  final bool customFocusHalo;
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
    required this.themeColor,
    required this.textDirection,
    required this.settings,
    required this.toolbarGeometry,
    required this.toolbarTopInsetMode,
    required this.customToolbarTopInset,
    required this.onToolbarTopInsetModeChanged,
    required this.onCustomToolbarTopInsetChanged,
    required this.onToggleStyle,
    required this.onToggleDirection,
    required this.onModeChanged,
    required this.onThemeModeChanged,
    required this.onThemeColorChanged,
    required this.onPreferredWidthChanged,
    required this.onMinimumWidthChanged,
    required this.onMaximumWidthChanged,
    required this.onCollapsedExtentChanged,
    required this.onAutomaticExpandedWidthChanged,
    required this.onCustomDragHandleChanged,
    required this.onCustomTooltipChanged,
    required this.onCustomLabelsChanged,
    required this.onCustomContentChanged,
    required this.onCustomFocusHaloChanged,
    required this.customSideStyle,
    required this.onCustomSideStyleChanged,
    required this.customBarStyle,
    required this.onCustomBarStyleChanged,
    required this.collapsedBarTransition,
    required this.onCollapsedBarTransitionChanged,
    required this.collapsedBarPlacement,
    required this.onCollapsedBarPlacementChanged,
    required this.onOpenPlacementDemo,
    required this.collapsedBarSeparator,
    required this.onCollapsedBarSeparatorChanged,
    required this.collapsedBarIcons,
    required this.onCollapsedBarIconsChanged,
    required this.cupertinoStyle,
    required this.onCupertinoStyleChanged,
  });

  final _SidebarStyle style;
  final _ExpansionMode mode;
  final int selectedIndex;
  final bool settingsSelected;
  final String? customPageTitle;
  final int itemCount;
  final ThemeMode themeMode;
  final ExampleThemeColor themeColor;
  final TextDirection textDirection;
  final _SettingsValues settings;
  final CupertinoSidebarToolbarGeometry toolbarGeometry;
  final _ToolbarTopInsetMode toolbarTopInsetMode;
  final double customToolbarTopInset;
  final ValueChanged<_ToolbarTopInsetMode> onToolbarTopInsetModeChanged;
  final ValueChanged<double> onCustomToolbarTopInsetChanged;
  final VoidCallback onToggleStyle;
  final VoidCallback onToggleDirection;
  final ValueChanged<_ExpansionMode> onModeChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<ExampleThemeColor> onThemeColorChanged;
  final ValueChanged<double> onPreferredWidthChanged;
  final ValueChanged<double> onMinimumWidthChanged;
  final ValueChanged<double> onMaximumWidthChanged;
  final ValueChanged<double> onCollapsedExtentChanged;
  final ValueChanged<double> onAutomaticExpandedWidthChanged;
  final ValueChanged<bool> onCustomDragHandleChanged;
  final ValueChanged<bool> onCustomTooltipChanged;
  final ValueChanged<bool> onCustomLabelsChanged;
  final ValueChanged<bool> onCustomContentChanged;
  final ValueChanged<bool> onCustomFocusHaloChanged;
  final bool customSideStyle;
  final ValueChanged<bool> onCustomSideStyleChanged;
  final bool customBarStyle;
  final ValueChanged<bool> onCustomBarStyleChanged;
  final _CollapsedBarTransition collapsedBarTransition;
  final ValueChanged<_CollapsedBarTransition> onCollapsedBarTransitionChanged;
  final CupertinoSidebarCollapsedBarPlacement collapsedBarPlacement;
  final ValueChanged<CupertinoSidebarCollapsedBarPlacement>
  onCollapsedBarPlacementChanged;
  final VoidCallback onOpenPlacementDemo;
  final bool collapsedBarSeparator;
  final ValueChanged<bool> onCollapsedBarSeparatorChanged;
  final bool collapsedBarIcons;
  final ValueChanged<bool> onCollapsedBarIconsChanged;
  final CupertinoSidebarStyle cupertinoStyle;
  final ValueChanged<CupertinoSidebarStyle> onCupertinoStyleChanged;

  @override
  Widget build(BuildContext context) {
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
    final pageSlivers = _pageSlivers();
    if (style == _SidebarStyle.cupertino) {
      final reserved =
          SidebarLeadingScope.maybeOf(context)?.reservedExtent ?? 0;
      final cupertinoText = CupertinoTheme.of(context).textTheme.textStyle;
      return DefaultTextStyle(
        style: cupertinoText,
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            // Keep the fill clear so the example gradient remains visible
            // through the navigation bar's backdrop blur.
            backgroundColor: CupertinoTheme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: 0),
            automaticBackgroundVisibility: true,
            enableBackgroundFilterBlur: true,
            border: null,
            bottom: _navigationBarBottomFor(toolbarGeometry),
            automaticallyImplyLeading: false,
            leading: reserved == 0 ? null : SizedBox(width: reserved),
            // The sliver bar adds a second, large title in portrait. This
            // static bar keeps a single small title on every size.
            transitionBetweenRoutes: false,
            middle: _ExampleNavMiddle(showBar: !settings.customContent),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GlassStyleButton(
                  style: cupertinoStyle,
                  onPressed: () => onCupertinoStyleChanged(
                    cupertinoStyle == CupertinoSidebarStyle.liquid
                        ? CupertinoSidebarStyle.liquidEdge
                        : CupertinoSidebarStyle.liquid,
                  ),
                ),
                _ThemeColorButton(
                  color: themeColor,
                  onChanged: onThemeColorChanged,
                ),
                CupertinoButton(
                  key: const ValueKey('style-button'),
                  padding: EdgeInsets.zero,
                  onPressed: onToggleStyle,
                  child: const Icon(CupertinoIcons.device_phone_portrait),
                ),
                appearance,
                direction,
              ],
            ),
          ),
          child: Builder(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top,
                    ),
                    sliver: SliverMainAxisGroup(slivers: pageSlivers),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            title: const Text('Adaptive sidebar'),
            actions: [
              IconButton(
                key: const ValueKey('style-button'),
                tooltip: 'Use Cupertino',
                onPressed: onToggleStyle,
                icon: const Icon(Icons.phone_iphone),
              ),
              appearance,
              direction,
            ],
          ),
          ...pageSlivers,
        ],
      ),
    );
  }

  List<Widget> _pageSlivers() {
    if (settingsSelected) {
      return [
        _SettingsPage(
          style: style,
          settings: settings,
          mode: mode,
          onModeChanged: onModeChanged,
          toolbarTopInsetMode: toolbarTopInsetMode,
          customToolbarTopInset: customToolbarTopInset,
          onToolbarTopInsetModeChanged: onToolbarTopInsetModeChanged,
          onCustomToolbarTopInsetChanged: onCustomToolbarTopInsetChanged,
          collapsedBarTransition: collapsedBarTransition,
          onCollapsedBarTransitionChanged: onCollapsedBarTransitionChanged,
          collapsedBarPlacement: collapsedBarPlacement,
          onCollapsedBarPlacementChanged: onCollapsedBarPlacementChanged,
          onOpenPlacementDemo: onOpenPlacementDemo,
          collapsedBarSeparator: collapsedBarSeparator,
          onCollapsedBarSeparatorChanged: onCollapsedBarSeparatorChanged,
          collapsedBarIcons: collapsedBarIcons,
          onCollapsedBarIconsChanged: onCollapsedBarIconsChanged,
          onPreferredWidthChanged: onPreferredWidthChanged,
          onMinimumWidthChanged: onMinimumWidthChanged,
          onMaximumWidthChanged: onMaximumWidthChanged,
          onCollapsedExtentChanged: onCollapsedExtentChanged,
          onAutomaticExpandedWidthChanged: onAutomaticExpandedWidthChanged,
          onCustomDragHandleChanged: onCustomDragHandleChanged,
          onCustomTooltipChanged: onCustomTooltipChanged,
          onCustomLabelsChanged: onCustomLabelsChanged,
          onCustomContentChanged: onCustomContentChanged,
          onCustomFocusHaloChanged: onCustomFocusHaloChanged,
          customSideStyle: customSideStyle,
          onCustomSideStyleChanged: onCustomSideStyleChanged,
          customBarStyle: customBarStyle,
          onCustomBarStyleChanged: onCustomBarStyleChanged,
        ),
      ];
    }
    final customPageTitle = this.customPageTitle;
    if (customPageTitle != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text(customPageTitle)),
        ),
      ];
    }
    return [
      switch (selectedIndex) {
        0 => _HomeList(style: style, itemCount: itemCount),
        _ => const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Search')),
        ),
      },
    ];
  }
}

class _ThemeColorButton extends StatelessWidget {
  const _ThemeColorButton({required this.color, required this.onChanged});

  final ExampleThemeColor color;
  final ValueChanged<ExampleThemeColor> onChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = CupertinoDynamicColor.resolve(color.color, context);
    return Semantics(
      label: 'Theme color: ${color.label}',
      button: true,
      child: CupertinoButton(
        key: const ValueKey('theme-color-button'),
        padding: EdgeInsets.zero,
        onPressed: () => onChanged(color.next),
        child: Icon(CupertinoIcons.circle_fill, color: resolvedColor),
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

class _TransitionControls extends StatelessWidget {
  const _TransitionControls({
    required this.transition,
    required this.onChanged,
  });

  final _CollapsedBarTransition transition;
  final ValueChanged<_CollapsedBarTransition> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bar animation'),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<_CollapsedBarTransition>(
            groupValue: transition,
            children: const {
              _CollapsedBarTransition.drop: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Drop'),
              ),
              _CollapsedBarTransition.fade: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Fade'),
              ),
            },
            onValueChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _PlacementControls extends StatelessWidget {
  const _PlacementControls({
    required this.placement,
    required this.onChanged,
    required this.onOpenDemo,
  });

  final CupertinoSidebarCollapsedBarPlacement placement;
  final ValueChanged<CupertinoSidebarCollapsedBarPlacement> onChanged;
  final VoidCallback onOpenDemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('collapsed-bar-placement-control'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bar placement'),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<
            CupertinoSidebarCollapsedBarPlacement
          >(
            groupValue: placement,
            children: const {
              CupertinoSidebarCollapsedBarPlacement.toolbarAnchor: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Toolbar anchor'),
              ),
              CupertinoSidebarCollapsedBarPlacement.fixedToolbar: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Fixed toolbar'),
              ),
            },
            onValueChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Push the demo page to compare a route-owned anchor with a bar '
            'fixed to the shell toolbar.',
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            key: const ValueKey('collapsed-bar-placement-demo-button'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: onOpenDemo,
            child: const Text('Push demo page'),
          ),
        ],
      ),
    );
  }
}

class _PlacementDemoRoutePage extends Page<void> {
  const _PlacementDemoRoutePage({required this.child, super.key});

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) {
    return _PlacementDemoPageRoute(page: this);
  }
}

class _PlacementDemoPageRoute extends PageRoute<void> {
  _PlacementDemoPageRoute({required _PlacementDemoRoutePage page})
    : super(settings: page);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 350);

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return (settings as _PlacementDemoRoutePage).child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final incoming = Tween(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(animation);
    final outgoing = Tween(
      begin: Offset.zero,
      end: const Offset(-0.25, 0),
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(secondaryAnimation);
    return SlideTransition(
      position: outgoing,
      child: SlideTransition(position: incoming, child: child),
    );
  }
}

class _PlacementDemoPage extends StatelessWidget {
  const _PlacementDemoPage({
    required this.placement,
    required this.toolbarGeometry,
  });

  final CupertinoSidebarCollapsedBarPlacement placement;
  final CupertinoSidebarToolbarGeometry toolbarGeometry;

  @override
  Widget build(BuildContext context) {
    final placementName = switch (placement) {
      CupertinoSidebarCollapsedBarPlacement.toolbarAnchor => 'Toolbar anchor',
      CupertinoSidebarCollapsedBarPlacement.fixedToolbar => 'Fixed toolbar',
    };
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0),
        automaticBackgroundVisibility: true,
        enableBackgroundFilterBlur: true,
        border: null,
        bottom: _navigationBarBottomFor(toolbarGeometry),
        previousPageTitle: 'Settings',
        transitionBetweenRoutes: false,
        middle: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            'Pushed page',
            key: ValueKey('collapsed-bar-placement-demo-title'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      child: SafeArea(
        child: DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '$placementName is active.\n\n'
                'The anchored bar follows the previous page during the route '
                'transition; the fixed bar stays in the shell toolbar.',
                key: const ValueKey('collapsed-bar-placement-demo-description'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExampleNavMiddle extends StatelessWidget {
  const _ExampleNavMiddle({required this.showBar});

  final bool showBar;

  @override
  Widget build(BuildContext context) {
    const title = Text(
      'Adaptive sidebar',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    if (!showBar) {
      return const Align(
        alignment: AlignmentDirectional.centerStart,
        child: title,
      );
    }
    return _TitleBesideCenteredBar(
      title: title,
      bar: const CupertinoSidebarMiddle(title: SizedBox.shrink()),
    );
  }
}

class _TitleBesideCenteredBar extends MultiChildRenderObjectWidget {
  _TitleBesideCenteredBar({required Widget title, required Widget bar})
    : super(children: [title, bar]);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTitleBesideCenteredBar(
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTitleBesideCenteredBar renderObject,
  ) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _TitleBarParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderTitleBesideCenteredBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TitleBarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TitleBarParentData> {
  _RenderTitleBesideCenteredBar({required this._textDirection});

  TextDirection _textDirection;

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TitleBarParentData) {
      child.parentData = _TitleBarParentData();
    }
  }

  double _usedOrigin = double.nan;

  /// Navigation toolbar that owns this middle slot, if it has been laid out.
  RenderBox? _toolbarBox() {
    var node = parent;
    while (node != null) {
      if (node is RenderCustomMultiChildLayoutBox && node.hasSize) {
        return node;
      }
      node = node.parent;
    }
    return null;
  }

  void _scheduleOriginSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!attached || !hasSize) return;
      final toolbar = _toolbarBox();
      if (toolbar == null) return;
      final origin = toolbar.globalToLocal(localToGlobal(Offset.zero)).dx;
      if ((_usedOrigin - origin).abs() < 0.5) return;
      _usedOrigin = origin;
      markNeedsLayout();
    });
  }

  @override
  void performLayout() {
    final title = firstChild!;
    final bar = childAfter(title)!;
    final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
    final height = constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
    size = Size(maxWidth, height);

    // Loose width lets the capsule keep its own width. A tight width would
    // shrink it to make room for the title.
    bar.layout(
      BoxConstraints(maxWidth: maxWidth, maxHeight: height),
      parentUsesSize: true,
    );
    final barWidth = math.min(bar.size.width, maxWidth);
    final toolbar = _toolbarBox();
    final origin = _usedOrigin.isNaN ? 0.0 : _usedOrigin;
    final toolbarWidth = toolbar?.size.width ?? maxWidth;
    final centeredLeft = (toolbarWidth - barWidth) / 2 - origin;
    final barLeft = centeredLeft
        .clamp(0.0, math.max(0.0, maxWidth - barWidth))
        .toDouble();
    final titleMax = math.max(
      0.0,
      _textDirection == TextDirection.ltr
          ? barLeft
          : maxWidth - barLeft - barWidth,
    );
    title.layout(
      BoxConstraints(maxWidth: titleMax, maxHeight: height),
      parentUsesSize: true,
    );

    final titleParent = title.parentData! as _TitleBarParentData;
    final barParent = bar.parentData! as _TitleBarParentData;
    titleParent.offset = Offset(
      _textDirection == TextDirection.ltr ? 0 : maxWidth - title.size.width,
      (height - title.size.height) / 2,
    );
    barParent.offset = Offset(barLeft, (height - bar.size.height) / 2);
    _scheduleOriginSync();
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

class _GlassStyleButton extends StatelessWidget {
  const _GlassStyleButton({required this.style, required this.onPressed});

  final CupertinoSidebarStyle style;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final edge = style == CupertinoSidebarStyle.liquidEdge;
    return CupertinoButton(
      key: const ValueKey('glass-style-button'),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Text(edge ? 'Edge' : 'Liquid'),
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
    final control = style == _SidebarStyle.cupertino
        ? CupertinoSlidingSegmentedControl<_ExpansionMode>(
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
          )
        : SegmentedButton<_ExpansionMode>(
            segments: [
              for (final entry in labels.entries)
                ButtonSegment(value: entry.key, label: Text(entry.value)),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onChanged(selection.first),
          );
    return Padding(
      key: const ValueKey('expansion-control'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text('Expansion'), const SizedBox(height: 8), control],
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
    this.itemStyle,
    this.materialItemStyle,
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
  final CupertinoSidebarItemStyle? itemStyle;
  final MaterialSidebarItemStyle? materialItemStyle;

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
              key: ValueKey('custom-sidebar-destination-$index'),
              destination: destination,
              itemStyle: materialItemStyle,
              selected:
                  selectedLabel == null &&
                  !settingsSelected &&
                  selectedIndex == index,
              onPressed: () => onDestinationSelected(index),
            ),
          _MaterialNoteButton(
            animation: animation,
            selected: selectedLabel == 'Note',
            itemStyle: materialItemStyle,
            onPressed: () => onLabelSelected('Note'),
          ),
          MaterialWideNavigationRailButton(
            key: const ValueKey('custom-sidebar-settings'),
            destination: settingsDestination,
            itemStyle: materialItemStyle,
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
    final theme = CupertinoTheme.of(context);
    final primary = theme.primaryColor;
    final noteSelected = selectedLabel == 'Note';
    final noteFilled =
        noteSelected && CupertinoSidebar.filledSelectionOf(context);
    final noteColor = !noteSelected
        ? null
        : CupertinoSidebarItemStyle.selectedColorOf(
            itemStyle,
            noteFilled ? primary : primary.withValues(alpha: 0.14),
          );
    final noteForeground = CupertinoSidebarItemStyle.foregroundOf(
      itemStyle,
      selected: noteSelected,
      selectedFallback: noteFilled ? theme.primaryContrastingColor : primary,
      unselectedFallback: primary,
    );
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
            itemStyle: itemStyle,
            selected:
                selectedLabel == null &&
                !settingsSelected &&
                selectedIndex == index,
            onPressed: () => onDestinationSelected(index),
          ),
        Padding(
          key: const ValueKey('custom-sidebar-note'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: _CupertinoCapsuleButton(
            color: noteColor,
            foregroundColor: noteForeground,
            labelStyle: itemStyle?.labelStyle,
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
          itemStyle: itemStyle,
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
    this.itemStyle,
  });

  final Animation<double> animation;
  final bool selected;
  final VoidCallback onPressed;
  final MaterialSidebarItemStyle? itemStyle;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    final iconColor = MaterialSidebarItemStyle.foregroundOf(
      itemStyle,
      selected: selected,
      selectedFallback: Theme.of(context).colorScheme.primary,
      unselectedFallback: color ?? Theme.of(context).colorScheme.onSurface,
    );
    final labelStyle = MaterialSidebarItemStyle.labelStyleOf(
      itemStyle,
      fallback: Theme.of(context).textTheme.labelLarge ?? const TextStyle(),
      color: iconColor,
    );
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
                  Text('Note', style: labelStyle),
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

class _CupertinoCapsuleButton extends StatefulWidget {
  const _CupertinoCapsuleButton({
    required this.color,
    required this.foregroundColor,
    required this.onPressed,
    required this.child,
    this.labelStyle,
  });

  final Color? color;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final Widget child;
  final TextStyle? labelStyle;

  @override
  State<_CupertinoCapsuleButton> createState() =>
      _CupertinoCapsuleButtonState();
}

class _CupertinoCapsuleButtonState extends State<_CupertinoCapsuleButton> {
  static const double _height = 44;

  bool _held = false;
  bool _showFocusHighlight = false;

  void _hold(bool value) {
    if (_held == value) {
      return;
    }
    setState(() => _held = value);
  }

  void _handleShowFocusHighlight(bool value) {
    if (_showFocusHighlight == value) return;
    setState(() => _showFocusHighlight = value);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _held
        ? widget.foregroundColor.withValues(alpha: 0.4)
        : widget.foregroundColor;
    final textStyle = CupertinoTheme.of(context).textTheme.actionTextStyle
        .merge(widget.labelStyle)
        .copyWith(color: foreground);
    final focusColor = CupertinoTheme.of(
      context,
    ).primaryColor.withValues(alpha: 0.8);
    return Semantics(
      button: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: _handleShowFocusHighlight,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          onLongPressStart: (_) => _hold(true),
          onLongPressEnd: (_) => _hold(false),
          onLongPressCancel: () => _hold(false),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              border: _showFocusHighlight
                  ? Border.all(color: focusColor, width: 3)
                  : null,
              borderRadius: BorderRadius.circular(_height / 2),
            ),
            child: SizedBox(
              height: _height,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
                child: IconTheme(
                  data: IconThemeData(
                    color: foreground,
                    size: (textStyle.fontSize ?? 17) * 1.2,
                  ),
                  child: DefaultTextStyle(
                    style: textStyle,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
    if (cupertino) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: _CupertinoCapsuleButton(
          color: background,
          foregroundColor: CupertinoDynamicColor.resolve(
            CupertinoColors.label,
            context,
          ),
          onPressed: onPressed,
          child: Row(
            children: [
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
            ],
          ),
        ),
      );
    }
    return InkWell(
      onTap: onPressed,
      child: ColoredBox(
        color: background ?? const Color(0x00000000),
        child: SizedBox(
          height: 40,
          child: Row(
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
          ),
        ),
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

const List<Color> _homeItemColors = <Color>[
  Color(0xFFFFE08A),
  Color(0xFFB7E4C7),
  Color(0xFFA9D6E5),
  Color(0xFFF4C2C2),
  Color(0xFFD4C4FB),
];

class _HomeList extends StatelessWidget {
  const _HomeList({required this.style, required this.itemCount});

  final _SidebarStyle style;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      key: const ValueKey('home-list'),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final title = 'Item $index';
        final detail =
            'The quick brown fox jumps over the lazy dog. '
            'This longer row is here so color and text can be seen sliding '
            'under the bar.';
        final color = index % 6 == 0
            ? _homeItemColors[(index ~/ 6) % _homeItemColors.length]
            : null;
        if (style == _SidebarStyle.cupertino) {
          return CupertinoListTile(
            backgroundColor: color,
            title: Text(title),
            subtitle: Text(detail),
          );
        }
        return ListTile(
          tileColor: color,
          title: Text(title),
          subtitle: Text(detail),
        );
      },
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.style,
    required this.settings,
    required this.mode,
    required this.onModeChanged,
    required this.toolbarTopInsetMode,
    required this.customToolbarTopInset,
    required this.onToolbarTopInsetModeChanged,
    required this.onCustomToolbarTopInsetChanged,
    required this.collapsedBarTransition,
    required this.onCollapsedBarTransitionChanged,
    required this.collapsedBarPlacement,
    required this.onCollapsedBarPlacementChanged,
    required this.onOpenPlacementDemo,
    required this.collapsedBarSeparator,
    required this.onCollapsedBarSeparatorChanged,
    required this.collapsedBarIcons,
    required this.onCollapsedBarIconsChanged,
    required this.onPreferredWidthChanged,
    required this.onMinimumWidthChanged,
    required this.onMaximumWidthChanged,
    required this.onCollapsedExtentChanged,
    required this.onAutomaticExpandedWidthChanged,
    required this.onCustomDragHandleChanged,
    required this.onCustomTooltipChanged,
    required this.onCustomLabelsChanged,
    required this.onCustomContentChanged,
    required this.onCustomFocusHaloChanged,
    required this.customSideStyle,
    required this.onCustomSideStyleChanged,
    required this.customBarStyle,
    required this.onCustomBarStyleChanged,
  });

  final _SidebarStyle style;
  final _SettingsValues settings;
  final _ExpansionMode mode;
  final ValueChanged<_ExpansionMode> onModeChanged;
  final _ToolbarTopInsetMode toolbarTopInsetMode;
  final double customToolbarTopInset;
  final ValueChanged<_ToolbarTopInsetMode> onToolbarTopInsetModeChanged;
  final ValueChanged<double> onCustomToolbarTopInsetChanged;
  final _CollapsedBarTransition collapsedBarTransition;
  final ValueChanged<_CollapsedBarTransition> onCollapsedBarTransitionChanged;
  final CupertinoSidebarCollapsedBarPlacement collapsedBarPlacement;
  final ValueChanged<CupertinoSidebarCollapsedBarPlacement>
  onCollapsedBarPlacementChanged;
  final VoidCallback onOpenPlacementDemo;
  final bool collapsedBarSeparator;
  final ValueChanged<bool> onCollapsedBarSeparatorChanged;
  final bool collapsedBarIcons;
  final ValueChanged<bool> onCollapsedBarIconsChanged;
  final ValueChanged<double> onPreferredWidthChanged;
  final ValueChanged<double> onMinimumWidthChanged;
  final ValueChanged<double> onMaximumWidthChanged;
  final ValueChanged<double> onCollapsedExtentChanged;
  final ValueChanged<double> onAutomaticExpandedWidthChanged;
  final ValueChanged<bool> onCustomDragHandleChanged;
  final ValueChanged<bool> onCustomTooltipChanged;
  final ValueChanged<bool> onCustomLabelsChanged;
  final ValueChanged<bool> onCustomContentChanged;
  final ValueChanged<bool> onCustomFocusHaloChanged;
  final bool customSideStyle;
  final ValueChanged<bool> onCustomSideStyleChanged;
  final bool customBarStyle;
  final ValueChanged<bool> onCustomBarStyleChanged;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      key: const ValueKey('sidebar-settings'),
      delegate: SliverChildListDelegate([
        _ExpansionControls(style: style, mode: mode, onChanged: onModeChanged),
        if (style == _SidebarStyle.cupertino) ...[
          _ToolbarTopInsetControls(
            mode: toolbarTopInsetMode,
            customTopInset: customToolbarTopInset,
            onModeChanged: onToolbarTopInsetModeChanged,
            onCustomTopInsetChanged: onCustomToolbarTopInsetChanged,
          ),
          _TransitionControls(
            transition: collapsedBarTransition,
            onChanged: onCollapsedBarTransitionChanged,
          ),
          _PlacementControls(
            placement: collapsedBarPlacement,
            onChanged: onCollapsedBarPlacementChanged,
            onOpenDemo: onOpenPlacementDemo,
          ),
          _SwitchControl(
            style: style,
            label: 'Bar separator',
            value: collapsedBarSeparator,
            onChanged: onCollapsedBarSeparatorChanged,
          ),
          _SwitchControl(
            style: style,
            label: 'Bar icons',
            value: collapsedBarIcons,
            onChanged: onCollapsedBarIconsChanged,
          ),
          _SwitchControl(
            style: style,
            label: 'Custom bar style',
            value: customBarStyle,
            onChanged: onCustomBarStyleChanged,
          ),
          _SwitchControl(
            style: style,
            label: 'Custom focus halo',
            value: settings.customFocusHalo,
            onChanged: onCustomFocusHaloChanged,
          ),
        ],
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
        _SwitchControl(
          style: style,
          label: 'Custom side style',
          value: customSideStyle,
          onChanged: onCustomSideStyleChanged,
        ),
      ]),
    );
  }
}

class _ToolbarTopInsetControls extends StatelessWidget {
  const _ToolbarTopInsetControls({
    required this.mode,
    required this.customTopInset,
    required this.onModeChanged,
    required this.onCustomTopInsetChanged,
  });

  final _ToolbarTopInsetMode mode;
  final double customTopInset;
  final ValueChanged<_ToolbarTopInsetMode> onModeChanged;
  final ValueChanged<double> onCustomTopInsetChanged;

  @override
  Widget build(BuildContext context) {
    // viewPadding keeps the window safe area visible even when an ancestor
    // SafeArea has already consumed MediaQuery.padding.
    final safeAreaTop = MediaQuery.viewPaddingOf(context).top;
    return Padding(
      key: const ValueKey('toolbar-top-inset-control'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Minimum top inset'),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl<_ToolbarTopInsetMode>(
            groupValue: mode,
            children: const {
              _ToolbarTopInsetMode.automatic: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Auto'),
              ),
              _ToolbarTopInsetMode.unified: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Unified'),
              ),
              _ToolbarTopInsetMode.custom: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Custom'),
              ),
            },
            onValueChanged: (value) {
              if (value != null) onModeChanged(value);
            },
          ),
          if (mode == _ToolbarTopInsetMode.custom) ...[
            const SizedBox(height: 8),
            Text(
              'Configured ${customTopInset.round()} · '
              'Safe area ${safeAreaTop.round()}',
            ),
            CupertinoSlider(
              key: const ValueKey('toolbar-top-inset-slider'),
              value: customTopInset,
              min: 0,
              max: 96,
              divisions: 96,
              onChanged: onCustomTopInsetChanged,
            ),
          ],
        ],
      ),
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
