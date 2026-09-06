import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/metric_tile.dart';
import 'package:flutter/material.dart';

/// Outlined summary card holding the three headline metrics (SOW §4.6 / §5.3).
///
/// Layout per the §5.3 spacing table: outer horizontal margin is the screen
/// padding (16dp), inner padding `py=20 / px=16`, elevation 0 (outlined), 12dp
/// radius (all from `cardTheme`), 8dp gap between tiles.
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: kSpacingXL,
          horizontal: kSpacingLG,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MetricTile(
                label: 'Monthly EMI',
                value: monthlyEmi.toIndianCurrency(),
              ),
            ),
            const SizedBox(width: kSpacingSM),
            Expanded(
              child: MetricTile(
                label: 'Total Interest',
                value: totalInterest.toIndianCurrency(),
              ),
            ),
            const SizedBox(width: kSpacingSM),
            Expanded(
              child: MetricTile(
                label: 'Total Payable',
                value: totalPayable.toIndianCurrency(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
