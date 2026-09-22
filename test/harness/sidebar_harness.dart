import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

/// Home, Search, and Settings destinations shared by sidebar widget tests.
const sidebarDestinations = [
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
  AdaptiveNavigationDestination(
    label: 'Settings',
    icons: NavigationDestinationIcons(
      material: Icon(Icons.settings_outlined),
      materialSelected: Icon(Icons.settings),
      cupertino: Icon(CupertinoIcons.gear),
      cupertinoSelected: Icon(CupertinoIcons.gear_solid),
    ),
  ),
];

/// Auxiliary destination used by footer highlight tests.
const sidebarFooterDestination = AdaptiveNavigationDestination(
  label: 'Footer',
  icons: NavigationDestinationIcons(
    material: Icon(Icons.tune),
    materialSelected: Icon(Icons.tune),
    cupertino: Icon(CupertinoIcons.slider_horizontal_3),
    cupertinoSelected: Icon(CupertinoIcons.slider_horizontal_3),
  ),
);

/// Gives widget tests a wide window.
void useLargeTestWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Builds a Material or Cupertino sidebar around [controller].
Widget sidebarHost({
  required AdaptiveNavigationController controller,
  required bool cupertino,
  NavigationTooltipBuilder? tooltipBuilder,
  Color? backgroundColor,
  Widget? content,
  List<AdaptiveNavigationDestination> destinations = sidebarDestinations,
  List<AdaptiveNavigationDestination> auxiliaryDestinations = const [],
  int? selectedAuxiliaryIndex,
  ValueChanged<int>? onDestinationSelected,
  ValueChanged<int>? onAuxiliaryDestinationSelected,
}) {
  const body = Text('Body');
  final resolvedContent =
      content ??
      sidebarNavigation(
        controller: controller,
        cupertino: cupertino,
        destinations: destinations,
        auxiliaryDestinations: auxiliaryDestinations,
        selectedAuxiliaryIndex: selectedAuxiliaryIndex,
        onDestinationSelected: onDestinationSelected,
        onAuxiliaryDestinationSelected: onAuxiliaryDestinationSelected,
      );
  final sidebar = cupertino
      ? CupertinoSidebar(
          controller: controller,
          content: resolvedContent,
          tooltipBuilder: tooltipBuilder,
          backgroundColor: backgroundColor,
          child: body,
        )
      : Row(
          children: [
            MaterialSidebar(
              controller: controller,
              content: resolvedContent,
              tooltipBuilder: tooltipBuilder,
            ),
            const Expanded(child: body),
          ],
        );
  return CupertinoTheme(data: const CupertinoThemeData(), child: sidebar);
}

/// Navigation list used as the default sidebar content.
Widget sidebarNavigation({
  required AdaptiveNavigationController controller,
  required bool cupertino,
  List<AdaptiveNavigationDestination> destinations = sidebarDestinations,
  List<AdaptiveNavigationDestination> auxiliaryDestinations = const [],
  int? selectedAuxiliaryIndex,
  ValueChanged<int>? onDestinationSelected,
  ValueChanged<int>? onAuxiliaryDestinationSelected,
}) {
  final select = onDestinationSelected ?? controller.select;
  if (cupertino) {
    return CupertinoSidebarNavigation(
      destinations: destinations,
      selectedIndex: controller.selectedIndex,
      onDestinationSelected: select,
      auxiliaryDestinations: auxiliaryDestinations,
      selectedAuxiliaryIndex: selectedAuxiliaryIndex,
      onAuxiliaryDestinationSelected: onAuxiliaryDestinationSelected,
    );
  }
  return MaterialSidebarNavigation(
    destinations: destinations,
    selectedIndex: controller.selectedIndex,
    onDestinationSelected: select,
    auxiliaryDestinations: auxiliaryDestinations,
    selectedAuxiliaryIndex: selectedAuxiliaryIndex,
    onAuxiliaryDestinationSelected: onAuxiliaryDestinationSelected,
  );
}

/// Pumps [sidebarHost] inside a [MaterialApp].
Future<void> pumpSidebar(
  WidgetTester tester, {
  required AdaptiveNavigationController controller,
  required bool cupertino,
  bool disableAnimations = false,
  NavigationTooltipBuilder? tooltipBuilder,
  Color? backgroundColor,
  Widget? content,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: disableAnimations
                ? media.copyWith(disableAnimations: true)
                : media,
            child: sidebarHost(
              controller: controller,
              cupertino: cupertino,
              tooltipBuilder: tooltipBuilder,
              backgroundColor: backgroundColor,
              content: content,
            ),
          );
        },
      ),
    ),
  );
}

/// Whether the destination identified by [key] is selected.
bool destinationSelected(
  WidgetTester tester,
  String key, {
  required bool cupertino,
}) {
  final finder = find.byKey(ValueKey(key));
  if (cupertino) {
    return tester.widget<CupertinoSidebarDestination>(finder).selected;
  }
  return tester
      .widget<MaterialWideNavigationRailButton>(
        find.ancestor(
          of: finder,
          matching: find.byType(MaterialWideNavigationRailButton),
        ),
      )
      .selected;
}

/// Host that keeps auxiliary selection outside the navigation controller.
class SidebarFooterHost extends StatefulWidget {
  /// Creates a host for [controller].
  const SidebarFooterHost({
    super.key,
    required this.controller,
    required this.cupertino,
  });

  /// Sidebar state under test.
  final AdaptiveNavigationController controller;

  /// Whether the host builds a Cupertino sidebar.
  final bool cupertino;

  @override
  State<SidebarFooterHost> createState() => _SidebarFooterHostState();
}

class _SidebarFooterHostState extends State<SidebarFooterHost> {
  int? _auxiliaryIndex;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant SidebarFooterHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return sidebarHost(
      controller: widget.controller,
      cupertino: widget.cupertino,
      destinations: sidebarDestinations.sublist(0, 2),
      auxiliaryDestinations: const [sidebarFooterDestination],
      selectedAuxiliaryIndex: _auxiliaryIndex,
      onDestinationSelected: (index) {
        setState(() => _auxiliaryIndex = null);
        widget.controller.select(index);
      },
      onAuxiliaryDestinationSelected: (index) {
        setState(() => _auxiliaryIndex = index);
      },
    );
  }
}
