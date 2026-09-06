import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Domain contract for persisting and restoring the user's most recent loan
/// inputs (SOW §7.5).
///
/// The implementation lives in the data layer
/// (`LoanRepositoryImpl` → `LoanLocalDataSource` → `SharedPreferences`).
/// Nothing in this file may import Flutter, `shared_preferences`, or any other
/// plugin — the domain depends only on its own entities.
abstract interface class LoanRepository {
  /// Restores the last persisted [LoanInput].
  ///
  /// Returns `null` on first launch (nothing stored yet). Implementations must
  /// not throw for a missing value; other I/O failures may surface as an
  /// exception for the caller to handle.
  Future<LoanInput?> getLastInput();

  /// Persists [input] as the most recent calculation, replacing any previously
  /// stored value. Called after every successful calculation (SOW §7.5).
  Future<void> saveLastInput(LoanInput input);
}
