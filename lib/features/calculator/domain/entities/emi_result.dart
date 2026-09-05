import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';

/// Output of the EMI calculation engine (SOW §4.3, §7.4).
///
/// PHASE 0 SCAFFOLD placeholder — Phase 1 (task 1.1) replaces this with a
/// `freezed` data class. No Flutter / plugin imports allowed here.
class EmiResult {
  /// Creates an EMI result.
  const EmiResult({
    required this.monthlyEmi,
    required this.totalInterest,
    required this.totalPayable,
    required this.principalRatio,
    required this.interestRatio,
    required this.schedule,
  });

  /// Monthly instalment, rounded to the nearest ₹1.
  final double monthlyEmi;

  /// Total interest payable over the full tenure (`EMI × n − P`).
  final double totalInterest;

  /// Total amount payable (`P + totalInterest`).
  final double totalPayable;

  /// Principal as a fraction of [totalPayable], `0.0`–`1.0`.
  final double principalRatio;

  /// Interest as a fraction of [totalPayable], `0.0`–`1.0`.
  final double interestRatio;

  /// Month-by-month amortization schedule.
  final List<AmortizationRow> schedule;
}
