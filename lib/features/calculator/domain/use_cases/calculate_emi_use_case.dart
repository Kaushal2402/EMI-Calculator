import 'dart:math' as math;

import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';
import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Pure EMI calculation engine (SOW §4.3, §7.4).
///
/// This class is a pure function: no Flutter, no plugins, no I/O, no mutation
/// of its argument. Given the same [LoanInput] it always returns an equal
/// [EmiResult].
///
/// ### Formula (SOW §4.3)
///
/// ```text
/// EMI = P × r × (1 + r)ⁿ / ((1 + r)ⁿ − 1)
///
///   P = principal
///   r = monthly rate = annualRate / 12 / 100
///   n = tenureMonths
/// ```
///
/// When `r == 0` (zero-interest loan) the formula is undefined, so the EMI
/// degrades to `P / n` (SOW §7.4 guard).
///
/// ### Rounding
///
/// [EmiResult.monthlyEmi], [EmiResult.totalInterest] and
/// [EmiResult.totalPayable] are the exact, unrounded values (matching the
/// SOW §7.4 code sample). Rounding to the nearest ₹1 for display is the
/// presentation layer's job. AC-01's ±₹1 tolerance covers this difference.
class CalculateEmiUseCase {
  /// Creates the use case.
  const CalculateEmiUseCase();

  /// Computes the EMI, totals, ratios and full month-by-month amortization
  /// schedule for [input].
  ///
  /// Invariants of the returned [EmiResult]:
  ///  * `schedule.length == input.tenureMonths`
  ///  * the final row's `outstandingBalance` is exactly `0`
  ///  * `Σ principalComponent == input.principal` (to floating-point epsilon)
  ///  * `Σ interestComponent ≈ totalInterest` (within ~₹1 of rounding drift)
  EmiResult execute(LoanInput input) {
    assert(input.principal > 0, 'principal must be positive');
    assert(input.tenureMonths > 0, 'tenureMonths must be positive');
    assert(input.annualRate >= 0, 'annualRate must not be negative');

    final p = input.principal;
    final n = input.tenureMonths;
    final r = input.annualRate / 12 / 100;

    final monthlyEmi = r == 0
        ? p / n
        : p * r * math.pow(1 + r, n) / (math.pow(1 + r, n) - 1);

    final schedule = _buildSchedule(
      principal: p,
      months: n,
      rate: r,
      emi: monthlyEmi,
    );

    final totalPayable = monthlyEmi * n;
    final totalInterest = totalPayable - p;
    final principalRatio = p / totalPayable;
    final interestRatio = totalInterest / totalPayable;

    return EmiResult(
      monthlyEmi: monthlyEmi,
      totalInterest: totalInterest,
      totalPayable: totalPayable,
      principalRatio: principalRatio,
      interestRatio: interestRatio,
      schedule: schedule,
    );
  }

  /// Builds the reducing-balance amortization schedule.
  ///
  /// Interest for a period is charged on the balance outstanding at the start
  /// of that period; the remainder of the EMI reduces the principal. The final
  /// row absorbs any residual balance so the loan closes exactly at `0`,
  /// guarding against floating-point drift over long tenures.
  List<AmortizationRow> _buildSchedule({
    required double principal,
    required int months,
    required double rate,
    required double emi,
  }) {
    final rows = <AmortizationRow>[];
    var balance = principal;

    for (var month = 1; month <= months; month++) {
      final interestComponent = balance * rate;
      double principalComponent;
      double rowEmi;

      if (month == months) {
        // Close the loan exactly: the last instalment repays whatever is left.
        principalComponent = balance;
        rowEmi = principalComponent + interestComponent;
      } else {
        principalComponent = emi - interestComponent;
        rowEmi = emi;
      }

      balance -= principalComponent;
      if (month == months) balance = 0;

      rows.add(
        AmortizationRow(
          period: month,
          emi: rowEmi,
          principalComponent: principalComponent,
          interestComponent: interestComponent,
          outstandingBalance: balance <= 0 ? 0 : balance,
        ),
      );
    }

    return rows;
  }
}
