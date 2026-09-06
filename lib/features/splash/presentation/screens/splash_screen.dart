import 'dart:async';

import 'package:emi_calculator/core/constants/app_info.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen (SOW §5.1).
///
/// App icon (80×80dp, centred), the "EMI Calculator" headline, a muted
/// "by Softpital" by-line and a 2dp [LinearProgressIndicator], over a vertical
/// gradient derived from the primary colour. After 1.5s it auto-navigates to
/// `/calculator`.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  /// How long the splash is shown before navigating on (SOW §5.1).
  static const Duration displayDuration = Duration(milliseconds: 1500);

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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // SOW §5.1 calls for a "Primary 600 → Primary 800" gradient. The §6.1
    // palette only defines a single `primary` token (no discrete 600/800
    // steps), so both stops are derived from it: a lighter tint for the top
    // (≈600) and a darker shade for the bottom (≈800).
    final gradientTop = Color.lerp(scheme.primary, Colors.white, 0.12)!;
    final gradientBottom = Color.lerp(scheme.primary, Colors.black, 0.24)!;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientTop, gradientBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.calculate, size: 80, color: scheme.onPrimary),
              const SizedBox(height: kSpacingLG),
              Text(
                'EMI Calculator',
                style: textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: kSpacingXS),
              Text(
                'by $kAppAuthor',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              const SizedBox(
                height: 2,
                child: LinearProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
