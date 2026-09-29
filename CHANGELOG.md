# Changelog

## 0.3.0

- Use Flutter's native Cupertino focus halo for expanded and collapsed sidebar
  destinations on macOS.
- Use platform-appropriate focused destination fills on iOS and iPadOS.
- Add `CupertinoSidebarThemeData.focusHaloBuilder` so apps can customize the
  macOS focus treatment while the package retains focus semantics.

## 0.2.0

- Align the Cupertino edge sidebar and collapsed bar with the iPadOS 27
  appearance while preserving their selection and focus behavior.
- Follow `CupertinoTheme.primaryColor` for Liquid and Edge destination accents
  across expanded and collapsed layouts.
- Add app-wide and per-sidebar Edge background customization, dynamic color
  support, the exported default fill alpha, and state-aware item colors.
- Add Cupertino theme-color switching to the example app.

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
