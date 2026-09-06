import 'package:emi_calculator/features/calculator/data/datasources/loan_local_datasource.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LoanLocalDataSourceImpl dataSource;

  Future<void> resetPrefs([Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    prefs = await SharedPreferences.getInstance();
    dataSource = LoanLocalDataSourceImpl(prefs);
  }

  setUp(resetPrefs);

  group('LoanLocalDataSourceImpl — last input', () {
    test('readLastInput returns null on a fresh install', () async {
      expect(await dataSource.readLastInput(), isNull);
    });

    test('write then read returns an identical input (DoD 2.1)', () async {
      for (final input in const [
        LoanInput(
          principal: 3000000,
          annualRate: 8.5,
          tenureMonths: 240,
          loanType: LoanType.home,
        ),
        LoanInput(
          principal: 812345.67,
          annualRate: 9.05,
          tenureMonths: 61,
          loanType: LoanType.car,
        ),
        LoanInput(
          principal: 300000,
          annualRate: 13,
          tenureMonths: 36,
          loanType: LoanType.personal,
        ),
      ]) {
        await dataSource.writeLastInput(input);
        expect(await dataSource.readLastInput(), input);
      }
    });

    test('writeLastInput overwrites the previous value', () async {
      await dataSource.writeLastInput(
        const LoanInput(
          principal: 3000000,
          annualRate: 8.5,
          tenureMonths: 240,
          loanType: LoanType.home,
        ),
      );
      const updated = LoanInput(
        principal: 500000,
        annualRate: 11,
        tenureMonths: 48,
        loanType: LoanType.personal,
      );
      await dataSource.writeLastInput(updated);
      expect(await dataSource.readLastInput(), updated);
    });

    test(
      'persists across a new data-source instance (simulated restart)',
      () async {
        const input = LoanInput(
          principal: 1500000,
          annualRate: 7.25,
          tenureMonths: 120,
          loanType: LoanType.home,
        );
        await dataSource.writeLastInput(input);

        final reopened = LoanLocalDataSourceImpl(
          await SharedPreferences.getInstance(),
        );
        expect(await reopened.readLastInput(), input);
      },
    );

    test('readLastInput returns null for a corrupt blob', () async {
      await resetPrefs({
        LoanLocalDataSourceImpl.lastInputKey: 'not-json-at-all',
      });
      expect(await dataSource.readLastInput(), isNull);
    });

    test(
      'readLastInput returns null for a well-formed but invalid blob',
      () async {
        await resetPrefs({
          LoanLocalDataSourceImpl.lastInputKey:
              '{"principal": 1, "loanType": 2}',
        });
        expect(await dataSource.readLastInput(), isNull);
      },
    );
  });

  group('LoanLocalDataSourceImpl — theme mode', () {
    test('readThemeMode returns null when never set', () async {
      expect(await dataSource.readThemeMode(), isNull);
    });

    test('write then read round-trips every ThemeMode', () async {
      for (final mode in ThemeMode.values) {
        await dataSource.writeThemeMode(mode);
        expect(await dataSource.readThemeMode(), mode);
      }
    });

    test(
      'readThemeMode returns null for an unrecognised stored value',
      () async {
        await resetPrefs({
          LoanLocalDataSourceImpl.themeModeKey: 'sepia',
        });
        expect(await dataSource.readThemeMode(), isNull);
      },
    );

    test('theme mode and last input are stored independently', () async {
      const input = LoanInput(
        principal: 300000,
        annualRate: 13,
        tenureMonths: 36,
        loanType: LoanType.personal,
      );
      await dataSource.writeLastInput(input);
      await dataSource.writeThemeMode(ThemeMode.dark);

      expect(await dataSource.readLastInput(), input);
      expect(await dataSource.readThemeMode(), ThemeMode.dark);
    });
  });
}
