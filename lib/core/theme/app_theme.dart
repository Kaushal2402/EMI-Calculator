import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// Builds the light and dark [ThemeData] for the app (SOW §6).
///
/// Material 3, tonal elevation only (no custom shadows, SOW §6.4). When
/// Android 12+ dynamic colour is available the caller passes the harmonised
/// schemes in; otherwise the fallbacks from [AppColors] are used.
abstract final class AppTheme {
  AppTheme._();

  /// Light theme. Pass a dynamic [scheme] to override the fallback palette.
  static ThemeData light([ColorScheme? scheme]) =>
      _base(scheme ?? AppColors.light);

  /// Dark theme. Pass a dynamic [scheme] to override the fallback palette.
  static ThemeData dark([ColorScheme? scheme]) =>
      _base(scheme ?? AppColors.dark);

  static ThemeData _base(ColorScheme scheme) {
    final textTheme = AppTypography.textTheme(
      scheme.brightness,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        toolbarHeight: AppSizes.appBarHeight,
        centerTitle: false,
        scrolledUnderElevation: 3,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.ctaButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.outlinedButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          foregroundColor: scheme.onSurfaceVariant,
          side: BorderSide(color: scheme.outlineVariant),
          shape: const StadiumBorder(),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.16),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        constraints: const BoxConstraints(
          minHeight: AppSizes.textFieldHeight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kSpacingLG,
          vertical: kSpacingMD,
        ),
        // Filled field, no resting outline (the fill + floating label carry
        // the affordance); a 2dp primary ring on focus. Also retires the
        // low-contrast resting `outline` border (qa/bugs.md P1-01).
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: scheme.surface,
        elevation: 3,
      ),
    );
  }
}
