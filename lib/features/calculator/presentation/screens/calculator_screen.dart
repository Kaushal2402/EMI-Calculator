import 'dart:async';

import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/interstitial_ad_controller.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/tenure_unit_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/admob_banner_widget.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amount_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/loan_type_selector.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/rate_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/tenure_input_field.dart';
import 'package:emi_calculator/shared/widgets/app_scaffold.dart';
import 'package:emi_calculator/shared/widgets/error_view.dart';
import 'package:emi_calculator/shared/widgets/gradient_button.dart';
import 'package:emi_calculator/shared/widgets/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home / Calculator screen (SOW §5.2).
///
/// Loan-type selector + Principal / Rate / Tenure inputs, each a synced
/// TextField + Slider, grouped in one card. A live EMI estimate updates under
/// the form as inputs change (`emiResultProvider`); CALCULATE EMI opens the
/// full breakdown on `/results`.
class CalculatorScreen extends ConsumerWidget {
  /// Creates the calculator screen.
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inputAsync = ref.watch(loanInputProvider);

    return AppScaffold(
      title: 'EMI Calculator',
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'About',
          onPressed: () => context.push(AppRoutes.info),
        ),
      ],
      // Pinned bottom stack: the primary CTA stays reachable without scrolling,
      // and the AdMob banner sits below it, owning the safe-area inset and
      // collapsing on a load failure (SOW §4.8).
      bottomNavigationBar: switch (inputAsync) {
        AsyncData() => const _BottomBar(),
        _ => const AdmobBannerWidget(),
      },
      body: switch (inputAsync) {
        AsyncData(:final value) => _CalculatorForm(input: value),
        AsyncError(:final error) => ErrorView(message: '$error'),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Sticky bottom area: hairline, the CALCULATE EMI CTA, then the banner slot.
class _BottomBar extends ConsumerWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final result = ref.watch(emiResultProvider);
    final canCalculate = !result.hasError;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: scheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            kSpacingLG,
            kSpacingMD,
            kSpacingLG,
            kSpacingMD,
          ),
          child: GradientButton(
            label: 'CALCULATE EMI',
            icon: Icons.calculate_outlined,
            onPressed: canCalculate
                ? () async {
                    // Every-5th-calculation interstitial boundary (SOW §4.8,
                    // task 7.4). Always resolves; navigation follows regardless.
                    await ref
                        .read(interstitialAdControllerProvider)
                        .maybeShowAtBoundary();
                    if (context.mounted) {
                      unawaited(context.push(AppRoutes.results));
                    }
                  }
                : null,
          ),
        ),
        const AdmobBannerWidget(),
      ],
    );
  }
}

class _CalculatorForm extends ConsumerWidget {
  const _CalculatorForm({required this.input});

  final LoanInput input;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(tenureUnitProvider);
    final notifier = ref.read(loanInputProvider.notifier);

    // Keep the debounced engine warm so /results paints immediately (AC-03).
    final liveEmi = ref.watch(emiResultProvider).value?.monthlyEmi;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: kSpacingLG),
          const LoanTypeSelector(),
          const SizedBox(height: kSpacingLG),

          _FormCard(
            children: [
              const SectionLabel('Principal Amount'),
              const SizedBox(height: kSpacingSM),
              AmountInputField(
                value: input.principal,
                onChanged: notifier.setPrincipal,
              ),
              const SizedBox(height: kSpacing24),
              const SectionLabel('Annual Interest Rate'),
              const SizedBox(height: kSpacingSM),
              RateInputField(
                value: input.annualRate,
                onChanged: notifier.setAnnualRate,
              ),
              const SizedBox(height: kSpacing24),
              const SectionLabel('Loan Tenure'),
              const SizedBox(height: kSpacingSM),
              TenureInputField(
                months: input.tenureMonths,
                unit: unit,
                onMonthsChanged: notifier.setTenureMonths,
                onUnitChanged: ref.read(tenureUnitProvider.notifier).select,
              ),
            ],
          ),

          const SizedBox(height: kSpacingLG),
          _LiveEmiCard(monthlyEmi: liveEmi),
          const SizedBox(height: kSpacingLG),
        ],
      ),
    );
  }
}

/// The single card that groups the three input sections.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(kSpacingLG),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Live EMI estimate that recalculates as the inputs change (SOW §4.2).
class _LiveEmiCard extends StatelessWidget {
  const _LiveEmiCard({required this.monthlyEmi});

  final double? monthlyEmi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = scheme.onPrimaryContainer;
    final value = monthlyEmi == null ? '—' : monthlyEmi!.toIndianCurrency();

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: kSpacingLG,
        horizontal: kSpacingXL,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ESTIMATED MONTHLY EMI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.8),
                    letterSpacing:
                        (theme.textTheme.labelSmall?.fontSize ?? 11) *
                        kCapsLetterSpacing,
                  ),
                ),
                const SizedBox(height: kSpacingXS),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: kSpacingMD),
          Icon(Icons.trending_up_rounded, color: fg.withValues(alpha: 0.9)),
        ],
      ),
    );
  }
}
