import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/tenure_unit_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults to Years', () {
    final container = ProviderContainer.test();

    expect(container.read(tenureUnitProvider), TenureUnit.years);
  });

  test('select sets the unit explicitly', () {
    final container = ProviderContainer.test();

    container.read(tenureUnitProvider.notifier).select(TenureUnit.months);

    expect(container.read(tenureUnitProvider), TenureUnit.months);
  });

  test('toggle flips between Years and Months', () {
    final container = ProviderContainer.test();

    container.read(tenureUnitProvider.notifier).toggle();
    expect(container.read(tenureUnitProvider), TenureUnit.months);

    container.read(tenureUnitProvider.notifier).toggle();
    expect(container.read(tenureUnitProvider), TenureUnit.years);
  });
}
