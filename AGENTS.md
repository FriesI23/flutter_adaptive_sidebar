# Repository Guidelines

## Project Structure & Module Organization

This repository is a Flutter package. The public library entry point is
`lib/flutter_adaptive_sidebar.dart`; keep implementation details under
`lib/src/`. Platform-specific widgets are grouped in `lib/src/material/` and
`lib/src/cupertino/`, while shared controllers, selection models, scopes, and
constants live directly in `lib/src/`. Tests mirror that layout under
`test/src/`; reusable widget setup belongs in `test/harness/`. The runnable
showcase is in `example/`, with its own `lib/` and `test/` directories. Update
`README.md`, `README_zh.md`, and `CHANGELOG.md` when public behavior changes.

## Build, Test, and Development Commands

The `Makefile` uses the repository's FVM SDK when `.fvm/flutter_sdk` exists,
and otherwise uses Flutter from `PATH`.

- `make check` verifies formatting, analyzes the package and example, and runs
  both test suites. Run this before opening a pull request.
- `make test` runs package tests; target one file with
  `flutter test test/src/material/material_sidebar_test.dart`.
- `make test-example` tests the example application.
- `make format` formats all Dart sources; `make format-check` checks without
  modifying files.
- `make analyze` and `make analyze-example` run static analysis separately.
- `cd example && flutter run` launches the interactive showcase.
- `make publish-dry-run` validates pub.dev packaging and metadata.

## Coding Style & Naming Conventions

Use Dart's standard two-space indentation and run `dart format`. The project
extends `flutter_lints` with strict casts, inference, and raw types. Prefer
relative imports inside the package, explicit return types, `final` locals,
and `const` constructors where possible. Name files in `snake_case.dart`, types
in `UpperCamelCase`, and members in `lowerCamelCase`. Document public APIs and
export them deliberately from the package entry point.

## Testing Guidelines

Use `flutter_test` and name files `*_test.dart`. Add focused widget or unit
tests beside the corresponding platform area, and put shared fixtures in
`test/harness/`. Cover Material and Cupertino behavior when shared contracts
change. There is no numeric coverage threshold; regressions and new public
behavior should have explicit tests.

## Commit & Pull Request Guidelines

History follows Conventional Commit-style subjects such as `feat:`,
`refactor:`, and `test:`. Keep subjects imperative and scoped to one coherent
change. Pull requests should explain the behavior and rationale, link relevant
issues, list validation performed, and include screenshots or recordings for
visible UI changes. Ensure `make check` and `make publish-dry-run` pass before
requesting review.
