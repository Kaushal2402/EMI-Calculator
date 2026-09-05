import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home / Calculator screen (SOW §5.2).
///
/// PHASE 0 SCAFFOLD: empty shell. Inputs, loan-type selector and real-time
/// calculation land in Phase 4.
class CalculatorScreen extends ConsumerWidget {
  /// Creates the calculator screen.
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'EMI Calculator',
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'About',
          onPressed: () => context.push(AppRoutes.info),
        ),
      ],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Calculator — coming in Phase 4',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: kSpacing24),
            FilledButton(
              onPressed: () => context.push(AppRoutes.results),
              child: const Text('CALCULATE EMI'),
            ),
          ],
        ),
      ),
    );
  }
}
