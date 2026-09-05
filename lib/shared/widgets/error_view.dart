import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// Generic centred error state with an optional retry action.
class ErrorView extends StatelessWidget {
  /// Creates an error view.
  const ErrorView({
    required this.message,
    this.onRetry,
    super.key,
  });

  /// Human-readable error message.
  final String message;

  /// Optional retry callback; when null no button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kSpacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 40,
            ),
            const SizedBox(height: kSpacingMD),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: kSpacingLG),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
