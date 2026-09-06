import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/aggregate_yearly_schedule_use_case.dart';
import 'package:emi_calculator/features/calculator/domain/use_cases/find_break_even_row_use_case.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the pure [AggregateYearlyScheduleUseCase].
final Provider<AggregateYearlyScheduleUseCase>
aggregateYearlyScheduleUseCaseProvider =
    Provider<AggregateYearlyScheduleUseCase>(
      (ref) => const AggregateYearlyScheduleUseCase(),
    );

/// Exposes the pure [FindBreakEvenRowUseCase].
final Provider<FindBreakEvenRowUseCase> findBreakEvenRowUseCaseProvider =
    Provider<FindBreakEvenRowUseCase>(
      (ref) => const FindBreakEvenRowUseCase(),
    );

/// Everything the Results screen needs to draw the amortization section:
/// both breakdown granularities plus the break-even row index for each
/// (SOW §4.4).
@immutable
class AmortizationView {
  /// Creates an amortization view model.
  const AmortizationView({
    required this.monthly,
    required this.yearly,
    required this.monthlyBreakEvenIndex,
    required this.yearlyBreakEvenIndex,
  });

  /// Month-by-month schedule (length == tenure in months).
  final List<AmortizationRow> monthly;

  /// Year-by-year aggregation of [monthly].
  final List<AmortizationRow> yearly;

  /// 0-based index of the break-even row in [monthly], or `null` if the
  /// principal component never overtakes the interest component
  /// (e.g. a zero-interest loan returns `0`).
  final int? monthlyBreakEvenIndex;

  /// 0-based index of the break-even row in [yearly], or `null`.
  final int? yearlyBreakEvenIndex;

  @override
  bool operator ==(Object other) =>
      other is AmortizationView &&
      listEquals(other.monthly, monthly) &&
      listEquals(other.yearly, yearly) &&
      other.monthlyBreakEvenIndex == monthlyBreakEvenIndex &&
      other.yearlyBreakEvenIndex == yearlyBreakEvenIndex;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(monthly),
    Object.hashAll(yearly),
    monthlyBreakEvenIndex,
    yearlyBreakEvenIndex,
  );
}

/// Derives the monthly + yearly schedule and break-even indices from
/// [emiResultProvider] (SOW §7.2 `amortizationProvider`).
///
/// Pure derivation — it inherits [emiResultProvider]'s debounce and does no
/// persistence of its own.
final FutureProvider<AmortizationView> amortizationProvider =
    FutureProvider<AmortizationView>((ref) async {
      final result = await ref.watch(emiResultProvider.future);
      final monthly = result.schedule;
      final yearly = ref
          .watch(aggregateYearlyScheduleUseCaseProvider)
          .execute(monthly);
      final findBreakEven = ref.watch(findBreakEvenRowUseCaseProvider);

      return AmortizationView(
        monthly: monthly,
        yearly: yearly,
        monthlyBreakEvenIndex: findBreakEven.execute(monthly),
        yearlyBreakEvenIndex: findBreakEven.execute(yearly),
      );
    });
