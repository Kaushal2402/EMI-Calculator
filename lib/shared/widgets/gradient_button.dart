import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// The app's primary CTA — a full-width pill with the brand bright-blue →
/// deep-blue gradient (client palette, 2026-09-06) and white label.
///
/// Falls back to a flat disabled surface when [onPressed] is null. Ripple and
/// the 52dp min height match `filledButtonTheme` so it drops in where a
/// `FilledButton` was.
class GradientButton extends StatelessWidget {
  /// Creates a [GradientButton].
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  /// Button text (rendered in `labelLarge`, letter-spaced).
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Tap handler; null disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(AppSizes.radiusLG);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.ctaGradient,
                )
              : null,
          color: enabled ? null : theme.colorScheme.surfaceContainerHighest,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.seed.withValues(alpha: 0.32),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSizes.ctaButtonHeight,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: kSpacingLG),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: enabled
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: kSpacingSM),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 0.5,
                      color: enabled
                          ? Colors.white
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
