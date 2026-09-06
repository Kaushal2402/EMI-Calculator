import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// One label/value pair inside `SummaryCard` (SOW §4.6 / §5.3).
///
/// * Value — `titleLarge` (22sp Poppins) bumped to bold, tabular figures so
///   digits stay column-aligned across the tiles. With [emphasis] it steps up
///   to `headlineMedium` (28sp) for the headline Monthly-EMI figure.
/// * Label — `labelSmall` (11sp), muted `onSurfaceVariant` (or [foreground]
///   when the tile sits on a coloured panel), ALL CAPS with `0.08em` tracking
///   (SOW §6.2).
///
/// The value shrinks to fit (never wraps or overflows) so the tile survives
/// large text scales and long amounts.
class MetricTile extends StatelessWidget {
  /// Creates a [MetricTile].
  const MetricTile({
    required this.label,
    required this.value,
    this.emphasis = false,
    this.foreground,
    super.key,
  });

  /// Caption shown under the value, e.g. `Monthly EMI`.
  final String label;

  /// Pre-formatted, display-rounded value, e.g. `₹26,035`.
  final String value;

  /// Renders the value one step larger — used for the headline Monthly EMI.
  final bool emphasis;

  /// Text colour override for tiles painted on a coloured panel (the hero).
  /// When null the value uses `onSurface` (via the ambient text theme) and the
  /// label uses `onSurfaceVariant`.
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor =
        foreground?.withValues(alpha: 0.75) ??
        theme.colorScheme.onSurfaceVariant;
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: labelColor,
      letterSpacing:
          (theme.textTheme.labelSmall?.fontSize ?? 11) * kCapsLetterSpacing,
    );
    final valueBase = emphasis
        ? theme.textTheme.headlineMedium
        : theme.textTheme.titleLarge;

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
              style: valueBase?.copyWith(
                color: foreground,
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
