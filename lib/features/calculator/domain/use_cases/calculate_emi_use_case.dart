import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Pure EMI calculation engine (SOW §4.3, §7.4).
///
/// PHASE 0 SCAFFOLD: signature only — throws until implemented in task 1.2.
/// This class must stay a pure function: no Flutter, no plugins, no I/O.
class CalculateEmiUseCase {
  /// Creates the use case.
  const CalculateEmiUseCase();

  /// Computes the EMI, totals, ratios and full amortization schedule for
  /// [input].
  EmiResult execute(LoanInput input) {
    throw UnimplementedError('CalculateEmiUseCase.execute — task 1.2');
  }
}
