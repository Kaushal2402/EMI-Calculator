import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the [CalculateEmiUseCase].
final Provider<CalculateEmiUseCase> calculateEmiUseCaseProvider =
    Provider<CalculateEmiUseCase>((ref) => const CalculateEmiUseCase());

/// Runs the EMI calculation for the current [loanInputProvider] state
/// (SOW §7.2 `emiResultProvider`).
///
/// PHASE 0 SCAFFOLD: straight pass-through. The 150 ms debounce (SOW §4.2)
/// and yearly aggregation are added in tasks 3.3 / 3.4.
final Provider<EmiResult> emiResultProvider = Provider<EmiResult>((ref) {
  final input = ref.watch(loanInputProvider);
  return ref.watch(calculateEmiUseCaseProvider).execute(input);
});
