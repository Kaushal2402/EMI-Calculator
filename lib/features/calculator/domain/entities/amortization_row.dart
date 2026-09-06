/// One row of the amortization schedule (month or aggregated year).
///
/// This file must never import Flutter or any plugin (Clean Architecture).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'amortization_row.freezed.dart';

/// A single period in the amortization schedule (SOW §4.4).
@freezed
abstract class AmortizationRow with _$AmortizationRow {
  /// Creates an amortization row.
  const factory AmortizationRow({
    /// 1-based period index (month number, or year number in the yearly view).
    required int period,

    /// EMI paid in this period (sum of the monthly EMIs in the yearly view).
    required double emi,

    /// Portion of [emi] that reduced the principal.
    required double principalComponent,

    /// Portion of [emi] that went to interest.
    required double interestComponent,

    /// Principal still outstanding at the end of this period.
    required double outstandingBalance,
  }) = _AmortizationRow;
}
