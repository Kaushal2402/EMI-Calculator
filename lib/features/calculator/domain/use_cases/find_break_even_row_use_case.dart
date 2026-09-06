import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';

/// Finds the amortization "break-even" row to highlight (SOW §4.4).
///
/// Pure Dart: no Flutter, no plugins, no I/O.
///
/// ## Semantics — and a deviation from the literal SOW wording
///
/// SOW §4.4 says: *"Highlight the first row where cumulative principal >
/// cumulative interest (break-even point)."*
///
/// Taken literally (running total of principal repaid vs running total of
/// interest paid), **no such row exists for the Home Loan default**
/// (₹30,00,000 / 8.50% / 20y): total interest (~₹32.5L) exceeds total
/// principal (₹30L), so cumulative principal never overtakes cumulative
/// interest. That directly contradicts TASKS.md 1.4, which requires asserting
/// a break-even index for exactly that input.
///
/// This use case therefore implements the standard amortization **crossover
/// point**: the first row whose *principal component* exceeds its *interest
/// component*. This is the universally used meaning of an amortization
/// "break-even" and is well-defined for every positive-rate loan. It works
/// on a monthly schedule or on an aggregated yearly schedule.
///
/// >  DECISION PENDING CLIENT SIGN-OFF: if the client truly means the
/// >  cumulative running-total comparison, switch the predicate in
/// >  [_isBreakEven] to compare running sums instead (and accept that some
/// >  loans, including the Home Loan default, will have no highlighted row).
class FindBreakEvenRowUseCase {
  /// Creates the use case.
  const FindBreakEvenRowUseCase();

  /// Returns the 0-based index of the first break-even row in [schedule], or
  /// `null` if the principal component never exceeds the interest component
  /// (e.g. a zero-interest loan, or a single-row schedule that is all
  /// principal from the start still counts — see below).
  ///
  /// For a zero-interest loan every row has `interestComponent == 0`, so the
  /// first row already satisfies `principal > interest` and index `0` is
  /// returned.
  int? execute(List<AmortizationRow> schedule) {
    for (var i = 0; i < schedule.length; i++) {
      if (_isBreakEven(schedule[i])) return i;
    }
    return null;
  }

  bool _isBreakEven(AmortizationRow row) =>
      row.principalComponent > row.interestComponent;
}
