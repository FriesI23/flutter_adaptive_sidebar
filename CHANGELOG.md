# Changelog

## Unreleased

- Derive liquid and edge destination accents from
  `CupertinoTheme.primaryColor` in both the expanded sidebar and collapsed
  horizontal bar.
- Preserve the edge sidebar's unfocused selection, retained active interaction,
  pointer focus, and outside-tap reset behavior while applying the theme accent.
- Keep the collapsed edge capsule's surface, border, shadow, and opacity
  treatment while sourcing its tint from the resolved Cupertino bar theme.
- Add `CupertinoSidebarThemeData.edgeBackgroundColor` so app themes can supply
  an edge tint while the package consistently applies its glass opacity to
  expanded and collapsed surfaces.
- Add default, purple, teal, and orange Cupertino theme-color switching to the
  example app.
- Retain the iPadOS 27 edge sidebar baseline fill, geometry, opacity, and
  separator treatment when no theme tint is supplied.
- Add `CupertinoSidebar.backgroundColor` with plain and dynamic color support.
- Expose `kCupertinoSidebarEdgeFillAlpha` for theme-color overrides that retain
  the edge style's default glass opacity.
- Add state-aware destination color overrides.

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
