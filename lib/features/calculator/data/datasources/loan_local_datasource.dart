import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Data-layer contract for the calculator feature's local persistence,
/// backed by `SharedPreferences` (SOW §7.5).
///
/// This is a plain interface — the concrete `SharedPreferences`-backed
/// implementation lands in task 2.1 (`LoanLocalDataSourceImpl`). Keeping the
/// contract separate lets `LoanRepositoryImpl` and its tests depend on an
/// abstraction rather than a specific storage plugin.
abstract interface class LoanLocalDataSource {
  /// Reads the persisted loan input, or `null` if nothing has been stored yet.
  ///
  /// Implementations serialise/deserialise [LoanInput] to primitive
  /// `SharedPreferences` values internally; callers only ever see the entity.
  Future<LoanInput?> readLastInput();

  /// Writes [input] to local storage, overwriting any previous value.
  Future<void> writeLastInput(LoanInput input);
}
