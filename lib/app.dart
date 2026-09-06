import 'package:dynamic_color/dynamic_color.dart';
import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: wires `MaterialApp.router` to [appRouter] and the M3 themes
/// (SOW §6, §7.3).
///
/// Android 12+ dynamic colour is applied when available via
/// [DynamicColorBuilder]; otherwise the static fallback schemes in
/// [AppColors] are used (SOW §6.1).
class EmiCalculatorApp extends ConsumerWidget {
  /// Creates the app root.
  const EmiCalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme restore is async (SharedPreferences); fall back to system while it
    // resolves on the first frame.
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic ?? AppColors.light;
        final darkScheme = darkDynamic ?? AppColors.dark;

        return MaterialApp.router(
          title: 'EMI Calculator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(lightScheme),
          darkTheme: AppTheme.dark(darkScheme),
          themeMode: themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
