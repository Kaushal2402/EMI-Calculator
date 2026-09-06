import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/provider_fakes.dart';

/// Records every [execute] call so tests can count real calculations.
class SpyCalculateEmiUseCase extends CalculateEmiUseCase {
  SpyCalculateEmiUseCase() : super();

  final List<LoanInput> calls = <LoanInput>[];

  @override
  EmiResult execute(LoanInput input) {
    calls.add(input);
    return super.execute(input);
  }
}

void main() {
  group('emiResultProvider — correctness', () {
    test('exposes the use-case result for the current input', () async {
      final container = ProviderContainer.test(
        overrides: [
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          calcDebounceProvider.overrideWithValue(Duration.zero),
        ],
      );

      final result = await container.read(emiResultProvider.future);
      final expected = const CalculateEmiUseCase().execute(
        container.read(loanInputProvider).value!,
      );

      expect(result.monthlyEmi, expected.monthlyEmi);
      expect(result.totalInterest, expected.totalInterest);
      expect(result.schedule.length, 240);
    });

    test('recalculates when the input changes', () async {
      final container = ProviderContainer.test(
        overrides: [
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          calcDebounceProvider.overrideWithValue(Duration.zero),
        ],
      );
      await container.read(emiResultProvider.future);

      container.read(loanInputProvider.notifier).setLoanType(LoanType.personal);
      final result = await container.read(emiResultProvider.future);

      expect(result.schedule.length, 36);
    });
  });

  group('emiResultProvider — debounce (SOW §4.2)', () {
    test('a synchronous burst of edits collapses to one calculation', () async {
      final spy = SpyCalculateEmiUseCase();
      final container = ProviderContainer.test(
        overrides: [
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          calcDebounceProvider.overrideWithValue(
            const Duration(milliseconds: 30),
          ),
          calculateEmiUseCaseProvider.overrideWithValue(spy),
        ],
      );
      final sub = container.listen(emiResultProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(emiResultProvider.future);
      expect(spy.calls.length, 1, reason: 'initial calculation');

      container.read(loanInputProvider.notifier)
        ..setPrincipal(1000000)
        ..setPrincipal(1100000)
        ..setPrincipal(1200000)
        ..setPrincipal(1300000);

      await container.read(emiResultProvider.future);

      expect(spy.calls.length, 2);
      expect(spy.calls.last.principal, 1300000);
    });

    test(
      'edits spaced within the debounce window cancel superseded runs',
      () async {
        final spy = SpyCalculateEmiUseCase();
        final container = ProviderContainer.test(
          overrides: [
            loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
            calcDebounceProvider.overrideWithValue(
              const Duration(milliseconds: 40),
            ),
            calculateEmiUseCaseProvider.overrideWithValue(spy),
          ],
        );
        final sub = container.listen(emiResultProvider, (_, _) {});
        addTearDown(sub.close);
        await container.read(emiResultProvider.future);
        expect(spy.calls.length, 1);

        final notifier = container.read(loanInputProvider.notifier)
          ..setPrincipal(1000000);
        await Future<void>.delayed(const Duration(milliseconds: 15));
        notifier.setPrincipal(1100000);
        await Future<void>.delayed(const Duration(milliseconds: 15));
        notifier.setPrincipal(1200000);

        final settled = await container.read(emiResultProvider.future);

        expect(
          spy.calls.length,
          2,
          reason:
              'initial + one coalesced; the two superseded runs are aborted',
        );
        expect(settled.schedule.first.emi, greaterThan(0));
        expect(spy.calls.last.principal, 1200000);
      },
    );
  });
}
