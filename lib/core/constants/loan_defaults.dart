/// Per-loan-type preset defaults and global input ranges (SOW §4.1, §4.2).
library;

import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Immutable bundle of the three default values for a loan type.
class LoanTypeDefaults {
  /// Creates a set of defaults.
  const LoanTypeDefaults({
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
  });

  /// Default principal, in ₹.
  final double principal;

  /// Default annual interest rate, as a percentage (e.g. `8.5`).
  final double annualRate;

  /// Default tenure, in months.
  final int tenureMonths;
}

/// Default inputs applied when a loan-type tab is selected (SOW §4.1).
///
/// | Loan Type     | Principal    | Rate    | Tenure   |
/// |---------------|--------------|---------|----------|
/// | Home Loan     | ₹30,00,000   | 8.50%   | 20 years |
/// | Car Loan      | ₹8,00,000    | 9.00%   | 5 years  |
/// | Personal Loan | ₹3,00,000    | 13.00%  | 3 years  |
const Map<LoanType, LoanTypeDefaults> kLoanDefaults = {
  LoanType.home: LoanTypeDefaults(
    principal: 3000000,
    annualRate: 8.5,
    tenureMonths: 240,
  ),
  LoanType.car: LoanTypeDefaults(
    principal: 800000,
    annualRate: 9,
    tenureMonths: 60,
  ),
  LoanType.personal: LoanTypeDefaults(
    principal: 300000,
    annualRate: 13,
    tenureMonths: 36,
  ),
};

/// The loan type selected on first launch (SOW §5.2 / task 2.3).
const LoanType kDefaultLoanType = LoanType.home;

/// Builds a [LoanInput] pre-filled with [type]'s preset defaults (SOW §4.1).
///
/// Single source of truth for both first-launch seeding (task 2.3) and the
/// tab-switch reset behaviour (AC-05, Phase 3).
LoanInput loanInputFromDefaults(LoanType type) {
  final d = kLoanDefaults[type]!;
  return LoanInput(
    principal: d.principal,
    annualRate: d.annualRate,
    tenureMonths: d.tenureMonths,
    loanType: type,
  );
}

/// The [LoanInput] a fresh install opens with: Home Loan defaults
/// (₹30,00,000 / 8.50% / 20 years) per SOW §4.1 (task 2.3).
LoanInput firstLaunchLoanInput() => loanInputFromDefaults(kDefaultLoanType);

// --- Input constraints (SOW §4.2) ---------------------------------------------

/// Minimum principal: ₹10,000.
const double kMinPrincipal = 10000;

/// Maximum principal: ₹5,00,00,000 (5 crore).
const double kMaxPrincipal = 50000000;

/// Minimum annual interest rate: 1.00%.
const double kMinAnnualRate = 1;

/// Maximum annual interest rate: 36.00%.
const double kMaxAnnualRate = 36;

/// Interest-rate slider step: 0.05%.
const double kAnnualRateStep = 0.05;

/// Minimum tenure in years.
const int kMinTenureYears = 1;

/// Maximum tenure in years.
const int kMaxTenureYears = 30;

/// Minimum tenure in months.
const int kMinTenureMonths = 12;

/// Maximum tenure in months.
const int kMaxTenureMonths = 360;

/// Real-time recalculation debounce (SOW §4.2).
const Duration kCalcDebounce = Duration(milliseconds: 150);

/// Show an interstitial ad on every Nth calculation (SOW §4.8).
const int kInterstitialEveryNCalculations = 5;
