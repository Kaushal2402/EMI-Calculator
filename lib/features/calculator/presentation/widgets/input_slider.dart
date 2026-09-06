import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// A [Slider] with a min / max caption row 4dp below it (SOW §5.2).
///
/// Shared by `AmountInputField`, `RateInputField` and `TenureInputField` so the
/// slider + range-label spacing is defined in exactly one place.
class InputSlider extends StatelessWidget {
  /// Creates an input slider.
  const InputSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.minLabel,
    required this.maxLabel,
    this.divisions,
    this.semanticFormatterCallback,
    super.key,
  });

  /// Current value. Clamped into `[min, max]` before being handed to [Slider]
  /// so an out-of-range model value never throws.
  final double value;

  /// Slider lower bound.
  final double min;

  /// Slider upper bound.
  final double max;

  /// Discrete steps, or null for a continuous track.
  final int? divisions;

  /// Called with the new value on drag.
  final ValueChanged<double> onChanged;

  /// Caption under the left end of the track.
  final String minLabel;

  /// Caption under the right end of the track.
  final String maxLabel;

  /// Accessibility announcement for the current value.
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          semanticFormatterCallback: semanticFormatterCallback,
          onChanged: onChanged,
        ),
        const SizedBox(height: kSpacingXS),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpacingXS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: captionStyle),
              Text(maxLabel, style: captionStyle),
            ],
          ),
        ),
      ],
    );
  }
}
