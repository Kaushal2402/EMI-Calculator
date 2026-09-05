import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget: wires `MaterialApp.router` to [appRouter] and the M3 themes
/// (SOW §6, §7.3).
///
/// PHASE 0 NOTE: Android 12+ dynamic colour (`DynamicColorBuilder`, SOW §6.1)
/// needs the `dynamic_color` package, which is missing from SOW §9. Flagged to
/// the client. Until it is approved the app uses the static fallback schemes in
/// [AppTheme]; the wiring point is isolated here.
class EmiCalculatorApp extends ConsumerWidget {
  /// Creates the app root.
  const EmiCalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'EMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
