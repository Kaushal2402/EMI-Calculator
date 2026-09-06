import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/calculation_persistence_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/provider_fakes.dart';

void main() {
  late FakeLoanRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeLoanRepository();
    container =
        ProviderContainer.test(
            overrides: [
              loanRepositoryProvider.overrideWithValue(repo),
              calcDebounceProvider.overrideWithValue(Duration.zero),
            ],
          )
          // Activate the side-effect listener (the app root does this via `watch`).
          ..read(calculationPersistenceProvider);
  });

  Future<void> settle() async {
    await container.read(emiResultProvider.future);
    // Let the ref.listen callback microtask run.
    await Future<void>.delayed(Duration.zero);
  }

  test('persists inputs exactly once per settled calculation', () async {
    await settle();

    expect(repo.saveCallCount, 1);
    expect(repo.lastSaved, container.read(loanInputProvider).value);
  });

  test('each subsequent settled change persists once more', () async {
    await settle();
    expect(repo.saveCallCount, 1);

    container.read(loanInputProvider.notifier).setLoanType(LoanType.car);
    await settle();
    expect(repo.saveCallCount, 2);
    expect(repo.lastSaved!.loanType, LoanType.car);

    container.read(loanInputProvider.notifier).setPrincipal(999999);
    await settle();
    expect(repo.saveCallCount, 3);
    expect(repo.lastSaved!.principal, 999999);
  });

  test('a synchronous burst of edits still persists only once', () async {
    await settle();
    expect(repo.saveCallCount, 1);

    container.read(loanInputProvider.notifier)
      ..setPrincipal(1000000)
      ..setPrincipal(1100000)
      ..setPrincipal(1200000);
    await settle();

    expect(repo.saveCallCount, 2);
    expect(repo.lastSaved!.principal, 1200000);
  });

  test('does not persist while the result is still loading/errored', () async {
    // Before the first calculation settles, nothing has been written.
    expect(repo.saveCallCount, 0);
  });
}
