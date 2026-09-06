import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/amortization_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/provider_fakes.dart';

void main() {
  ProviderContainer makeContainer({LoanInput? initial}) =>
      ProviderContainer.test(
        overrides: [
          loanRepositoryProvider.overrideWithValue(
            FakeLoanRepository(initial: initial),
          ),
          calcDebounceProvider.overrideWithValue(Duration.zero),
        ],
      );

  test('derives monthly + yearly schedule lengths from the result', () async {
    final container = makeContainer();

    final view = await container.read(amortizationProvider.future);

    expect(view.monthly.length, 240);
    expect(view.yearly.length, 20);
    expect(view.yearly.first.period, 1);
    expect(view.yearly.last.outstandingBalance, 0);
  });

  test('handles a tenure that is not a whole number of years', () async {
    final container = makeContainer(
      initial: const LoanInput(
        principal: 500000,
        annualRate: 11,
        tenureMonths: 30,
        loanType: LoanType.personal,
      ),
    );

    final view = await container.read(amortizationProvider.future);

    expect(view.monthly.length, 30);
    expect(view.yearly.length, 3, reason: '12 + 12 + 6');
  });

  test('break-even indices match the domain crossover use case', () async {
    // Home Loan default: monthly crossover at index 142, yearly at index 12
    // (TASKS.md 1.4 decision).
    final container = makeContainer();

    final view = await container.read(amortizationProvider.future);

    expect(view.monthlyBreakEvenIndex, 142);
    expect(view.yearlyBreakEvenIndex, 12);
  });

  test('zero-interest loan breaks even on the first row', () async {
    final container = makeContainer(
      initial: const LoanInput(
        principal: 120000,
        annualRate: 0,
        tenureMonths: 12,
        loanType: LoanType.personal,
      ),
    );

    final view = await container.read(amortizationProvider.future);

    expect(view.monthlyBreakEvenIndex, 0);
    expect(view.yearlyBreakEvenIndex, 0);
  });

  test('recomputes when the input changes', () async {
    final container = makeContainer();
    await container.read(amortizationProvider.future);

    container.read(loanInputProvider.notifier).setLoanType(LoanType.car);
    final view = await container.read(amortizationProvider.future);

    expect(view.monthly.length, 60);
    expect(view.yearly.length, 5);
  });
}
