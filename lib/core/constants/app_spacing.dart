/// Spacing tokens — 8dp base grid, all values multiples of 4dp (SOW §6.3).
///
/// Use these constants everywhere instead of hardcoding numbers so the
/// layout stays on-grid and easy to retune.
library;

/// 4dp — micro gap (icon-to-label, badge padding).
const double kSpacingXS = 4;

/// 8dp — tight gap (within a row of chips).
const double kSpacingSM = 8;

/// 12dp — default gap (between stacked form elements).
const double kSpacingMD = 12;

/// 16dp — standard unit (horizontal screen padding, card insets).
const double kSpacingLG = 16;

/// 20dp — loose gap (between labeled field groups).
const double kSpacingXL = 20;

/// 24dp — section gap (between major content blocks).
const double kSpacing24 = 24;

/// 32dp — generous gap (CTA button top margin).
const double kSpacing32 = 32;

/// 40dp — large gap (top of first section below the AppBar).
const double kSpacing40 = 40;

/// 48dp — extra-large (hero metric vertical padding).
const double kSpacing48 = 48;

/// Component sizing tokens (SOW §6.3 "Component sizing" table).
abstract final class AppSizes {
  /// AppBar height.
  static const double appBarHeight = 64;

  /// Primary CTA (`FilledButton`) height.
  static const double ctaButtonHeight = 52;

  /// `OutlinedButton` height.
  static const double outlinedButtonHeight = 44;

  /// Material 3 `TextField` height.
  static const double textFieldHeight = 56;

  /// Loan-type `SegmentedButton` height.
  static const double segmentedButtonHeight = 40;

  /// Yr/Mo `ToggleButton` height.
  static const double toggleButtonHeight = 36;

  /// `DataTable` row height.
  static const double dataTableRowHeight = 48;

  /// Bottom navigation bar height.
  static const double bottomNavBarHeight = 80;

  /// AdMob banner height.
  static const double adBannerHeight = 50;

  /// Donut chart diameter on the Results screen.
  static const double chartDiameter = 200;

  // Border radii.

  /// OutlinedButton / SegmentedButton / ToggleButton radius.
  static const double radiusSM = 8;

  /// Legacy control radius (kept for callers that pin the old value).
  static const double radiusMD = 12;

  /// CTA button / TextField / card / hero-tile radius — the app's default
  /// rounded-surface radius for the refreshed UI.
  static const double radiusLG = 16;

  /// Large decorative radius (hero panels, bottom sheets).
  static const double radiusXL = 24;
}

/// Letter spacing applied to ALL-CAPS labels (`0.08em`, SOW §6.2).
const double kCapsLetterSpacing = 0.08;
