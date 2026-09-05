import 'dart:async';

import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen (SOW §5.1).
///
/// PHASE 0 SCAFFOLD: layout + 1.5s auto-navigation are in place; final icon
/// art and exact gradient tuning happen in task 6.2.
class SplashScreen extends StatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
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
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary,
              Color.alphaBlend(Colors.black26, scheme.primary),
            ],
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
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: scheme.onPrimary),
              ),
              const SizedBox(height: kSpacingXS),
              Text(
                'by Softpital',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
