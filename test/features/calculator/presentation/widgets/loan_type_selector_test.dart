import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/selected_tab_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/loan_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: LoanTypeSelector()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('renders the three loan-type segments', (tester) async {
    await pump(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Car'), findsOneWidget);
    expect(find.text('Personal'), findsOneWidget);
  });

  testWidgets('tapping a tab switches selectedTabProvider and resets inputs '
      "to that type's defaults (AC-05)", (tester) async {
    final container = await pump(tester);

    // Dirty the form first.
    container.read(loanInputProvider.notifier)
      ..setPrincipal(12345)
      ..setAnnualRate(3);

    await tester.tap(find.text('Car'));
    await tester.pumpAndSettle();

    expect(container.read(selectedTabProvider), LoanType.car);
    final input = container.read(loanInputProvider).requireValue;
    expect(input.loanType, LoanType.car);
    expect(input.principal, 800000);
    expect(input.annualRate, 9);
    expect(input.tenureMonths, 60);
  });

  testWidgets('switching to Personal then Home restores Home defaults', (
    tester,
  ) async {
    final container = await pump(tester);

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    final input = container.read(loanInputProvider).requireValue;
    expect(input.loanType, LoanType.home);
    expect(input.principal, 3000000);
    expect(input.annualRate, 8.5);
    expect(input.tenureMonths, 240);
  });
}
