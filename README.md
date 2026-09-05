# EMI Calculator

Flutter mobile app (iOS + Android) to calculate Equated Monthly Instalments for
home, car and personal loans, with an amortization schedule and an
interest-vs-principal donut chart. Monetised with Google AdMob.

- **Contract:** [`emi-calculator-sow.md`](emi-calculator-sow.md)
- **Execution plan:** [`TASKS.md`](TASKS.md)
- **Architecture:** Clean Architecture, feature-first, Riverpod (code generation)

## Getting started

```bash
flutter pub get
cp .env.example .env        # fill in production AdMob IDs for release builds
flutter run
```

## Quality gates

```bash
dart format .
flutter analyze             # must be 0 errors / 0 warnings (AC-08)
dart run custom_lint
flutter test
```

## Project layout

```
lib/
├── main.dart, app.dart
├── core/        constants (design tokens), extensions, theme, router, utils
├── features/
│   ├── calculator/  data · domain · presentation
│   ├── info/        presentation
│   └── splash/      presentation
└── shared/widgets/
```

See SOW §8 for the full tree.

## Toolchain notes

- Flutter 3.44.8 / Dart 3.12.2, AGP 9 / Gradle 9.
- Package versions differ from SOW §9: the pinned 2024-era versions do not
  resolve on this SDK. `pubspec.yaml` documents each deviation inline. Pending
  client sign-off.
- Generated code (`*.g.dart`, `*.freezed.dart`) **is** committed — see
  `.gitignore` for the rationale.
