# flutter_adaptive_sidebar example

Demonstrates a shared sidebar controller with Material and Cupertino sidebars.

```bash
cd example
flutter run
```

The content's navigation bar switches Material and Cupertino, chooses light, dark, or system appearance, and toggles left-to-right or right-to-left layout for the sidebar and the page. Cupertino colors come from `ThemeData.cupertinoOverrideTheme`, so they follow that brightness. The sidebar stays beside the content. Auto expands it when the window is at least the Auto width and collapses it below that width, including a landscape window that has become narrow. The default Auto width is 800, and Settings can change it. A manual sidebar toggle pauses Auto until Auto is selected again. Coll and Expand force those states. Home is a 9999-row list. Settings is the footer destination and changes the sidebar width bounds, the collapsed Material rail, and optional custom resize, tooltip, label, and sidebar-content builders. Custom sidebar content replaces the navigation list with destination buttons, a Note action, and a reminders-style list section under Settings. That section keeps its labels while the rail is expanded and falls back to centered icons when the Material rail collapses.
