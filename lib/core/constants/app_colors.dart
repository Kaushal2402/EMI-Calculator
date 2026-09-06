import 'package:flutter/material.dart';

/// Material 3 colour schemes for the app.
///
/// Brand palette (client, 2026-09-06):
/// * Primary Blue `#0060D0` · Deep Blue `#0030A0` · Bright Blue (CTA) `#0080F0`
/// * Dark Navy `#203050` · Gold / Rupee `#F0D040` · White `#FFFFFF`
///
/// These are the seed / fallback palettes used when Android 12+ dynamic colour
/// is unavailable; `DynamicColorBuilder` overrides them when it can. Every
/// foreground/background pair the UI actually paints is contrast-audited in
/// `test/core/wcag_contrast_test.dart` (AC-09).
abstract final class AppColors {
  AppColors._();

  /// Brand seed colour (light `primary`).
  static const Color seed = Color(0xFF0060D0);

  /// Bright-blue CTA accent — the top stop of the primary-button gradient.
  static const Color brightBlue = Color(0xFF0080F0);

  /// Deep-blue brand shade — bottom stop of gradients, dark `primaryContainer`.
  static const Color deepBlue = Color(0xFF0030A0);

  /// Light Material 3 colour scheme.
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0060D0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE8FB),
    onPrimaryContainer: Color(0xFF002E7A),
    secondary: Color(0xFFF0D040),
    onSecondary: Color(0xFF203050),
    secondaryContainer: Color(0xFFFBF0C4),
    onSecondaryContainer: Color(0xFF4A3D00),
    tertiary: Color(0xFF0030A0),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFBFE),
    onSurface: Color(0xFF203050),
    surfaceContainerHighest: Color(0xFFEBF0F8),
    onSurfaceVariant: Color(0xFF586277),
    outline: Color(0xFFC3CCDC),
    outlineVariant: Color(0xFFDCE3EF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2C3247),
    onInverseSurface: Color(0xFFF1F2F8),
    inversePrimary: Color(0xFF7FB3F7),
  );

  /// Dark Material 3 colour scheme.
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF7FB3F7),
    onPrimary: Color(0xFF00214D),
    primaryContainer: Color(0xFF0030A0),
    onPrimaryContainer: Color(0xFFD9E7FD),
    secondary: Color(0xFFF0D040),
    onSecondary: Color(0xFF203050),
    secondaryContainer: Color(0xFF5A4B00),
    onSecondaryContainer: Color(0xFFFBE7A0),
    tertiary: Color(0xFF7FB3F7),
    onTertiary: Color(0xFF00214D),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Color(0xFF12151D),
    onSurface: Color(0xFFE4E8F1),
    surfaceContainerHighest: Color(0xFF1E232E),
    onSurfaceVariant: Color(0xFFA9B2C4),
    outline: Color(0xFF3B4356),
    outlineVariant: Color(0xFF2A313F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE4E8F1),
    onInverseSurface: Color(0xFF2C3247),
    inversePrimary: Color(0xFF0060D0),
  );

  /// Primary-button gradient stops (bright blue → primary → deep blue).
  static const List<Color> ctaGradient = [
    Color(0xFF0080F0),
    Color(0xFF0060D0),
    Color(0xFF0038B0),
  ];

  /// Splash / hero gradient stops (primary → deep blue).
  static const List<Color> brandGradient = [
    Color(0xFF0068DA),
    Color(0xFF0030A0),
  ];

  /// Donut-chart segment colour for the principal portion (primary family).
  static Color principalSegment(ColorScheme scheme) => scheme.primary;

  /// Donut-chart segment colour for the interest portion (gold).
  static Color interestSegment(ColorScheme scheme) => scheme.secondary;

  /// Hairline border for legend swatches / chips so a light gold swatch still
  /// has a 3:1 boundary on a light surface (WCAG 1.4.11).
  static Color swatchBorder(ColorScheme scheme) => scheme.onSurfaceVariant;
}
