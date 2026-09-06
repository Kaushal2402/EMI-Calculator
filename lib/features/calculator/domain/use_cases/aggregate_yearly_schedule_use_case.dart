import 'dart:math' as math;

import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';

/// Collapses a month-by-month amortization schedule into year-by-year rows
/// for the "Yearly" breakdown toggle (SOW §4.4).
///
/// Pure Dart: no Flutter, no plugins, no I/O.
///
/// Each output row covers up to 12 consecutive months:
///  * [AmortizationRow.period] is the 1-based year number.
///  * [AmortizationRow.emi], `principalComponent` and `interestComponent` are
///    the sums over the months in that year.
///  * [AmortizationRow.outstandingBalance] is the balance after the last month
///    of that year (i.e. the final month's closing balance).
///
/// A trailing partial year (tenure not divisible by 12) becomes a final row
/// covering the remaining months.
class AggregateYearlyScheduleUseCase {
  /// Creates the use case.
  const AggregateYearlyScheduleUseCase();

  /// Aggregates [monthlySchedule] (as produced by `CalculateEmiUseCase`) into
  /// yearly rows. Returns an empty list for an empty input.
  List<AmortizationRow> execute(List<AmortizationRow> monthlySchedule) {
    if (monthlySchedule.isEmpty) return const [];

    final years = <AmortizationRow>[];
    for (var start = 0; start < monthlySchedule.length; start += 12) {
      final end = math.min(start + 12, monthlySchedule.length);
      final chunk = monthlySchedule.sublist(start, end);

      var emi = 0.0;
      var principal = 0.0;
      var interest = 0.0;
      for (final row in chunk) {
        emi += row.emi;
        principal += row.principalComponent;
        interest += row.interestComponent;
      }

      years.add(
        AmortizationRow(
          period: (start ~/ 12) + 1,
          emi: emi,
          principalComponent: principal,
          interestComponent: interest,
          outstandingBalance: chunk.last.outstandingBalance,
        ),
      );
    }
    return years;
  }
}
