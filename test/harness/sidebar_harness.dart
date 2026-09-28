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
  CupertinoSidebarStyle cupertinoStyle = CupertinoSidebarStyle.liquid,
  NavigationTooltipBuilder? tooltipBuilder,
  Color? scaffoldBackgroundColor,
  Widget? content,
  Widget body = const Text('Body'),
  List<AdaptiveNavigationDestination> destinations = sidebarDestinations,
  List<AdaptiveNavigationDestination> auxiliaryDestinations = const [],
  ValueChanged<SidebarDestinationSelection>? onSelectionChanged,
}) {
  final resolvedContent =
      content ??
      sidebarNavigation(
        controller: controller,
        cupertino: cupertino,
        destinations: destinations,
        auxiliaryDestinations: auxiliaryDestinations,
        onSelectionChanged: onSelectionChanged,
      );
  final sidebar = cupertino
      ? switch (cupertinoStyle) {
          CupertinoSidebarStyle.liquid => CupertinoSidebar(
            controller: controller,
            content: resolvedContent,
            tooltipBuilder: tooltipBuilder,
            scaffoldBackgroundColor: scaffoldBackgroundColor,
            child: body,
          ),
          CupertinoSidebarStyle.liquidEdge => CupertinoSidebar.edge(
            controller: controller,
            content: resolvedContent,
            tooltipBuilder: tooltipBuilder,
            scaffoldBackgroundColor: scaffoldBackgroundColor,
            child: body,
          ),
        }
      : Row(
          children: [
            MaterialSidebar(
              controller: controller,
              content: resolvedContent,
              tooltipBuilder: tooltipBuilder,
            ),
            Expanded(child: body),
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
  ValueChanged<SidebarDestinationSelection>? onSelectionChanged,
}) {
  final select = onSelectionChanged ?? controller.select;
  if (cupertino) {
    return CupertinoSidebarNavigation(
      destinations: destinations,
      selection: controller.selection,
      onSelectionChanged: select,
      auxiliaryDestinations: auxiliaryDestinations,
    );
  }
  return MaterialSidebarNavigation(
    destinations: destinations,
    selection: controller.selection,
    onSelectionChanged: select,
    auxiliaryDestinations: auxiliaryDestinations,
  );
}

/// Pumps [sidebarHost] inside a [MaterialApp].
Future<void> pumpSidebar(
  WidgetTester tester, {
  required AdaptiveNavigationController controller,
  required bool cupertino,
  CupertinoSidebarStyle cupertinoStyle = CupertinoSidebarStyle.liquid,
  bool disableAnimations = false,
  NavigationTooltipBuilder? tooltipBuilder,
  Color? scaffoldBackgroundColor,
  Widget? content,
  Widget body = const Text('Body'),
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
              cupertinoStyle: cupertinoStyle,
              tooltipBuilder: tooltipBuilder,
              scaffoldBackgroundColor: scaffoldBackgroundColor,
              content: content,
              body: body,
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
  return tester.widget<MaterialWideNavigationRailButton>(finder).selected;
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
      onSelectionChanged: widget.controller.select,
    );
  }
}
