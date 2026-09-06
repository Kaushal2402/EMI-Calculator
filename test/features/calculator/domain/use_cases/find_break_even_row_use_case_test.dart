import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/aggregate_yearly_schedule_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/find_break_even_row_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = CalculateEmiUseCase();
  const aggregate = AggregateYearlyScheduleUseCase();
  const findBreakEven = FindBreakEvenRowUseCase();

  const homeDefault = LoanInput(
    principal: 3000000,
    annualRate: 8.5,
    tenureMonths: 240,
    loanType: LoanType.home,
  );

  group('Home Loan default (₹30,00,000 / 8.50% / 20y)', () {
    test('monthly break-even is row index 142 (month 143)', () {
      final schedule = calc.execute(homeDefault).schedule;
      final index = findBreakEven.execute(schedule);

      expect(index, 142);
      // Sanity: the flagged row is the first with principal > interest,
      // and the row before it is not.
      expect(
        schedule[142].principalComponent,
        greaterThan(schedule[142].interestComponent),
      );
      expect(
        schedule[141].principalComponent,
        lessThanOrEqualTo(schedule[141].interestComponent),
      );
    });

    test('yearly break-even is row index 12 (year 13)', () {
      final yearly = aggregate.execute(calc.execute(homeDefault).schedule);
      expect(findBreakEven.execute(yearly), 12);
    });
  });

  test('Car Loan default breaks even on the first row', () {
    final schedule = calc
        .execute(
          const LoanInput(
            principal: 800000,
            annualRate: 9,
            tenureMonths: 60,
            loanType: LoanType.car,
          ),
        )
        .schedule;
    expect(findBreakEven.execute(schedule), 0);
  });

  test('Personal Loan default breaks even on the first row', () {
    final schedule = calc
        .execute(
          const LoanInput(
            principal: 300000,
            annualRate: 13,
            tenureMonths: 36,
            loanType: LoanType.personal,
          ),
        )
        .schedule;
    expect(findBreakEven.execute(schedule), 0);
  });

  test('zero-interest loan breaks even immediately (index 0)', () {
    final schedule = calc
        .execute(
          const LoanInput(
            principal: 600000,
            annualRate: 0,
            tenureMonths: 24,
            loanType: LoanType.car,
          ),
        )
        .schedule;
    expect(findBreakEven.execute(schedule), 0);
  });

  test('empty schedule returns null', () {
    expect(findBreakEven.execute(const []), isNull);
  });
}
