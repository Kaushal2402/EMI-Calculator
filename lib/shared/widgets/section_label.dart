import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// Small ALL-CAPS section label used above form field groups (SOW §5.2).
///
/// Renders with `labelMedium`, uppercase, `0.08em` tracking and the muted
/// `onSurfaceVariant` colour.
class SectionLabel extends StatelessWidget {
  /// Creates a section label.
  const SectionLabel(this.text, {super.key});

  /// The label text (will be upper-cased).
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing:
            (theme.textTheme.labelMedium?.fontSize ?? 12) * kCapsLetterSpacing,
      ),
    );
  }
}
