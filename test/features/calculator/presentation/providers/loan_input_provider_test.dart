import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/provider_fakes.dart';

void main() {
  ProviderContainer containerWith(FakeLoanRepository repo) =>
      ProviderContainer.test(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
      );

  group('loanInputProvider — async init', () {
    test('restores the persisted input from the repository', () async {
      const persisted = LoanInput(
        principal: 750000,
        annualRate: 10.4,
        tenureMonths: 84,
        loanType: LoanType.car,
      );
      final container = containerWith(FakeLoanRepository(initial: persisted));

      final restored = await container.read(loanInputProvider.future);

      expect(restored, persisted);
    });

    test('falls back to the Home Loan preset on a cold start', () async {
      final container = containerWith(FakeLoanRepository());

      final input = await container.read(loanInputProvider.future);

      expect(input.loanType, LoanType.home);
      expect(input.principal, 3000000);
      expect(input.annualRate, 8.5);
      expect(input.tenureMonths, 240);
    });
  });

  group('loanInputProvider — field mutators', () {
    test(
      'setPrincipal / setAnnualRate / setTenureMonths patch one field',
      () async {
        final container = containerWith(FakeLoanRepository());
        await container.read(loanInputProvider.future);
        container.read(loanInputProvider.notifier)
          ..setPrincipal(1234567)
          ..setAnnualRate(9.25)
          ..setTenureMonths(180);

        final input = container.read(loanInputProvider).value!;
        expect(input.principal, 1234567);
        expect(input.annualRate, 9.25);
        expect(input.tenureMonths, 180);
        expect(input.loanType, LoanType.home, reason: 'type is untouched');
      },
    );

    test('setInput replaces the whole value', () async {
      final container = containerWith(FakeLoanRepository());
      await container.read(loanInputProvider.future);

      const replacement = LoanInput(
        principal: 500000,
        annualRate: 11,
        tenureMonths: 48,
        loanType: LoanType.personal,
      );
      container.read(loanInputProvider.notifier).setInput(replacement);

      expect(container.read(loanInputProvider).value, replacement);
    });
  });

  group('loanInputProvider — setLoanType (AC-05)', () {
    test("resets every field to the selected type's presets", () async {
      final container = containerWith(FakeLoanRepository());
      await container.read(loanInputProvider.future);

      // Dirty the form first, then switch tab.
      container.read(loanInputProvider.notifier)
        ..setPrincipal(99)
        ..setAnnualRate(1)
        ..setTenureMonths(12)
        ..setLoanType(LoanType.personal);

      final input = container.read(loanInputProvider).value!;
      expect(input.loanType, LoanType.personal);
      expect(input.principal, 300000);
      expect(input.annualRate, 13);
      expect(input.tenureMonths, 36);
    });

    test('car preset', () async {
      final container = containerWith(FakeLoanRepository());
      await container.read(loanInputProvider.future);

      container.read(loanInputProvider.notifier).setLoanType(LoanType.car);

      final input = container.read(loanInputProvider).value!;
      expect(input.principal, 800000);
      expect(input.annualRate, 9);
      expect(input.tenureMonths, 60);
    });
  });
}
