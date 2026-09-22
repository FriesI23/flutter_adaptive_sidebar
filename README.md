# flutter_adaptive_sidebar

Material and Cupertino sidebars that share one controller.

The package draws the sidebar. The caller decides when to show it, including how window size maps to a sidebar or to content alone.

```dart
final Widget page = useMaterial
    ? Row(
        children: [
          MaterialSidebar(
            controller: controller,
            content: MaterialSidebarNavigation(
              destinations: destinations,
              selectedIndex: controller.selectedIndex,
              onDestinationSelected: controller.select,
            ),
          ),
          Expanded(child: body),
        ],
      )
    : CupertinoSidebar(
        controller: controller,
        content: CupertinoSidebarNavigation(
          destinations: destinations,
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: controller.select,
        ),
        child: body,
      );
```

`content` can be any widget. `MaterialSidebarNavigation` and `CupertinoSidebarNavigation` are the destination lists, including destinations pinned at the bottom. `MaterialWideNavigationRailButton` and `CupertinoSidebarDestination` are the rows those lists use.

`AdaptiveNavigationController` keeps the selected destination, sidebar expansion, and manual width when the style changes. Both sidebars accept `tooltipBuilder`; only Material supplies a tooltip when it is omitted.

Wrap the tree in `IosNavigationObstruction` to clear iPadOS window controls, or provide your own `NavigationObstructionScope`.

See `example/` for a runnable app with a Material / Cupertino switch. Large and landscape windows place the sidebar beside the content. Compact portrait shows the content alone.
