import 'package:emi_calculator/features/calculator/data/models/loan_input_dto.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Data-layer contract for the calculator feature's local persistence,
/// backed by `SharedPreferences` (SOW §7.5).
///
/// Keeping the contract separate lets `LoanRepositoryImpl` and its tests depend
/// on an abstraction rather than a specific storage plugin. Implementations
/// serialise/deserialise [LoanInput] to primitive `SharedPreferences` values
/// internally; callers only ever see the entity (and [ThemeMode]).
abstract interface class LoanLocalDataSource {
  /// Reads the persisted loan input, or `null` if nothing has been stored yet
  /// (first launch) or the stored blob is unreadable / from an incompatible
  /// schema.
  Future<LoanInput?> readLastInput();

  /// Writes [input] to local storage, overwriting any previous value.
  Future<void> writeLastInput(LoanInput input);

  /// Reads the persisted theme preference, or `null` if the user has never
  /// changed it (SOW §7.5).
  Future<ThemeMode?> readThemeMode();

  /// Persists the user's [mode] theme preference (SOW §7.5).
  Future<void> writeThemeMode(ThemeMode mode);
}

/// `SharedPreferences`-backed implementation of [LoanLocalDataSource]
/// (SOW §7.5, task 2.1).
class LoanLocalDataSourceImpl implements LoanLocalDataSource {
  /// Creates the data source with an already-resolved [SharedPreferences].
  const LoanLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  /// Key holding the last calculation's inputs as a JSON string.
  static const String lastInputKey = 'calculator.last_input';

  /// Key holding the persisted [ThemeMode] as its enum name.
  static const String themeModeKey = 'settings.theme_mode';

  @override
  Future<LoanInput?> readLastInput() async {
    final raw = _prefs.getString(lastInputKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return LoanInputDto.decode(raw).toEntity();
    } on FormatException {
      // Corrupt or incompatible blob — treat as first launch rather than crash.
      return null;
    }
  }

  @override
  Future<void> writeLastInput(LoanInput input) async {
    await _prefs.setString(
      lastInputKey,
      LoanInputDto.fromEntity(input).encode(),
    );
  }

  @override
  Future<ThemeMode?> readThemeMode() async {
    final name = _prefs.getString(themeModeKey);
    if (name == null) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }

  @override
  Future<void> writeThemeMode(ThemeMode mode) async {
    await _prefs.setString(themeModeKey, mode.name);
  }
}
