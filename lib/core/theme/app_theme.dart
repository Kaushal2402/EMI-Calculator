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
        scrolledUnderElevation: 2,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.headlineSmall,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.ctaButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
          textStyle: textTheme.labelLarge,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          borderSide: BorderSide(color: scheme.outline),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          side: BorderSide(color: scheme.outline),
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
