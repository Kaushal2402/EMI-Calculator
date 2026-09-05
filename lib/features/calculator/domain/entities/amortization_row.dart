/// One row of the amortization schedule (month or aggregated year).
///
/// PHASE 0 SCAFFOLD placeholder — Phase 1 (task 1.1) replaces this with a
/// `freezed` data class. No Flutter / plugin imports allowed here.
library;

/// A single period in the amortization schedule.
class AmortizationRow {
  /// Creates an amortization row.
  const AmortizationRow({
    required this.period,
    required this.emi,
    required this.principalComponent,
    required this.interestComponent,
    required this.outstandingBalance,
  });

  /// 1-based period index (month number, or year number in the yearly view).
  final int period;

  /// EMI paid in this period.
  final double emi;

  /// Portion of [emi] that reduced the principal.
  final double principalComponent;

  /// Portion of [emi] that went to interest.
  final double interestComponent;

  /// Principal still outstanding at the end of this period.
  final double outstandingBalance;
}
