/// Composition-root providers for local persistence (SOW §7.5).
///
/// These sit in `core/` because they are shared infrastructure: the calculator
/// feature uses them for `LoanRepository`, and the info feature uses them for
/// the persisted `ThemeMode` (Phase 2.1 decision — one `LoanLocalDataSource`
/// owns both blobs).
library;

import 'package:emi_calculator/features/calculator/data/datasources/loan_local_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The resolved [SharedPreferences] instance.
///
/// Overridden in `main()` after `SharedPreferences.getInstance()` and in tests
/// with `SharedPreferences.setMockInitialValues`. The fallback throws so a
/// missing override fails loudly rather than silently no-op'ing persistence.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (ref) => throw UnimplementedError(
        'sharedPreferencesProvider must be overridden in main() and in tests',
      ),
    );

/// `SharedPreferences`-backed [LoanLocalDataSource] (SOW §7.5).
///
/// Override this directly in provider tests with an in-memory fake to avoid
/// the plugin channel entirely.
final Provider<LoanLocalDataSource> loanLocalDataSourceProvider =
    Provider<LoanLocalDataSource>(
      (ref) => LoanLocalDataSourceImpl(ref.watch(sharedPreferencesProvider)),
    );
