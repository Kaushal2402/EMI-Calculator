import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Granularity of the amortization table on the Results screen (SOW §5.3).
enum AmortizationUnit {
  /// Month-by-month rows.
  monthly,

  /// Year-by-year aggregated rows.
  yearly,
}

/// Notifier backing [amortizationUnitProvider].
///
/// This is **presentation state for the Results screen only** — deliberately
/// separate from `tenureUnitProvider` (which is the Calculator screen's Yr/Mo
/// entry toggle). They change independently and mean different things.
class AmortizationUnitNotifier extends Notifier<AmortizationUnit> {
  @override
  AmortizationUnit build() => AmortizationUnit.monthly;

  /// Selects [unit] as the active table granularity.
  void select(AmortizationUnit unit) {
    if (state == unit) return;
    state = unit;
  }
}

/// Monthly vs Yearly toggle for the amortization table (SOW §5.3).
final NotifierProvider<AmortizationUnitNotifier, AmortizationUnit>
amortizationUnitProvider =
    NotifierProvider<AmortizationUnitNotifier, AmortizationUnit>(
      AmortizationUnitNotifier.new,
    );
