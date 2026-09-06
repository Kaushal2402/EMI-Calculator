import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/aggregate_yearly_schedule_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/find_break_even_row_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/amortization_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amortization_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AmortizationView _viewFor(LoanInput input) {
  final result = const CalculateEmiUseCase().execute(input);
  final monthly = result.schedule;
  final yearly = const AggregateYearlyScheduleUseCase().execute(monthly);
  const findBreakEven = FindBreakEvenRowUseCase();
  return AmortizationView(
    monthly: monthly,
    yearly: yearly,
    monthlyBreakEvenIndex: findBreakEven.execute(monthly),
    yearlyBreakEvenIndex: findBreakEven.execute(yearly),
  );
}

const _homeDefault = LoanInput(
  principal: 3000000,
  annualRate: 8.5,
  tenureMonths: 240,
  loanType: LoanType.home,
);

Future<void> _pump(WidgetTester tester, AmortizationView view) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomScrollView(
              slivers: [AmortizationTable(view: view)],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Color? _rowColor(WidgetTester tester, String periodLabel) {
  final container = tester.widget<Container>(
    find
        .ancestor(
          of: find.text(periodLabel),
          matching: find.byType(Container),
        )
        .first,
  );
  return (container.decoration! as BoxDecoration).color;
}

void main() {
  testWidgets('shows the Monthly header and toggles to Yearly (SOW §5.3)', (
    tester,
  ) async {
    await _pump(tester, _viewFor(_homeDefault));

    expect(find.text('MONTH'), findsOneWidget);
    expect(find.text('EMI'), findsOneWidget);
    expect(find.text('BALANCE'), findsOneWidget);

    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    expect(find.text('YEAR'), findsOneWidget);
    expect(find.text('MONTH'), findsNothing);
  });

  testWidgets('alternate rows use the surface-variant background', (
    tester,
  ) async {
    final view = _viewFor(_homeDefault);
    await _pump(tester, view);

    final scheme = AppTheme.light().colorScheme;
    // Period 2 -> index 1 (odd, not the break-even row at index 142).
    expect(_rowColor(tester, '2'), scheme.surfaceContainerHighest);
    // Period 1 -> index 0 (even, no tint).
    expect(_rowColor(tester, '1'), isNull);
  });

  testWidgets('highlights the Yearly break-even row at the Home Loan default '
      'index (period 13)', (tester) async {
    final view = _viewFor(_homeDefault);
    expect(view.yearlyBreakEvenIndex, 12);

    await _pump(tester, view);
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('13'),
      300,
      scrollable: find.byType(Scrollable),
    );

    expect(
      _rowColor(tester, '13'),
      AppTheme.light().colorScheme.primaryContainer,
    );

    final container = tester.widget<Container>(
      find
          .ancestor(of: find.text('13'), matching: find.byType(Container))
          .first,
    );
    final border = (container.decoration! as BoxDecoration).border! as Border;
    expect(border.left.width, 3);
  });

  testWidgets(
    'highlights the Monthly break-even row (zero-interest -> row 1)',
    (
      tester,
    ) async {
      final view = _viewFor(
        const LoanInput(
          principal: 120000,
          annualRate: 0,
          tenureMonths: 12,
          loanType: LoanType.personal,
        ),
      );
      expect(view.monthlyBreakEvenIndex, 0);

      await _pump(tester, view);

      expect(
        _rowColor(tester, '1'),
        AppTheme.light().colorScheme.primaryContainer,
      );
    },
  );

  testWidgets('numeric cells use tabular figures', (tester) async {
    await _pump(tester, _viewFor(_homeDefault));

    // First month's EMI for the Home default is ~₹26,035.
    final emiText = tester.widget<Text>(find.text('26,035').first);
    expect(
      emiText.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
