import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// One label/value pair inside `SummaryCard` (SOW §4.6 / §5.3).
///
/// * Value — `titleLarge` (22sp Poppins) bumped to bold, tabular figures so
///   digits stay column-aligned across the three tiles.
/// * Label — `labelSmall` (11sp), muted `onSurfaceVariant`, ALL CAPS with
///   `0.08em` tracking (SOW §6.2).
///
/// The value shrinks to fit (never wraps or overflows) so the tile survives
/// large text scales and long amounts.
class MetricTile extends StatelessWidget {
  /// Creates a [MetricTile].
  const MetricTile({
    required this.label,
    required this.value,
    super.key,
  });

  /// Caption shown under the value, e.g. `Monthly EMI`.
  final String label;

  /// Pre-formatted, display-rounded value, e.g. `₹26,035`.
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing:
          (theme.textTheme.labelSmall?.fontSize ?? 11) * kCapsLetterSpacing,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
        const SizedBox(height: kSpacingXS),
        Text(label.toUpperCase(), style: labelStyle),
      ],
    );
  }
}
