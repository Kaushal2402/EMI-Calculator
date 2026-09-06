# Versioning policy

**Scope:** EMI Calculator (Flutter, iOS + Android). TASKS 9.3.

## Single source of truth

`pubspec.yaml` → `version: <name>+<code>`.

| Part | Name | Maps to Android | Maps to iOS | Rule |
|---|---|---|---|---|
| `<name>` | `1.0.0` | `versionName` / `flutter.versionName` | `CFBundleShortVersionString` / `FLUTTER_BUILD_NAME` | Semantic version, user-visible. |
| `<code>` | `1` | `versionCode` / `flutter.versionCode` | `CFBundleVersion` / `FLUTTER_BUILD_NUMBER` | Integer, **strictly increasing**, never reused on either store. |

Flutter derives all four native fields from this one line at build time — do **not**
hand-edit `build.gradle.kts`, `Info.plist`, or the Xcode project for versioning.

The in-app "app version" string (`lib/core/constants/app_info.dart` → `kAppVersion`)
is a **hand-synced mirror** of `<name>` only (client decision 2026-09-06: no
`package_info_plus`). Whenever `<name>` changes, update `kAppVersion` in the same
commit. `test/core/app_version_consistency_test.dart` fails the build if they drift.

## Current

```
version: 1.0.0+1
```

First public release. `kAppVersion = '1.0.0'`.

## Bump rules (semver for `<name>`)

- **PATCH** (`1.0.0 → 1.0.1`): bug fixes, copy tweaks, dependency bumps with no
  behaviour change. No SOW scope change.
- **MINOR** (`1.0.x → 1.1.0`): backward-compatible feature added (e.g. a new loan
  type, PDF export) — i.e. new SOW scope that does not break existing flows.
- **MAJOR** (`1.x.y → 2.0.0`): redesign, data-migration, or a change that removes or
  breaks an existing user-facing behaviour.

`<code>` increases by **exactly 1 on every build uploaded to either store**, including
re-uploads of the same `<name>` (e.g. a rejected binary resubmitted). It is monotonic
across both platforms for simplicity — gaps are fine, decreases are not.

## Release checklist (per store submission)

1. Decide the `<name>` bump from the rules above.
2. Edit `pubspec.yaml` `version:` — bump `<name>` as decided and **always** `+1` the `<code>`.
3. If `<name>` changed, update `kAppVersion` in `lib/core/constants/app_info.dart`.
4. `flutter test` (the consistency test must pass), `flutter analyze` 0/0.
5. Commit as `chore(release): vX.Y.Z (build N)` on a release branch off `develop`.
6. Build: `flutter build appbundle --release --dart-define-from-file=.env` and
   `flutter build ipa --release --dart-define-from-file=.env` (TASKS 9.4 / 9.5).
7. After the store accepts the build, tag `vX.Y.Z` on the merge commit (TASKS 10.6).

## Hotfix

Branch `hotfix/vX.Y.(Z+1)` off the release tag, PATCH bump + `<code>` +1, cherry-pick
forward to `develop`.
