# Changelog

## Unreleased

- Keep the light Edge collapsed selection visible over tinted glass content by
  preserving it as a neutral overlay instead of a fixed composited color.

- Match the iPadOS 27 Edge Sidebar label transition: black to white in light
  appearance and white in both inactive and active dark states.

- Match the collapsed edge bar to the iPadOS 27 Files light/dark glass,
  neutral selection, and accent-label treatment while preserving liquid
  defaults and the measured 44pt/36pt geometry.
- Propagate the parent `CupertinoSidebarStyle` and edge background override to
  the supplied collapsed bar without adding a required caller parameter.
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
