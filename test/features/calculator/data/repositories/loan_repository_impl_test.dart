import 'package:emi_calculator/features/calculator/data/datasources/loan_local_datasource.dart';
import 'package:emi_calculator/features/calculator/data/repositories/loan_repository_impl.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

/// In-memory [LoanLocalDataSource] — no `SharedPreferences`, no plugins.
class FakeLoanLocalDataSource implements LoanLocalDataSource {
  LoanInput? storedInput;
  ThemeMode? storedThemeMode;
  int writeInputCallCount = 0;

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
  Future<void> writeThemeMode(ThemeMode mode) async => storedThemeMode = mode;
}

void main() {
  late FakeLoanLocalDataSource fake;
  late LoanRepositoryImpl repository;

  setUp(() {
    fake = FakeLoanLocalDataSource();
    repository = LoanRepositoryImpl(fake);
  });

  group('LoanRepositoryImpl.getLastInput', () {
    test(
      'seeds Home Loan defaults on a fresh install (task 2.3 DoD)',
      () async {
        final input = await repository.getLastInput();

        expect(input.loanType, LoanType.home);
        expect(input.principal, 3000000); // ₹30,00,000
        expect(input.annualRate, 8.5); // 8.50% p.a.
        expect(input.tenureMonths, 240); // 20 years
      },
    );

    test('never returns null', () async {
      expect(await repository.getLastInput(), isNotNull);
    });

    test('returns the persisted input verbatim when one exists', () async {
      const persisted = LoanInput(
        principal: 750000,
        annualRate: 10.4,
        tenureMonths: 84,
        loanType: LoanType.car,
      );
      fake.storedInput = persisted;

      expect(await repository.getLastInput(), persisted);
    });
  });

  group('LoanRepositoryImpl.saveLastInput', () {
    test('delegates to the data source once', () async {
      const input = LoanInput(
        principal: 300000,
        annualRate: 13,
        tenureMonths: 36,
        loanType: LoanType.personal,
      );

      await repository.saveLastInput(input);

      expect(fake.writeInputCallCount, 1);
      expect(fake.storedInput, input);
    });

    test('a saved input is returned by the next getLastInput', () async {
      const input = LoanInput(
        principal: 4200000,
        annualRate: 8.75,
        tenureMonths: 300,
        loanType: LoanType.home,
      );

      await repository.saveLastInput(input);

      expect(await repository.getLastInput(), input);
    });
  });
}
