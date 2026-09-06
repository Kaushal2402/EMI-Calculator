import 'package:flutter/material.dart';

/// Typography scale (SOW §6.2): Poppins for display/headings, Inter for
/// body/data.
///
/// The faces are bundled as app assets (see `pubspec.yaml` `fonts:`) rather
/// than fetched at runtime by `google_fonts`, so the first frame never waits
/// on a network font and widget goldens render the real glyphs.
abstract final class AppTypography {
  AppTypography._();

  static const String _display = 'Poppins';
  static const String _body = 'Inter';

  /// Poppins text style with an absolute line height in logical pixels.
  static TextStyle _poppins(
    double size,
    FontWeight weight,
    double lineHeight,
  ) => TextStyle(
    fontFamily: _display,
    fontSize: size,
    fontWeight: weight,
    height: lineHeight / size,
  );

  /// Inter text style with an absolute line height in logical pixels.
  static TextStyle _inter(
    double size,
    FontWeight weight,
    double lineHeight,
  ) => TextStyle(
    fontFamily: _body,
    fontSize: size,
    fontWeight: weight,
    height: lineHeight / size,
  );

  /// Builds the app [TextTheme] for the given [brightness].
  ///
  /// Colours are left null here; `ThemeData` merges the active
  /// [ColorScheme.onSurface] in.
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return base.copyWith(
      displaySmall: _poppins(36, FontWeight.w700, 44),
      headlineMedium: _poppins(28, FontWeight.w600, 36),
      headlineSmall: _poppins(24, FontWeight.w600, 32),
      titleLarge: _poppins(22, FontWeight.w600, 28),
      titleMedium: _inter(16, FontWeight.w500, 24),
      titleSmall: _inter(14, FontWeight.w500, 20),
      bodyLarge: _inter(16, FontWeight.w400, 24),
      bodyMedium: _inter(14, FontWeight.w400, 20),
      bodySmall: _inter(12, FontWeight.w400, 16),
      labelLarge: _inter(14, FontWeight.w600, 20),
      labelMedium: _inter(12, FontWeight.w500, 16),
      labelSmall: _inter(11, FontWeight.w400, 16),
    );
  }
}
