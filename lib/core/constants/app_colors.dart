import 'package:flutter/material.dart';

/// Fallback Material 3 colour schemes (SOW §6.1).
///
/// These are the seed / fallback palettes used when Android 12+ dynamic colour
/// is unavailable. `DynamicColorBuilder` overrides them when it can.
abstract final class AppColors {
  AppColors._();

  /// Brand seed colour (light `primary`).
  static const Color seed = Color(0xFF1565C0);

  /// Light Material 3 colour scheme (SOW §6.1).
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1565C0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD3E4FF),
    onPrimaryContainer: Color(0xFF001C3B),
    secondary: Color(0xFFE53935),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDAD6),
    onSecondaryContainer: Color(0xFF410002),
    tertiary: Color(0xFF6750A4),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF1A1A2E),
    surfaceContainerHighest: Color(0xFFEEF2FA),
    onSurfaceVariant: Color(0xFF5C6470),
    outline: Color(0xFFC5CAD3),
    outlineVariant: Color(0xFFD9DEE7),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2F3033),
    onInverseSurface: Color(0xFFF1F0F4),
    inversePrimary: Color(0xFF90CAF9),
  );

  /// Dark Material 3 colour scheme (SOW §6.1).
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF90CAF9),
    onPrimary: Color(0xFF003C8F),
    primaryContainer: Color(0xFF1565C0),
    onPrimaryContainer: Color(0xFFD3E4FF),
    secondary: Color(0xFFEF9A9A),
    onSecondary: Color(0xFF680003),
    secondaryContainer: Color(0xFF930006),
    onSecondaryContainer: Color(0xFFFFDAD6),
    tertiary: Color(0xFFD0BCFF),
    onTertiary: Color(0xFF381E72),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceContainerHighest: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFFA0A0A0),
    outline: Color(0xFF3A3A3A),
    outlineVariant: Color(0xFF2A2A2A),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE0E0E0),
    onInverseSurface: Color(0xFF2F3033),
    inversePrimary: Color(0xFF1565C0),
  );

  /// Donut-chart segment colour for the principal portion (primary family).
  static Color principalSegment(ColorScheme scheme) => scheme.primary;

  /// Donut-chart segment colour for the interest portion (secondary family).
  static Color interestSegment(ColorScheme scheme) => scheme.secondary;
}
