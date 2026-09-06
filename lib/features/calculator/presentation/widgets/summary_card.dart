import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/metric_tile.dart';
import 'package:flutter/material.dart';

/// Outlined summary card holding the three headline metrics (SOW §4.6 / §5.3).
///
/// Refreshed layout: the Monthly EMI is the hero — large type on a
/// `primaryContainer` panel — with Total Interest and Total Payable as two
/// secondary chips beneath it. Outer card is elevation 0 / 16dp radius / hairline
/// `outlineVariant` border (from `cardTheme`).
///
/// Takes plain unrounded `EmiResult` figures and applies the display rounding
/// itself (SOW §4.3): every rupee value is shown to the nearest ₹1 in the
/// Indian numeral system.
class SummaryCard extends StatelessWidget {
  /// Creates a [SummaryCard].
  const SummaryCard({
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalPayable,
    super.key,
  });

  /// Monthly instalment (unrounded).
  final double monthlyEmi;

  /// Total interest payable over the tenure (unrounded).
  final double totalInterest;

  /// Total amount payable (unrounded).
  final double totalPayable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(kSpacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: kSpacingXL,
                  horizontal: kSpacingLG,
                ),
                child: MetricTile(
                  label: 'Monthly EMI',
                  value: monthlyEmi.toIndianCurrency(),
                  emphasis: true,
                  foreground: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: kSpacingMD),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SubTile(
                    label: 'Total Interest',
                    value: totalInterest.toIndianCurrency(),
                  ),
                ),
                const SizedBox(width: kSpacingMD),
                Expanded(
                  child: _SubTile(
                    label: 'Total Payable',
                    value: totalPayable.toIndianCurrency(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A secondary metric on a `surfaceContainerHighest` chip.
class _SubTile extends StatelessWidget {
  const _SubTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingLG,
          horizontal: kSpacingMD,
        ),
        child: MetricTile(label: label, value: value),
      ),
    );
  }
}
