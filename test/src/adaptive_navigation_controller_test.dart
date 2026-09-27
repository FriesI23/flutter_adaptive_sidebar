import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extent = SideNavigationExtent(200);

  test('keeps selection, expansion, and manual width', () {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    controller.select(const SidebarPrimarySelection(2));
    controller.expanded = false;
    controller.beginResize(extent, windowWidth: 1200);
    controller.updateResize(80, extent, windowWidth: 1200);
    controller.endResize();

    expect(controller.selection, const SidebarPrimarySelection(2));
    expect(controller.expanded, isFalse);
    expect(controller.manualWidth, 280);
    expect(controller.resizing, isFalse);
    expect(controller.effectiveWidth(extent, windowWidth: 1200), 280);

    controller.clearManualWidth();
    expect(controller.manualWidth, isNull);
    expect(controller.effectiveWidth(extent, windowWidth: 1200), 200);
  });

  test('uses its initial values and ignores unchanged writes', () {
    final controller = AdaptiveNavigationController(
      initialSelection: const SidebarPrimarySelection(1),
      initialExpanded: false,
      initialManualWidth: 240,
    );
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    expect(controller.selection, const SidebarPrimarySelection(1));
    expect(controller.expanded, isFalse);
    expect(controller.manualWidth, 240);

    controller.select(const SidebarPrimarySelection(1));
    controller.expanded = false;
    controller.clearManualWidth();
    expect(notifications, 1);
    expect(controller.manualWidth, isNull);
  });

  test('rejects a negative selection', () {
    expect(() => SidebarPrimarySelection(-1), throwsAssertionError);
    expect(() => SidebarAuxiliarySelection(-1), throwsAssertionError);
  });

  test('toggleExpanded flips the presentation', () {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    controller.toggleExpanded();
    expect(controller.expanded, isFalse);
    controller.toggleExpanded();
    expect(controller.expanded, isTrue);
  });

  test('resize reports an active drag until it ends', () {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.beginResize(extent, windowWidth: 1200);
    expect(controller.resizing, isTrue);

    controller.endResize();
    expect(controller.resizing, isFalse);

    notifications = 0;
    controller.endResize();
    expect(notifications, 0);
  });

  test('manual width cannot exceed the window upper bound', () {
    final controller = AdaptiveNavigationController();
    addTearDown(controller.dispose);

    controller.beginResize(extent, windowWidth: 1200);
    controller.updateResize(200, extent, windowWidth: 1200);
    controller.endResize();

    expect(controller.manualWidth, 288);
    expect(controller.effectiveWidth(extent, windowWidth: 1200), 288);
  });
}
