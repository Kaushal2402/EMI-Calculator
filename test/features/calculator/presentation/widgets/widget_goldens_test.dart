import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/aggregate_yearly_schedule_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/find_break_even_row_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/amortization_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amortization_table.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amount_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/emi_chart.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/loan_type_selector.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/metric_tile.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/rate_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/tenure_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 8.6 — golden coverage for the key SOW §5 widgets in BOTH themes.
///
/// `test/flutter_test_config.dart` disables google_fonts runtime fetching, so
/// text resolves to the deterministic bundled fallback (block glyphs) on every
/// machine / CI — these goldens verify geometry, colour and theming, not text
/// shaping (same contract as the pre-existing `summary_card` goldens). Each
/// case pins the column width so the snapshot is stable.
void main() {
  const homeDefault = LoanInput(
    principal: 3000000,
    annualRate: 8.5,
    tenureMonths: 240,
    loanType: LoanType.home,
  );

  AmortizationView amortizationView(LoanInput input) {
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

  /// Pumps [child] inside a themed [MaterialApp], then matches
  /// `goldens/<name>_light.png` and `goldens/<name>_dark.png`.
  ///
  /// A bare [ProviderScope] is enough: these are static snapshots, so no
  /// notifier that reaches `SharedPreferences` is ever invoked.
  /// [width] fixes the horizontal extent (matches the on-screen column width);
  /// [height] is only set for sliver widgets that need a bounded viewport,
  /// otherwise the child lays out at its natural height so nothing "overflows"
  /// a too-small box.
  Future<void> goldenBothThemes(
    WidgetTester tester, {
    required String name,
    required double width,
    required Widget child,
    double? height,
    bool settle = true,
  }) async {
    const key = ValueKey('golden-subject');
    for (final brightness in Brightness.values) {
      final themeName = brightness == Brightness.dark ? 'dark' : 'light';
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: brightness == Brightness.dark
                ? AppTheme.dark()
                : AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: RepaintBoundary(
                    key: key,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      if (settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }
      await expectLater(
        find.byKey(key),
        matchesGoldenFile('goldens/${name}_$themeName.png'),
      );
    }
  }

  testWidgets('loan type selector', (tester) async {
    await goldenBothThemes(
      tester,
      name: 'loan_type_selector',
      width: 360,
      child: const LoanTypeSelector(),
    );
  });

  testWidgets('amount input field', (tester) async {
    await goldenBothThemes(
      tester,
      name: 'amount_input_field',
      width: 360,
      child: AmountInputField(value: 3000000, onChanged: (_) {}),
    );
  });

  testWidgets('rate input field', (tester) async {
    await goldenBothThemes(
      tester,
      name: 'rate_input_field',
      width: 360,
      child: RateInputField(value: 8.5, onChanged: (_) {}),
    );
  });

  testWidgets('tenure input field', (tester) async {
    await goldenBothThemes(
      tester,
      name: 'tenure_input_field',
      width: 360,
      child: TenureInputField(
        months: 240,
        unit: TenureUnit.years,
        onMonthsChanged: (_) {},
        onUnitChanged: (_) {},
      ),
    );
  });

  testWidgets('metric tile', (tester) async {
    await goldenBothThemes(
      tester,
      name: 'metric_tile',
      width: 140,
      child: const MetricTile(label: 'Monthly EMI', value: '₹26,035'),
    );
  });

  testWidgets('emi chart', (tester) async {
    await goldenBothThemes(
      tester,
      name: 'emi_chart',
      width: 380,
      child: const EmiChart(
        principal: 3000000,
        interest: 3248368,
        totalPayable: 6248368,
      ),
    );
  });

  testWidgets('amortization table (monthly header + striped rows)', (
    tester,
  ) async {
    final view = amortizationView(homeDefault);
    await goldenBothThemes(
      tester,
      name: 'amortization_table',
      width: 380,
      height: 320,
      child: CustomScrollView(slivers: [AmortizationTable(view: view)]),
    );
  });
}
