import 'package:emi_calculator/core/extensions/double_ext.dart';
import 'package:emi_calculator/core/extensions/int_ext.dart';
import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Builds the plain-text share summary for a calculation result (SOW §4.7,
/// AC-06).
///
/// The output matches the SOW §4.7 template byte-for-byte for the Home Loan
/// default: a header line, a labelled input block, a labelled result block and
/// a footer, separated by blank lines. Labels within each block are padded so
/// the colons align.
///
/// ## Rounding (SOW §4.3)
///
/// [EmiResult] values are exact/unrounded. The share text applies display
/// rounding: the monthly EMI is rounded to the nearest ₹1, and the totals are
/// derived from that rounded EMI per SOW §4.3 —
/// `Total Interest = EMI × n − P`, `Total Payable = P + Total Interest`. This
/// is what reproduces the template's `₹32,48,400` / `₹62,48,400` exactly.
String buildEmiShareText({
  required LoanInput input,
  required EmiResult result,
}) {
  final roundedEmi = result.monthlyEmi.round();
  final totalPayable = (roundedEmi * input.tenureMonths).toDouble();
  final totalInterest = totalPayable - input.principal;

  String row(String label, String value, int width) =>
      '${label.padRight(width)}: $value';

  const inputWidth = 13;
  const resultWidth = 17;

  return [
    'EMI Calculator Result — Softpital',
    '',
    row('Loan Type', _loanTypeLabel(input.loanType), inputWidth),
    row('Principal', input.principal.toIndianCurrency(), inputWidth),
    row('Interest Rate', '${input.annualRate.toPercentage()} p.a.', inputWidth),
    row('Tenure', input.tenureMonths.toTenureLabel(), inputWidth),
    '',
    row('Monthly EMI', roundedEmi.toDouble().toIndianCurrency(), resultWidth),
    row('Total Interest', totalInterest.toIndianCurrency(), resultWidth),
    row('Total Payable', totalPayable.toIndianCurrency(), resultWidth),
    '',
    'Calculated using EMI Calculator App',
  ].join('\n');
}

String _loanTypeLabel(LoanType type) => switch (type) {
  LoanType.home => 'Home Loan',
  LoanType.car => 'Car Loan',
  LoanType.personal => 'Personal Loan',
};
