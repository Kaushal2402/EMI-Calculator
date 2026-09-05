import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Local persistence for the calculator feature, backed by
/// `SharedPreferences` (SOW §7.5).
///
/// PHASE 0 SCAFFOLD: contract only. Implementation lands in task 2.1.
abstract interface class LoanLocalDataSource {
  /// Reads the persisted [LoanInput], or `null` if nothing is stored.
  Future<LoanInput?> readLastInput();

  /// Writes [input] to local storage.
  Future<void> writeLastInput(LoanInput input);
}
