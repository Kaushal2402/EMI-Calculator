import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/calculate_emi_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

/// A single AC-01 reference case.
///
/// [expectedEmi] is the reduce-balance EMI computed to full precision with the
/// SOW §4.3 formula. Standard financial calculators (BankBazaar, Groww, HDFC)
/// use the same formula and display the rounded value; AC-01 allows ±₹1.
/// The first three rows are additionally anchored to figures published in the
/// SOW itself (§4.1 defaults / §4.7 share sample).
class _RefCase {
  const _RefCase(
    this.label,
    this.principal,
    this.annualRate,
    this.months,
    this.expectedEmi,
  );

  final String label;
  final double principal;
  final double annualRate;
  final int months;
  final double expectedEmi;
}

const _referenceCases = <_RefCase>[
  // --- SOW-anchored ---------------------------------------------------------
  _RefCase(
    'Home Loan default (SOW §4.7 = ₹26,035)',
    3000000,
    8.5,
    240,
    26034.697001,
  ),
  _RefCase('Car Loan default (SOW §4.1)', 800000, 9, 60, 16606.684181),
  _RefCase('Personal Loan default (SOW §4.1)', 300000, 13, 36, 10108.185601),
  // --- commonly published references -------------------------------------
  _RefCase('₹10L @ 10% / 10y', 1000000, 10, 120, 13215.073688),
  _RefCase('₹5L @ 12% / 5y', 500000, 12, 60, 11122.223842),
  _RefCase('₹1L @ 12% / 1y', 100000, 12, 12, 8884.878868),
  // --- spread across the input space ------------------------------------
  _RefCase('₹25L @ 7.5% / 25y', 2500000, 7.5, 300, 18474.779445),
  _RefCase('₹15L @ 9.25% / 15y', 1500000, 9.25, 180, 15437.884347),
  _RefCase('₹7.5L @ 11% / 7y', 750000, 11, 84, 12841.827326),
  _RefCase('₹2L @ 14% / 2y', 200000, 14, 24, 9602.576654),
  _RefCase('₹50L @ 8% / 30y', 5000000, 8, 360, 36688.228694),
  _RefCase('₹12L @ 8.75% / 20y', 1200000, 8.75, 240, 10604.528507),
  _RefCase('₹3.5L @ 10.5% / 4y', 350000, 10.5, 48, 8961.182913),
  _RefCase('₹40L @ 9.5% / 25y', 4000000, 9.5, 300, 34947.866435),
  _RefCase('₹6L @ 12.5% / 6y', 600000, 12.5, 72, 11886.707221),
  _RefCase('₹9L @ 10% / 8y', 900000, 10, 96, 13656.747688),
  _RefCase('₹20L @ 8.4% / 15y', 2000000, 8.4, 180, 19577.732649),
  _RefCase('₹2.75L @ 15% / 5y', 275000, 15, 60, 6542.230774),
  _RefCase('₹33L @ 7.9% / 30y', 3300000, 7.9, 360, 23984.578373),
  _RefCase('₹1.25L @ 18% / 3y', 125000, 18, 36, 4519.049442),
  // --- boundary rates / amounts --------------------------------------
  _RefCase('min principal ₹10K @ 1% / 1y', 10000, 1, 12, 837.854116),
  _RefCase('max principal ₹5Cr @ 36% / 30y', 50000000, 36, 360, 1500035.867470),
  _RefCase('₹10K @ 36% / 1y', 10000, 36, 12, 1004.620855),
  _RefCase('₹5Cr @ 1% / 1y', 50000000, 1, 12, 4189270.577790),
];

LoanInput _input(_RefCase c) => LoanInput(
  principal: c.principal,
  annualRate: c.annualRate,
  tenureMonths: c.months,
  loanType: LoanType.home,
);

