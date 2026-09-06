import 'package:emi_calculator/features/calculator/presentation/providers/amortization_unit_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to Monthly (SOW §5.3)', () {
    final container = ProviderContainer.test();
    expect(container.read(amortizationUnitProvider), AmortizationUnit.monthly);
  });

  test('select switches granularity', () {
    final container = ProviderContainer.test();

    container
        .read(amortizationUnitProvider.notifier)
        .select(AmortizationUnit.yearly);
    expect(container.read(amortizationUnitProvider), AmortizationUnit.yearly);

    container
        .read(amortizationUnitProvider.notifier)
        .select(AmortizationUnit.monthly);
    expect(container.read(amortizationUnitProvider), AmortizationUnit.monthly);
  });

  test('selecting the current value is a no-op', () {
    final container = ProviderContainer.test();
    var notifications = 0;
    container.listen(amortizationUnitProvider, (_, _) => notifications++);

    container
        .read(amortizationUnitProvider.notifier)
        .select(AmortizationUnit.monthly);

    expect(notifications, 0);
  });
}
