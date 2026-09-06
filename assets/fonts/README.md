# Bundled fonts

| Family | Files | Source | License |
|---|---|---|---|
| Poppins | `Poppins-{Regular,Medium,SemiBold,Bold}.ttf` | Indian Type Foundry / Jonny Pinhorn — https://github.com/google/fonts/tree/main/ofl/poppins | SIL Open Font License 1.1 |
| Inter | `Inter-Variable.ttf` (variable, `wght` axis) | Rasmus Andersson — https://github.com/google/fonts/tree/main/ofl/inter | SIL Open Font License 1.1 |

Both faces are the upstream OFL builds, vendored so the first frame never
waits on a network font (`google_fonts` runtime fetching) and widget goldens
render real glyphs. OFL 1.1 permits bundling and redistribution with the
software; the full licence text ships in each font's `name` table.

Declared in `pubspec.yaml` under `flutter: fonts:` and consumed via
`lib/core/constants/app_typography.dart` (`fontFamily: 'Poppins' | 'Inter'`).
