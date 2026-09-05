import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Results screen (SOW §5.3).
///
/// PHASE 0 SCAFFOLD: empty shell. Summary card, donut chart, amortization
/// table, share action and AdMob banner land in Phases 5–7.
class ResultsScreen extends ConsumerWidget {
  /// Creates the results screen.
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Results',
      leading: BackButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.calculator),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {},
        ),
      ],
      body: Center(
        child: Text(
          'Results — coming in Phase 5',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
