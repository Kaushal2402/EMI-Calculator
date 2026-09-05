import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Contract for persisting and restoring the user's last loan inputs
/// (SOW §7.5). Implemented in the data layer; the domain never sees
/// `SharedPreferences`.
///
/// PHASE 0 SCAFFOLD: interface shape only. Fleshed out in task 1.5.
abstract interface class LoanRepository {
  /// Restores the last saved [LoanInput], or `null` on first launch.
  Future<LoanInput?> getLastInput();

  /// Persists [input] as the most recent calculation.
  Future<void> saveLastInput(LoanInput input);
}
