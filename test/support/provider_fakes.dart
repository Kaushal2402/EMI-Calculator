import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/data/datasources/loan_local_datasource.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/repositories/loan_repository.dart';
import 'package:flutter/material.dart' show ThemeMode;

/// In-memory [LoanRepository] for provider tests — no `SharedPreferences`,
/// no plugins. Records every [saveLastInput] call so tests can assert
/// "persisted exactly once".
class FakeLoanRepository implements LoanRepository {
  FakeLoanRepository({LoanInput? initial}) : _stored = initial;

  LoanInput? _stored;

  /// Every input passed to [saveLastInput], in order.
  final List<LoanInput> savedInputs = <LoanInput>[];

  int get saveCallCount => savedInputs.length;

  LoanInput? get lastSaved => savedInputs.isEmpty ? null : savedInputs.last;

  @override
  Future<LoanInput> getLastInput() async => _stored ?? firstLaunchLoanInput();

  @override
  Future<void> saveLastInput(LoanInput input) async {
    savedInputs.add(input);
    _stored = input;
  }
}

/// In-memory [LoanLocalDataSource] for provider tests.
class FakeLoanLocalDataSource implements LoanLocalDataSource {
  FakeLoanLocalDataSource({this.storedInput, this.storedThemeMode});

  LoanInput? storedInput;
  ThemeMode? storedThemeMode;
  int writeInputCallCount = 0;
  int writeThemeCallCount = 0;

  @override
  Future<LoanInput?> readLastInput() async => storedInput;

  @override
  Future<void> writeLastInput(LoanInput input) async {
    writeInputCallCount++;
    storedInput = input;
  }

  @override
  Future<ThemeMode?> readThemeMode() async => storedThemeMode;

  @override
  Future<void> writeThemeMode(ThemeMode mode) async {
    writeThemeCallCount++;
    storedThemeMode = mode;
  }
}