void main() {
  const useCase = CalculateEmiUseCase();

  group('CalculateEmiUseCase — reference cases (AC-01, ±₹1)', () {
    test('has at least 20 reference cases', () {
      expect(_referenceCases.length, greaterThanOrEqualTo(20));
    });

    for (final c in _referenceCases) {
      test(c.label, () {
        final result = useCase.execute(_input(c));
        expect(
          result.monthlyEmi,
          closeTo(c.expectedEmi, 1),
          reason: '${c.label}: EMI outside ±₹1 of reference',
        );
      });
    }

    test('Home Loan default rounds to the SOW §4.7 figure of ₹26,035', () {
      final result = useCase.execute(
        const LoanInput(
          principal: 3000000,
          annualRate: 8.5,
          tenureMonths: 240,
          loanType: LoanType.home,
        ),
      );
      expect(result.monthlyEmi.round(), 26035);
    });
  });

  group('CalculateEmiUseCase — totals & ratios', () {
    test('totalPayable == EMI × n and totalInterest == totalPayable − P', () {
      final result = useCase.execute(_input(_referenceCases.first));
      expect(result.totalPayable, closeTo(result.monthlyEmi * 240, 1e-6));
      expect(
        result.totalInterest,
        closeTo(result.totalPayable - 3000000, 1e-6),
      );
    });

    test('principalRatio + interestRatio == 1 and both in 0..1', () {
      for (final c in _referenceCases) {
        final r = useCase.execute(_input(c));
        expect(r.principalRatio + r.interestRatio, closeTo(1, 1e-9));
        expect(r.principalRatio, inInclusiveRange(0, 1));
        expect(r.interestRatio, inInclusiveRange(0, 1));
      }
    });
  });

  group('CalculateEmiUseCase — schedule invariants', () {
    for (final c in _referenceCases) {
      test('${c.label}: invariants hold', () {
        final r = useCase.execute(_input(c));

        // length == n
        expect(r.schedule.length, c.months);

        // final balance is exactly zero
        expect(r.schedule.last.outstandingBalance, 0);

        // Σ principal == P
        final sumPrincipal = r.schedule.fold<double>(
          0,
          (s, row) => s + row.principalComponent,
        );
        expect(sumPrincipal, closeTo(c.principal, 0.01));

        // Σ interest ≈ totalInterest (within rounding drift of one instalment)
        final sumInterest = r.schedule.fold<double>(
          0,
          (s, row) => s + row.interestComponent,
        );
        expect(sumInterest, closeTo(r.totalInterest, 1));

        // per-row: principal + interest == emi, balance non-increasing, no
        // negative components.
        var prevBalance = double.infinity;
        for (final row in r.schedule) {
          expect(
            row.principalComponent + row.interestComponent,
            closeTo(row.emi, 1e-6),
          );
          expect(row.outstandingBalance, lessThanOrEqualTo(prevBalance + 1e-6));
          expect(row.principalComponent, greaterThanOrEqualTo(-1e-6));
          expect(row.interestComponent, greaterThanOrEqualTo(-1e-6));
          prevBalance = row.outstandingBalance;
        }
      });
    }
  });

  group('CalculateEmiUseCase — edge cases', () {
    test('1-month tenure: single row repays the whole principal', () {
      final r = useCase.execute(
        const LoanInput(
          principal: 100000,
          annualRate: 12,
          tenureMonths: 1,
          loanType: LoanType.personal,
        ),
      );
      expect(r.schedule, hasLength(1));
      expect(r.schedule.single.principalComponent, closeTo(100000, 1e-6));
      expect(r.schedule.single.interestComponent, closeTo(1000, 1e-6));
      expect(r.schedule.single.outstandingBalance, 0);
      expect(r.monthlyEmi, closeTo(101000, 1e-6));
    });

    test('360-month tenure produces 360 rows', () {
      final r = useCase.execute(
        const LoanInput(
          principal: 5000000,
          annualRate: 8,
          tenureMonths: 360,
          loanType: LoanType.home,
        ),
      );
      expect(r.schedule, hasLength(360));
      expect(r.schedule.last.outstandingBalance, 0);
    });

    test('1% rate and 36% rate both stay finite and positive', () {
      for (final rate in [1.0, 36.0]) {
        final r = useCase.execute(
          LoanInput(
            principal: 1000000,
            annualRate: rate,
            tenureMonths: 120,
            loanType: LoanType.car,
          ),
        );
        expect(r.monthlyEmi.isFinite, isTrue);
        expect(r.monthlyEmi, greaterThan(0));
        expect(r.totalInterest, greaterThan(0));
      }
    });

    test('zero-interest loan: EMI == P / n, no interest anywhere', () {
      final r = useCase.execute(
        const LoanInput(
          principal: 1200000,
          annualRate: 0,
          tenureMonths: 120,
          loanType: LoanType.car,
        ),
      );
      expect(r.monthlyEmi, closeTo(10000, 1e-9));
      expect(r.totalInterest, closeTo(0, 1e-6));
      expect(r.totalPayable, closeTo(1200000, 1e-6));
      expect(r.interestRatio, closeTo(0, 1e-9));
      expect(r.principalRatio, closeTo(1, 1e-9));
      for (final row in r.schedule) {
        expect(row.interestComponent, closeTo(0, 1e-9));
        expect(row.principalComponent, closeTo(10000, 1e-6));
      }
      // balance decreases linearly
      expect(r.schedule[0].outstandingBalance, closeTo(1190000, 1e-6));
      expect(r.schedule[59].outstandingBalance, closeTo(600000, 1e-6));
      expect(r.schedule.last.outstandingBalance, 0);
    });

    test('is deterministic — equal input yields equal result', () {
      const input = LoanInput(
        principal: 730000,
        annualRate: 9.65,
        tenureMonths: 144,
        loanType: LoanType.home,
      );
      expect(useCase.execute(input), useCase.execute(input));
    });
  });
}
