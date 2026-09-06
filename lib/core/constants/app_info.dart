/// Static app metadata shown in the UI (SOW §5.4 "app version").
library;

/// Human-readable app version name, e.g. `1.0.0`.
///
/// Hand-synced mirror of the `<name>` part of `pubspec.yaml`'s `version:` line
/// (currently `1.0.0+1`). The bump policy and per-release checklist live in
/// `docs/VERSIONING.md`; `test/core/app_version_consistency_test.dart` fails the
/// build if this constant drifts from `pubspec.yaml`.
///
/// Client decision 2026-09-06: keep this const — do **not** add
/// `package_info_plus` to read the version from the platform at runtime.
const String kAppVersion = '1.0.0';

/// Attribution line shown on the splash and About sheet (SOW §5.1, §5.4).
const String kAppAuthor = 'Softpital';
