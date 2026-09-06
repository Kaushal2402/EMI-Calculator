import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier backing [loanInputProvider] (SOW §7.2).
///
/// Holds the calculator form state — principal, annual rate, tenure (always in
/// months) and loan type. [build] restores the last persisted input from the
/// `LoanRepository`; on a cold start the repository already yields the Home
/// Loan preset (Phase 2.3), so there is no `null` / first-launch branch here.
///
/// ## Type choice — `AsyncNotifier` (documented)
///
/// SOW §7.2 predates Riverpod 3 and lists `StateNotifierProvider`. The approved
/// modern set (pubspec note, 2026-09-06) mandates `NotifierProvider`. Restoring
/// from `SharedPreferences` is inherently asynchronous, so this is an
/// [AsyncNotifierProvider]: `build` awaits the repository and consumers get an
/// `AsyncValue<LoanInput>` that is `loading` only for the first frame.
///
/// ## Naming — hand-written, not `@riverpod` codegen (documented deviation)
///
/// The phase brief asks for `@riverpod` codegen. Codegen derives the provider
/// name from the Notifier class name, and the only class name that yields the
/// SOW-mandated symbol `loanInputProvider` is `LoanInput` — which collides with
/// the domain entity of the same name that this file must import. Renaming the
/// provider (e.g. `loanFormProvider`) would ripple through Phase 4/5 and the
/// brief itself, which all reference `loanInputProvider`. The rest of the
/// provider layer (`themeModeProvider`, `emiResultProvider`, …) is already
/// hand-written `Notifier`s — the exact shape codegen expands to — so this
/// stays consistent with the codebase. Freezed entity codegen is unaffected.
class LoanInputNotifier extends AsyncNotifier<LoanInput> {
  @override
  Future<LoanInput> build() => ref.watch(loanRepositoryProvider).getLastInput();

  /// Selects [type] and resets **every** field to that type's preset defaults
  /// (AC-05, SOW §4.1). Uses the single source of truth in
  /// `core/constants/loan_defaults.dart`.
  void setLoanType(LoanType type) {
    state = AsyncData(loanInputFromDefaults(type));
  }

  /// Updates the principal (₹). Range clamping is the input widget's job
  /// (Phase 4.8); this setter stores what it is given.
  void setPrincipal(double principal) =>
      _patch((input) => input.copyWith(principal: principal));

  /// Updates the annual interest rate (percentage, e.g. `8.5`).
  void setAnnualRate(double annualRate) =>
      _patch((input) => input.copyWith(annualRate: annualRate));

  /// Updates the tenure. Always stored in months regardless of the UI unit
  /// toggle (`tenureUnitProvider`).
  void setTenureMonths(int tenureMonths) =>
      _patch((input) => input.copyWith(tenureMonths: tenureMonths));

  /// Replaces the whole input in one shot (e.g. restoring a shared result).
  void setInput(LoanInput input) => state = AsyncData(input);

  void _patch(LoanInput Function(LoanInput current) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }
}

/// Calculator form state (SOW §7.2 `loanInputProvider`).
final AsyncNotifierProvider<LoanInputNotifier, LoanInput> loanInputProvider =
    AsyncNotifierProvider<LoanInputNotifier, LoanInput>(LoanInputNotifier.new);
