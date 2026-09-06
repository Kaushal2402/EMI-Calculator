import 'dart:async';

import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Animated donut chart comparing principal repaid vs interest paid
/// (SOW §4.5 / §5.3).
///
/// * 200dp diameter donut. Principal segment = `primary`, interest segment =
///   `secondary` (design tokens).
/// * Centre shows the total amount payable in large type (shrink-to-fit so it
///   never clips the donut hole or overflows at large text scales).
/// * Legend below (12dp gap): swatch + name + percentage + absolute value per
///   segment, 8dp vertical gap between rows.
///
/// ## Animation (SOW §4.5)
///
/// A single [AnimationController] sweeps the donut from empty to full over
/// 1200ms ease-in-out on first mount. Because the fl_chart [PieChart] is fed
/// pre-interpolated values with `duration: Duration.zero`, later prop changes
/// (slider drags on a still-mounted chart) snap instantly with no re-animation
/// — the controller is already completed so the sweep factor stays at 1.
class EmiChart extends StatefulWidget {
  /// Creates an [EmiChart].
  const EmiChart({
    required this.principal,
    required this.interest,
    required this.totalPayable,
    super.key,
  });

  /// Principal amount (absolute ₹, unrounded).
  final double principal;

  /// Total interest payable (absolute ₹, unrounded).
  final double interest;

  /// Total amount payable (absolute ₹, unrounded) — shown in the centre.
  final double totalPayable;

  @override
  State<EmiChart> createState() => _EmiChartState();
}

class _EmiChartState extends State<EmiChart>
    with SingleTickerProviderStateMixin {
  static const double _sectionRadius = 32;

  late final AnimationController _controller;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _sweep = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final total = widget.principal + widget.interest;
    // Whole-number percentages that always sum to 100.
    final principalPct = total <= 0
        ? 0
        : (widget.principal / total * 100).round();
    final interestPct = 100 - principalPct;

    return Column(
      children: [
        SizedBox(
          width: AppSizes.chartDiameter,
          height: AppSizes.chartDiameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _sweep,
                builder: (context, _) {
                  final f = _sweep.value;
                  final principalValue = widget.principal * f;
                  final interestValue = widget.interest * f;
                  final remaining = total * (1 - f);
                  return PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: f == 1 ? 2 : 0,
                      centerSpaceRadius:
                          AppSizes.chartDiameter / 2 - _sectionRadius,
                      sections: [
                        PieChartSectionData(
                          value: principalValue,
                          color: scheme.primary,
                          radius: _sectionRadius,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: interestValue,
                          color: scheme.secondary,
                          radius: _sectionRadius,
                          showTitle: false,
                        ),
                        if (remaining > 0)
                          PieChartSectionData(
                            value: remaining,
                            color: scheme.surfaceContainerHighest,
                            radius: _sectionRadius,
                            showTitle: false,
                          ),
                      ],
                    ),
                    duration: Duration.zero,
                  );
                },
              ),
              _CentreLabel(total: widget.totalPayable),
            ],
          ),
        ),
        const SizedBox(height: kSpacingMD),
        _LegendRow(
          color: scheme.primary,
          name: 'Principal',
          percent: principalPct,
          amount: widget.principal,
        ),
        const SizedBox(height: kSpacingSM),
        _LegendRow(
          color: scheme.secondary,
          name: 'Interest',
          percent: interestPct,
          amount: widget.interest,
        ),
      ],
    );
  }
}

class _CentreLabel extends StatelessWidget {
  const _CentreLabel({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TOTAL PAYABLE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing:
                (theme.textTheme.labelSmall?.fontSize ?? 11) *
                kCapsLetterSpacing,
          ),
        ),
        const SizedBox(height: kSpacingXS),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 132),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              total.toIndianCurrency(),
              maxLines: 1,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.name,
    required this.percent,
    required this.amount,
  });

  final Color color;
  final String name;
  final int percent;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            // Hairline so a light gold swatch keeps a 3:1 boundary on a light
            // surface (WCAG 1.4.11, AC-09).
            border: Border.all(
              color: AppColors.swatchBorder(theme.colorScheme),
            ),
          ),
        ),
        const SizedBox(width: kSpacingSM),
        Text(
          // Label text stays default `onSurface` — the coloured swatch (with
          // its hairline) carries the segment identity; the gold `secondary`
          // itself is too light to use as body text.
          name,
          style: theme.textTheme.bodyMedium,
        ),
        const Spacer(),
        Text('$percent%', style: valueStyle),
        const SizedBox(width: kSpacingMD),
        Text(amount.toIndianCurrency(), style: valueStyle),
      ],
    );
  }
}
