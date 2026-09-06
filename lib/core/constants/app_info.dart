/// Static app metadata shown in the UI (SOW §5.4 "app version").
library;

/// Human-readable app version name, e.g. `1.0.0`.
///
/// INTERIM SOURCE: hardcoded and kept in sync **by hand** with the `version:`
/// field in `pubspec.yaml` (currently `1.0.0+1`). Phase 9.3 formalises the
/// bump policy.
///
/// The production-grade fix is to read `PackageInfo.fromPlatform().version`
/// at runtime, which needs the `package_info_plus` package — an addition
/// beyond SOW §9, so it is **pending client approval** (same precedent as
/// `dynamic_color`). Until then this constant is the single source of truth
/// for the displayed version and keeps widget tests deterministic.
const String kAppVersion = '1.0.0';

/// Attribution line shown on the splash and About sheet (SOW §5.1, §5.4).
const String kAppAuthor = 'Softpital';
