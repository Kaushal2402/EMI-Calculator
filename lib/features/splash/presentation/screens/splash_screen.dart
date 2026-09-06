import 'dart:async';

import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/constants/app_info.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen (SOW §5.1).
///
/// The app icon on a rounded card, the "EMI Calculator" wordmark, a muted
/// "by Softpital" by-line and a slim progress bar, over the brand
/// primary → deep-blue gradient. After 1.5s it auto-navigates to `/calculator`.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  /// How long the splash is shown before navigating on (SOW §5.1).
  static const Duration displayDuration = Duration(milliseconds: 1500);

  /// Side of the icon card.
  static const double iconSize = 104;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashScreen.displayDuration, () {
      if (mounted) context.go(AppRoutes.calculator);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.brandGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: SplashScreen.iconSize,
                height: SplashScreen.iconSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: kSpacing24),
              Text(
                'EMI Calculator',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: kSpacingXS),
              Text(
                'by $kAppAuthor',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kSpacingXS),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: kSpacing40),
            ],
          ),
        ),
      ),
    );
  }
}
