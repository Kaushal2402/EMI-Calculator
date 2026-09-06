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

/// A [Page] that presents its [child] as a Material modal bottom sheet
/// (SOW §5.4): drag handle, drag-to-dismiss, capped at 60% of screen height.
///
/// Used for the `/info` route so the About sheet participates in normal
/// GoRouter navigation (`context.push('/info')` opens it, a drag or scrim tap
/// pops it).
class ModalBottomSheetPage<T> extends Page<T> {
  /// Creates a modal-bottom-sheet page.
  const ModalBottomSheetPage({required this.child, super.key});

  /// The sheet content.
  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      builder: (_) => child,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
    );
  }
}

/// The app's [GoRouter] instance (SOW §7.3).
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
      pageBuilder: (context, state) => const ModalBottomSheetPage<void>(
        child: InfoBottomSheet(),
      ),
    ),
  ],
);
