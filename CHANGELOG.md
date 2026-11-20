# Changelog

## 0.5.1

- Add README recommendations for other projects.

## 0.5.0

- **Breaking:** Require Flutter 3.47+ and Dart 3.13+; support only the standalone
  `material_ui` and `cupertino_ui` design libraries.
- Update direct `cupertino_icons` dependencies to `^2.0.0`.
- Update app hosts, custom content, and builder imports to the standalone libraries.
- Migrate themes, `CupertinoSidebarThemeData` registration, and dynamic colors.
- Use the localization delegates from the standalone libraries.

## 0.4.0

- Add `CupertinoSidebarToolbarRegion` to position toggles and fixed collapsed
  bars within a declared toolbar region, with a width budget that preserves
  window centering and independent panel and page safe areas.
- Auto-scroll overflowing Cupertino collapsed destinations when dragging the
  selected thumb near an edge. Releasing selects and reveals the target;
  cancelling leaves selection unchanged.

## 0.3.2

- Raise the example deployment targets to iOS 15 and macOS 12 for Xcode 27.
- Keep selected Material rail hover, focus, and press feedback visible and
  follow NavigationBar theme overlay colors.

## 0.3.1

- Added Cupertino sidebar toggle builder overrides for the interactive button
  and collapsed-bar transition placeholder while retaining package defaults.

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
