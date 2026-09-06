import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the pure [CalculateEmiUseCase].
final Provider<CalculateEmiUseCase> calculateEmiUseCaseProvider =
    Provider<CalculateEmiUseCase>((ref) => const CalculateEmiUseCase());

/// Runs [CalculateEmiUseCase] for the current [loanInputProvider] state
/// (SOW §7.2 `emiResultProvider`).
///
/// Pure derivation — no persistence here (that is
/// `calculationPersistenceProvider`, task 3.5). The 150 ms input debounce
/// (SOW §4.2) is layered on in task 3.3.
final FutureProvider<EmiResult> emiResultProvider = FutureProvider<EmiResult>((
  ref,
) async {
  final input = await ref.watch(loanInputProvider.future);
  return ref.watch(calculateEmiUseCaseProvider).execute(input);
});
