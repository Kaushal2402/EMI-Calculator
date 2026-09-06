import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/aggregate_yearly_schedule_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = CalculateEmiUseCase();
  const aggregate = AggregateYearlyScheduleUseCase();

  const homeDefault = LoanInput(
    principal: 3000000,
    annualRate: 8.5,
    tenureMonths: 240,
    loanType: LoanType.home,
  );

  test('empty input yields empty output', () {
    expect(aggregate.execute(const []), isEmpty);
  });

  test('Home Loan default aggregates to 20 yearly rows numbered 1..20', () {
    final monthly = calc.execute(homeDefault).schedule;
    final yearly = aggregate.execute(monthly);

    expect(yearly, hasLength(20));
    expect(yearly.map((r) => r.period), List.generate(20, (i) => i + 1));
  });

  test('yearly totals reconcile with the monthly schedule', () {
    final result = calc.execute(homeDefault);
    final yearly = aggregate.execute(result.schedule);

    final sumPrincipal = yearly.fold<double>(
      0,
      (s, r) => s + r.principalComponent,
    );
    final sumInterest = yearly.fold<double>(
      0,
      (s, r) => s + r.interestComponent,
    );
    final sumEmi = yearly.fold<double>(0, (s, r) => s + r.emi);

    expect(sumPrincipal, closeTo(3000000, 0.01));
    expect(sumInterest, closeTo(result.totalInterest, 1));
    expect(sumEmi, closeTo(result.totalPayable, 1));
    expect(yearly.last.outstandingBalance, 0);
  });

  test('each yearly balance equals the 12th months closing balance', () {
    final monthly = calc.execute(homeDefault).schedule;
    final yearly = aggregate.execute(monthly);

    for (var y = 0; y < yearly.length; y++) {
      final lastMonthOfYear = monthly[(y * 12) + 11];
      expect(
        yearly[y].outstandingBalance,
        lastMonthOfYear.outstandingBalance,
      );
    }
  });

  test('trailing partial year becomes a short final row', () {
    // 30-month tenure -> years of 12, 12, 6 months.
    final monthly = calc
        .execute(
          const LoanInput(
            principal: 500000,
            annualRate: 11,
            tenureMonths: 30,
            loanType: LoanType.personal,
          ),
        )
        .schedule;
    final yearly = aggregate.execute(monthly);

    expect(yearly, hasLength(3));
    expect(yearly.map((r) => r.period), [1, 2, 3]);
    expect(yearly.last.outstandingBalance, 0);

    // Final row sums only the last 6 months.
    final lastSix = monthly.sublist(24, 30);
    expect(
      yearly.last.principalComponent,
      closeTo(
        lastSix.fold<double>(0, (s, r) => s + r.principalComponent),
        1e-6,
      ),
    );
  });
}
