import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// Info / About bottom sheet (SOW §5.4).
///
/// PHASE 0 SCAFFOLD: static content only. Task 6.1 makes it a real
/// drag-to-dismiss modal capped at 60% screen height and pulls the app
/// version from `package_info`.
class InfoBottomSheet extends StatelessWidget {
  /// Creates the info bottom sheet.
  const InfoBottomSheet({super.key});

  /// Shows this sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.6,
      ),
      builder: (_) => const InfoBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(kSpacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How EMI is calculated', style: theme.textTheme.titleLarge),
            const SizedBox(height: kSpacingMD),
            Text(
              'EMI = P × r × (1 + r)^n / ((1 + r)^n − 1)\n\n'
              'P = principal, r = monthly interest rate (annual / 12 / 100), '
              'n = tenure in months.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: kSpacing24),
            Text(
              'EMI Calculator by Softpital',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
