import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier backing [tenureUnitProvider] (SOW §7.2).
///
/// Presentation-only: it controls whether the tenure field shows Years or
/// Months (SOW §4.2 Yr/Mo toggle). The underlying [LoanInput.tenureMonths] is
/// **always** stored in months regardless of this value.
///
/// SOW §7.2 lists a `StateProvider<TenureUnit>`; the approved modern set uses
/// [NotifierProvider].
class TenureUnitNotifier extends Notifier<TenureUnit> {
  @override
  TenureUnit build() => TenureUnit.years;

  /// Sets the display unit explicitly.
  void select(TenureUnit unit) {
    if (state == unit) return;
    state = unit;
  }

  /// Flips between Years and Months.
  void toggle() =>
      state = state == TenureUnit.years ? TenureUnit.months : TenureUnit.years;
}

/// Tenure display unit — Years vs Months (SOW §7.2 `tenureUnitProvider`).
final NotifierProvider<TenureUnitNotifier, TenureUnit> tenureUnitProvider =
    NotifierProvider<TenureUnitNotifier, TenureUnit>(TenureUnitNotifier.new);
