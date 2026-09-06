import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/selected_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home / Car / Personal loan tab bar (SOW §4.1, §5.2).
///
/// A segmented pill control: the track is `surfaceContainerHighest`, the active
/// tab is a raised `surface` pill in the brand `primary` colour. Switching a
/// tab delegates to [SelectedTabNotifier.select], which resets every input to
/// that loan type's preset defaults (AC-05).
class LoanTypeSelector extends ConsumerWidget {
  /// Creates a [LoanTypeSelector].
  const LoanTypeSelector({super.key});

  static const _tabs = <(LoanType, String, IconData)>[
    (LoanType.home, 'Home', Icons.home_rounded),
    (LoanType.car, 'Car', Icons.directions_car_rounded),
    (LoanType.personal, 'Personal', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(selectedTabProvider);

    return Container(
      padding: const EdgeInsets.all(kSpacingXS),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          for (final (type, label, icon) in _tabs)
            Expanded(
              child: _Tab(
                label: label,
                icon: icon,
                selected: type == selected,
                onTap: () =>
                    ref.read(selectedTabProvider.notifier).select(type),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: kSpacingXS),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
