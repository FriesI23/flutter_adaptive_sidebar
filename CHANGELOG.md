# Changelog

## Unreleased

- Match the default Cupertino edge sidebar fill to iPadOS 27 in light and dark
  modes.
- Add `CupertinoSidebar.backgroundColor` with plain and dynamic color support.
- Expose `kCupertinoSidebarEdgeFillAlpha` for theme-color overrides that retain
  the edge style's default glass opacity.
- Match iPadOS 27 edge destination selection, focus, press, icon, and label
  colors in light and dark modes.
- Add state-aware destination color overrides.
- Retain the edge sidebar's last interacted destination across focus and theme
  rebuilds, and clear it on an actual outside tap, while keeping liquid
  navigation behavior unchanged.

## 0.1.0

- Material and Cupertino sidebars backed by a shared navigation controller.
- Built-in primary and auxiliary navigation lists, custom content, item styles,
  tooltips, and action labels.
- Collapsible and resizable layouts, including configurable Material rail
  widths and Cupertino inset or edge styles.
- An iPadOS-style Cupertino collapsed bar with configurable placement,
  transitions, visibility, and toolbar geometry.
- Navigation obstruction insets, focus handling, and left-to-right and
  right-to-left layout support.
