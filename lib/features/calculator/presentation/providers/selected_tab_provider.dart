import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier backing [selectedTabProvider] (SOW §7.2).
///
/// SOW §7.2 lists this as a `StateProvider<LoanType>`; the approved modern set
/// uses [NotifierProvider]. State is derived from
/// [loanInputProvider]'s `loanType` so the segmented tab and the form can never
/// disagree — there is exactly one source of truth.
class SelectedTabNotifier extends Notifier<LoanType> {
  @override
  LoanType build() {
    final loaded = ref.watch(
      loanInputProvider.select((state) => state.value?.loanType),
    );
    return loaded ?? kDefaultLoanType;
  }

  /// Switches the active loan-type tab.
  ///
  /// Per AC-05 / SOW §4.1 this resets **all** inputs to [type]'s presets. The
  /// reset is delegated to [LoanInputNotifier.setLoanType]; this notifier's own
  /// state then follows via [build]'s `watch`, so no direct `state =` is needed.
  void select(LoanType type) {
    if (state == type) return;
    ref.read(loanInputProvider.notifier).setLoanType(type);
  }
}

/// Active loan-type tab (SOW §7.2 `selectedTabProvider`).
final NotifierProvider<SelectedTabNotifier, LoanType> selectedTabProvider =
    NotifierProvider<SelectedTabNotifier, LoanType>(SelectedTabNotifier.new);
