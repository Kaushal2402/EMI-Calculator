/// Output of the EMI calculation engine (SOW §4.3, §7.4).
///
/// This file must never import Flutter or any plugin (Clean Architecture).
library;

import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'emi_result.freezed.dart';

/// The result of a single EMI calculation (SOW §4.3).
///
/// [monthlyEmi], [totalInterest] and [totalPayable] are the exact,
/// unrounded values produced by the reduce-balance formula (SOW §7.4).
/// Rounding for display is the presentation layer's responsibility.
@freezed
abstract class EmiResult with _$EmiResult {
  /// Creates an EMI result.
  const factory EmiResult({
    /// Monthly instalment (exact, unrounded).
    required double monthlyEmi,

    /// Total interest payable over the full tenure (`EMI × n − P`).
    required double totalInterest,

    /// Total amount payable (`P + totalInterest`, i.e. `EMI × n`).
    required double totalPayable,

    /// Principal as a fraction of [totalPayable], `0.0`–`1.0`.
    required double principalRatio,

    /// Interest as a fraction of [totalPayable], `0.0`–`1.0`.
    required double interestRatio,

    /// Month-by-month amortization schedule (length == `tenureMonths`).
    required List<AmortizationRow> schedule,
  }) = _EmiResult;
}
