import 'package:emi_calculator/core/constants/app_info.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// Info / About bottom sheet (SOW §5.4).
///
/// Presented as a modal bottom sheet by the `/info` route (see
/// `app_router.dart`): drag-to-dismiss, capped at 60% of screen height, with a
/// drag handle. This widget owns only the scrollable content — the formula
/// (SOW §4.3), a plain-language explanation of how the EMI is computed, and the
/// app version.
class InfoBottomSheet extends StatelessWidget {
  /// Creates the info bottom sheet content.
  const InfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final muted = textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          kSpacingLG,
          0,
          kSpacingLG,
          kSpacing24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('About EMI Calculator', style: textTheme.headlineSmall),
            const SizedBox(height: kSpacingLG),
            Text('The formula', style: textTheme.titleMedium),
            const SizedBox(height: kSpacingSM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kSpacingMD),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(
                'EMI = P × r × (1 + r)ⁿ / ((1 + r)ⁿ − 1)',
                style: textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: kSpacingMD),
            Text(
              'Where P is the principal loan amount, r is the monthly interest '
              'rate (annual rate ÷ 12 ÷ 100), and n is the loan tenure in '
              'months.',
              style: muted,
            ),
            const SizedBox(height: kSpacing24),
            Text('How the EMI is computed', style: textTheme.titleMedium),
            const SizedBox(height: kSpacingSM),
            Text(
              'Every month you pay the same instalment (the EMI). Part of it '
              'covers the interest charged on the outstanding balance for that '
              'month, and the rest reduces the principal you still owe. Early '
              'on, most of the EMI is interest; as the balance falls, more of '
              'each payment goes towards principal until the loan is fully '
              'repaid.\n\n'
              'Total Interest = EMI × n − P\n'
              'Total Payable = P + Total Interest',
              style: muted,
            ),
            const SizedBox(height: kSpacing24),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: kSpacingMD),
            Text(
              'EMI Calculator v$kAppVersion',
              style: textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: kSpacingXS),
            Text(
              'by $kAppAuthor',
              style: textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
