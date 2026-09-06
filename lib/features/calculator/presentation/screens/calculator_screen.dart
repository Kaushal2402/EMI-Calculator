import 'dart:async';

import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/interstitial_ad_controller.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/tenure_unit_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amount_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/loan_type_selector.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/rate_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/tenure_input_field.dart';
import 'package:emi_calculator/shared/widgets/app_scaffold.dart';
import 'package:emi_calculator/shared/widgets/error_view.dart';
import 'package:emi_calculator/shared/widgets/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home / Calculator screen (SOW §5.2).
///
/// Loan-type selector + Principal / Rate / Tenure inputs, each a synced
/// TextField + Slider. Every change flows into `loanInputProvider`, which the
/// already-debounced `emiResultProvider` recalculates from (SOW §4.2). The
/// CALCULATE EMI button navigates to `/results`.
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
      body: switch (inputAsync) {
        AsyncData(:final value) => _CalculatorForm(input: value),
        AsyncError(:final error) => ErrorView(message: '$error'),
        _ => const Center(child: CircularProgressIndicator()),
      },
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

    // Keep the debounced engine warm so /results paints immediately (AC-03),
    // and disable the CTA only if the engine actually errors.
    final result = ref.watch(emiResultProvider);
    final canCalculate = !result.hasError;

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AppBar bottom to first widget (SOW §5.2 spacing table).
          const SizedBox(height: kSpacing24),
          const LoanTypeSelector(),

          // Selector -> first field group. The spacing table lists the first
          // section label at 0dp top margin and 20dp "between field groups";
          // the selector is treated as a group peer, so 20dp applies here too.
          const SizedBox(height: kSpacingXL),
          const SectionLabel('Principal Amount'),
          const SizedBox(height: kSpacingSM),
          AmountInputField(
            value: input.principal,
            onChanged: notifier.setPrincipal,
          ),

          const SizedBox(height: kSpacingXL),
          const SectionLabel('Annual Interest Rate'),
          const SizedBox(height: kSpacingSM),
          RateInputField(
            value: input.annualRate,
            onChanged: notifier.setAnnualRate,
          ),

          const SizedBox(height: kSpacingXL),
          const SectionLabel('Loan Tenure'),
          const SizedBox(height: kSpacingSM),
          TenureInputField(
            months: input.tenureMonths,
            unit: unit,
            onMonthsChanged: notifier.setTenureMonths,
            onUnitChanged: ref.read(tenureUnitProvider.notifier).select,
          ),

          const SizedBox(height: kSpacing32),
          FilledButton(
            onPressed: canCalculate
                ? () async {
                    // Boundary point for the every-5th-calculation interstitial
                    // (SOW §4.8, task 7.4). Always resolves; navigation follows
                    // whether or not an ad was shown.
                    await ref
                        .read(interstitialAdControllerProvider)
                        .maybeShowAtBoundary();
                    if (context.mounted) {
                      unawaited(context.push(AppRoutes.results));
                    }
                  }
                : null,
            child: const Text('CALCULATE EMI'),
          ),
          SizedBox(height: kSpacing24 + bottomInset),
        ],
      ),
    );
  }
}
