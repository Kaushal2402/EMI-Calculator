import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/utils/emi_share_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = CalculateEmiUseCase();

  test(
    'matches the SOW §4.7 template byte-for-byte for the Home Loan default',
    () {
      final input = loanInputFromDefaults(LoanType.home);
      final result = useCase.execute(input);

      const expected =
          'EMI Calculator Result — Softpital\n'
          '\n'
          'Loan Type    : Home Loan\n'
          'Principal    : ₹30,00,000\n'
          'Interest Rate: 8.50% p.a.\n'
          'Tenure       : 20 Years\n'
          '\n'
          'Monthly EMI      : ₹26,035\n'
          'Total Interest   : ₹32,48,400\n'
          'Total Payable    : ₹62,48,400\n'
          '\n'
          'Calculated using EMI Calculator App';

      expect(buildEmiShareText(input: input, result: result), expected);
    },
  );

  test('colons align within each block', () {
    final input = loanInputFromDefaults(LoanType.home);
    final result = useCase.execute(input);
    final lines = buildEmiShareText(input: input, result: result).split('\n');

    // Input block rows 2-5, result block rows 7-9.
    final inputColons = lines.sublist(2, 6).map((l) => l.indexOf(':')).toSet();
    final resultColons = lines
        .sublist(7, 10)
        .map((l) => l.indexOf(':'))
        .toSet();

    expect(inputColons, hasLength(1));
    expect(resultColons, hasLength(1));
  });

  test('renders Car Loan label and its default figures', () {
    final input = loanInputFromDefaults(LoanType.car);
    final result = useCase.execute(input);
    final text = buildEmiShareText(input: input, result: result);

    expect(text, contains('Loan Type    : Car Loan'));
    expect(text, contains('Interest Rate: 9.00% p.a.'));
    expect(text, contains('Tenure       : 5 Years'));
  });

  test('renders Personal Loan label', () {
    final input = loanInputFromDefaults(LoanType.personal);
    final result = useCase.execute(input);

    expect(
      buildEmiShareText(input: input, result: result),
      contains('Loan Type    : Personal Loan'),
    );
  });

  test(
    'totals are derived from the rounded EMI (SOW §4.3), not raw doubles',
    () {
      const input = LoanInput(
        principal: 1000000,
        annualRate: 10,
        tenureMonths: 12,
        loanType: LoanType.personal,
      );
      final result = useCase.execute(input);
      final text = buildEmiShareText(input: input, result: result);

      final roundedEmi = result.monthlyEmi.round();
      final expectedPayable = roundedEmi * 12;
      final expectedInterest = expectedPayable - 1000000;

      expect(
        text,
        contains('Total Payable    : ₹${_grouped(expectedPayable)}'),
      );
      expect(
        text,
        contains('Total Interest   : ₹${_grouped(expectedInterest)}'),
      );
    },
  );

  test('handles a fractional-year tenure', () {
    const input = LoanInput(
      principal: 500000,
      annualRate: 12,
      tenureMonths: 30,
      loanType: LoanType.personal,
    );
    final result = useCase.execute(input);

    expect(
      buildEmiShareText(input: input, result: result),
      contains('Tenure       : 2 Years 6 Months'),
    );
  });
}

String _grouped(int value) {
  final s = value.toString();
  if (s.length <= 3) return s;
  final head = s.substring(0, s.length - 3);
  final tail = s.substring(s.length - 3);
  final buf = StringBuffer();
  for (var i = 0; i < head.length; i++) {
    if (i > 0 && (head.length - i).isEven) buf.write(',');
    buf.write(head[i]);
  }
  return '$buf,$tail';
}
