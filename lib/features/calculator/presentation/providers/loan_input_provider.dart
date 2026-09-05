import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier backing [loanInputProvider].
///
/// PHASE 0 SCAFFOLD: seeded synchronously with the Home Loan defaults. Phase 3
/// (task 3.1) regenerates this with Riverpod codegen and async init from
/// `LoanRepository`.
class LoanInputNotifier extends Notifier<LoanInput> {
  @override
  LoanInput build() => const LoanInput(
    principal: 3000000,
    annualRate: 8.5,
    tenureMonths: 240,
    loanType: kDefaultLoanType,
  );

  // Mutators (setType, setPrincipal, …) land in Phase 3 / task 3.1.
}

/// Holds the calculator form state (SOW §7.2 `loanInputProvider`).
final NotifierProvider<LoanInputNotifier, LoanInput> loanInputProvider =
    NotifierProvider<LoanInputNotifier, LoanInput>(LoanInputNotifier.new);
