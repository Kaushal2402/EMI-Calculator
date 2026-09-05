import 'package:emi_calculator/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:emi_calculator/features/calculator/presentation/screens/results_screen.dart';
import 'package:emi_calculator/features/info/presentation/screens/info_bottom_sheet.dart';
import 'package:emi_calculator/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Named route paths (SOW §7.3).
abstract final class AppRoutes {
  AppRoutes._();

  /// Splash / root.
  static const String splash = '/';

  /// Calculator (home) screen.
  static const String calculator = '/calculator';

  /// Results screen.
  static const String results = '/results';

  /// Info / About — presented as a modal bottom sheet (SOW §5.4).
  static const String info = '/info';
}

/// The app's [GoRouter] instance.
///
/// PHASE 0 SCAFFOLD: flat route table with empty screens. `/info` is modelled
/// as a full-screen dialog page here; task 6.1 swaps it for a proper
/// drag-to-dismiss modal bottom sheet.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.calculator,
      name: 'calculator',
      builder: (context, state) => const CalculatorScreen(),
    ),
    GoRoute(
      path: AppRoutes.results,
      name: 'results',
      builder: (context, state) => const ResultsScreen(),
    ),
    GoRoute(
      path: AppRoutes.info,
      name: 'info',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: InfoBottomSheet(),
      ),
    ),
  ],
);
