import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/metric_tile.dart';
import 'package:flutter/material.dart';

/// Headline metrics block on the Results screen (SOW §4.6 / §5.3).
///
/// The Monthly EMI is the hero — large white type on the brand gradient — with
/// Total Interest and Total Payable as two chips beneath, each tagged with the
/// donut-chart colour (blue = principal repaid drives the payable, gold =
/// interest) so the numbers and the chart read as one story.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: kSpacingXL,
            horizontal: kSpacingXL,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.brandGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.seed.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Monthly EMI',
                  value: monthlyEmi.toIndianCurrency(),
                  emphasis: true,
                  foreground: Colors.white,
                ),
              ),
              const SizedBox(width: kSpacingMD),
              Container(
                padding: const EdgeInsets.all(kSpacingMD),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
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
                dot: AppColors.interestSegment(scheme),
              ),
            ),
            const SizedBox(width: kSpacingMD),
            Expanded(
              child: _SubTile(
                label: 'Total Payable',
                value: totalPayable.toIndianCurrency(),
                dot: AppColors.principalSegment(scheme),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A secondary metric chip, tagged with a colour dot.
class _SubTile extends StatelessWidget {
  const _SubTile({required this.label, required this.value, required this.dot});

  final String label;
  final String value;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: kSpacingLG,
        horizontal: kSpacingLG,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.swatchBorder(scheme)),
            ),
          ),
          const SizedBox(height: kSpacingSM),
          MetricTile(label: label, value: value),
        ],
      ),
    );
  }
}
