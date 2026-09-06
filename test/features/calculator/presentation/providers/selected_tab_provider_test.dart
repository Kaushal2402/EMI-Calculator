import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/selected_tab_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/provider_fakes.dart';

void main() {
  ProviderContainer containerWith(FakeLoanRepository repo) =>
      ProviderContainer.test(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
      );

  test('defaults to Home before the input has resolved', () {
    final container = containerWith(FakeLoanRepository());

    expect(container.read(selectedTabProvider), LoanType.home);
  });

  test('tracks the restored input type once it resolves', () async {
    const persisted = LoanInput(
      principal: 750000,
      annualRate: 10.4,
      tenureMonths: 84,
      loanType: LoanType.car,
    );
    final container = containerWith(FakeLoanRepository(initial: persisted));

    await container.read(loanInputProvider.future);

    expect(container.read(selectedTabProvider), LoanType.car);
  });

  group('select (AC-05)', () {
    test(
      "switches the tab and resets inputs to that type's presets",
      () async {
        final container = containerWith(FakeLoanRepository());
        await container.read(loanInputProvider.future);

        container.read(selectedTabProvider.notifier).select(LoanType.personal);

        expect(container.read(selectedTabProvider), LoanType.personal);
        final input = container.read(loanInputProvider).value!;
        expect(input.loanType, LoanType.personal);
        expect(input.principal, 300000);
        expect(input.annualRate, 13);
        expect(input.tenureMonths, 36);
      },
    );

    test('re-selecting the active tab is a no-op (keeps edits)', () async {
      final container = containerWith(FakeLoanRepository());
      await container.read(loanInputProvider.future);
      container.read(loanInputProvider.notifier).setPrincipal(4200000);

      container.read(selectedTabProvider.notifier).select(LoanType.home);

      expect(container.read(loanInputProvider).value!.principal, 4200000);
    });
  });
}
