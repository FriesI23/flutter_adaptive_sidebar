import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reserved extent scales with progress', () {
    const hidden = SidebarLeadingScope(
      toolbarAvoidance: EdgeInsets.zero,
      progress: 1,
      child: SizedBox(),
    );
    const open = SidebarLeadingScope(
      toolbarAvoidance: EdgeInsets.zero,
      progress: 0,
      child: SizedBox(),
    );

    expect(hidden.reservedExtent, SidebarLeadingScope.buttonExtent);
    expect(open.reservedExtent, 0);
  });

  testWidgets('maybeOf is null outside a scope', (tester) async {
    late SidebarLeadingScope? scope;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            scope = SidebarLeadingScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(scope, isNull);
  });

  testWidgets('maybeOf returns the enclosing scope', (tester) async {
    await tester.pumpWidget(
      const SidebarLeadingScope(
        toolbarAvoidance: EdgeInsets.only(left: 6),
        progress: 0.5,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: _ScopeReader(),
        ),
      ),
    );
    final scope = tester.widget<_ScopeReader>(find.byType(_ScopeReader)).scope;

    expect(scope.toolbarAvoidance, const EdgeInsets.only(left: 6));
    expect(scope.reservedExtent, SidebarLeadingScope.buttonExtent * 0.5);
  });
}

class _ScopeReader extends StatelessWidget {
  const _ScopeReader();

  SidebarLeadingScope get scope => _scope;
  static late SidebarLeadingScope _scope;

  @override
  Widget build(BuildContext context) {
    _scope = SidebarLeadingScope.maybeOf(context)!;
    return const SizedBox();
  }
}
