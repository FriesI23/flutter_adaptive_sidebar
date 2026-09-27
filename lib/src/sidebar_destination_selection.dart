/// Which destination list currently holds the selection.
///
/// Primary and auxiliary destinations cannot be selected together.
sealed class SidebarDestinationSelection {
  /// Creates a selection.
  const SidebarDestinationSelection();

  /// Primary index, or null when an auxiliary destination is selected.
  int? get primaryIndex => switch (this) {
    SidebarPrimarySelection(:final index) => index,
    SidebarAuxiliarySelection() => null,
  };
}

/// A selected destination in the primary list.
final class SidebarPrimarySelection extends SidebarDestinationSelection {
  /// Creates a primary selection at [index].
  const SidebarPrimarySelection(this.index) : assert(index >= 0);

  /// Zero-based index in the primary destination list.
  final int index;

  @override
  bool operator ==(Object other) =>
      other is SidebarPrimarySelection && other.index == index;

  @override
  int get hashCode => index;
}

/// A selected destination in the auxiliary list.
final class SidebarAuxiliarySelection extends SidebarDestinationSelection {
  /// Creates an auxiliary selection at [index].
  const SidebarAuxiliarySelection(this.index) : assert(index >= 0);

  /// Zero-based index in the auxiliary destination list.
  final int index;

  @override
  bool operator ==(Object other) =>
      other is SidebarAuxiliarySelection && other.index == index;

  @override
  int get hashCode => index;
}
