import 'dart:async';

import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the pure [CalculateEmiUseCase].
final Provider<CalculateEmiUseCase> calculateEmiUseCaseProvider =
    Provider<CalculateEmiUseCase>((ref) => const CalculateEmiUseCase());

/// Debounce window before a settled input triggers a recalculation
/// (SOW §4.2, 150 ms). Exposed as a provider so tests can shrink it to
/// [Duration.zero] for immediate results, or set a small non-zero value to
/// assert coalescing deterministically.
final Provider<Duration> calcDebounceProvider = Provider<Duration>(
  (ref) => kCalcDebounce,
);

/// Runs [CalculateEmiUseCase] for the current [loanInputProvider] state
/// (SOW §7.2 `emiResultProvider`).
///
/// Pure derivation — no persistence here (that is
/// `calculationPersistenceProvider`, task 3.5).
///
/// ## Debounce (SOW §4.2)
///
/// Each change to [loanInputProvider] re-runs this provider. Riverpod disposes
/// the previous run first, firing the `onDispose` below and flipping
/// `cancelled`. The new run waits [calcDebounceProvider] before touching the
/// use case, so a burst of rapid edits collapses to a single calculation for
/// the value the user settles on. The aborted runs return early and their
/// results are discarded.
final FutureProvider<EmiResult> emiResultProvider = FutureProvider<EmiResult>((
  ref,
) async {
  final input = await ref.watch(loanInputProvider.future);

  final debounce = ref.watch(calcDebounceProvider);
  if (debounce > Duration.zero) {
    var cancelled = false;
    ref.onDispose(() => cancelled = true);
    await Future<void>.delayed(debounce);
    if (cancelled) {
      // Superseded by a newer input — bail without running the calculation.
      return Completer<EmiResult>().future;
    }
  }

  return ref.watch(calculateEmiUseCaseProvider).execute(input);
});
