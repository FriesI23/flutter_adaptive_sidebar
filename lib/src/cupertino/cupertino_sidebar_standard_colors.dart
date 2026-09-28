import 'package:flutter/cupertino.dart';

/// Measured unfocused selection fill of the iPadOS 27 edge Sidebar.
const cupertinoSidebarEdgeSelectedColor = CupertinoDynamicColor.withBrightness(
  debugLabel: 'cupertinoSidebarEdgeSelected',
  color: Color(0xFFD2D6DA),
  darkColor: Color(0xFF2D3235),
);

/// Measured focused or pressed fill of the iPadOS 27 edge Sidebar.
const cupertinoSidebarEdgeActiveColor = CupertinoDynamicColor.withBrightness(
  debugLabel: 'cupertinoSidebarEdgeActive',
  color: Color(0xFF0081F6),
  darkColor: Color(0xFF13A4FF),
);
