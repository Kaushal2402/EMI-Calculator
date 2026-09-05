/// Domain entity + supporting enums for a loan calculation request.
///
/// PHASE 0 SCAFFOLD: this is a plain placeholder. Phase 1 (task 1.1) replaces
/// [LoanInput] with a `freezed` data class. The enums are already final.
///
/// This file must never import Flutter or any plugin (Clean Architecture).
library;

/// The three supported loan products (SOW §4.1).
enum LoanType {
  /// Home loan.
  home,

  /// Car / auto loan.
  car,

  /// Unsecured personal loan.
  personal,
}

/// Unit the user is currently entering the tenure in (SOW §4.2).
///
/// Tenure is always *stored* in months regardless of the selected unit.
enum TenureUnit {
  /// Tenure entered in years.
  years,

  /// Tenure entered in months.
  months,
}

/// A single EMI calculation request.
///
/// Placeholder shape — see [SOW §7.4] for the target `freezed` definition.
class LoanInput {
  /// Creates a loan input.
  const LoanInput({
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
    required this.loanType,
  });

  /// Principal loan amount, in ₹.
  final double principal;

  /// Annual interest rate as a percentage, e.g. `8.5` for 8.50% p.a.
  final double annualRate;

  /// Loan tenure, always expressed in months.
  final int tenureMonths;

  /// Selected loan product.
  final LoanType loanType;
}
