/// Domain entity + supporting enums for a loan calculation request.
///
/// This file must never import Flutter or any plugin (Clean Architecture).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_input.freezed.dart';

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

/// A single EMI calculation request (SOW §7.4).
@freezed
abstract class LoanInput with _$LoanInput {
  /// Creates a loan input.
  const factory LoanInput({
    /// Principal loan amount, in ₹.
    required double principal,

    /// Annual interest rate as a percentage, e.g. `8.5` for 8.50% p.a.
    required double annualRate,

    /// Loan tenure, always expressed in months.
    required int tenureMonths,

    /// Selected loan product.
    required LoanType loanType,
  }) = _LoanInput;
}
