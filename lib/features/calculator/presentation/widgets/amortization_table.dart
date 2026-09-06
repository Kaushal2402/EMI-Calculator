import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/utils/number_formatter.dart';
import 'package:emi_calculator/features/calculator/domain/entities/amortization_row.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/amortization_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/amortization_unit_provider.dart';
import 'package:emi_calculator/shared/widgets/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Column widths, shared by the sticky header and every data row so the two
/// stay in perfect alignment.
const List<int> _columnFlex = [3, 4, 4, 4, 5];

/// Monthly / Yearly amortization schedule with a sticky header row
/// (SOW §4.4 / §5.3).
///
/// Returns a **sliver** (`SliverMainAxisGroup`) so it can live directly inside
/// the Results screen's single `CustomScrollView`: the header is a pinned
/// sliver that sticks under the AppBar while the rows scroll, and the rows are
/// lazily built by `SliverList.builder` so a 360-row schedule stays at 60fps
/// (AC-04) — no 360-child `DataTable`.
///
/// The break-even row (first period whose principal component overtakes its
/// interest component, per the domain crossover use case) is highlighted with
/// the `primaryContainer` fill + a `primary` leading rule, in both Monthly and
/// Yearly modes.
class AmortizationTable extends ConsumerWidget {
  /// Creates an [AmortizationTable].
  const AmortizationTable({required this.view, super.key});

  /// Resolved monthly + yearly schedule and break-even indices.
  final AmortizationView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(amortizationUnitProvider);
    final isMonthly = unit == AmortizationUnit.monthly;
    final rows = isMonthly ? view.monthly : view.yearly;
    final breakEvenIndex = isMonthly
        ? view.monthlyBreakEvenIndex
        : view.yearlyBreakEvenIndex;

    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: kSpacing24),
            child: SectionLabel('Amortization'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: kSpacingMD, bottom: kSpacingSM),
            child: _UnitToggle(
              unit: unit,
              onChanged: ref.read(amortizationUnitProvider.notifier).select,
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeader(isMonthly: isMonthly),
        ),
        SliverList.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) => _ScheduleRow(
            row: rows[i],
            periodLabel: '${rows[i].period}',
            isAlt: i.isOdd,
            isBreakEven: i == breakEvenIndex,
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onChanged});

  final AmortizationUnit unit;
  final ValueChanged<AmortizationUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = [
      unit == AmortizationUnit.monthly,
      unit == AmortizationUnit.yearly,
    ];
    return SizedBox(
      height: AppSizes.toggleButtonHeight,
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        constraints: const BoxConstraints(
          minHeight: AppSizes.toggleButtonHeight,
          minWidth: 88,
        ),
        isSelected: selected,
        onPressed: (i) => onChanged(
          i == 0 ? AmortizationUnit.monthly : AmortizationUnit.yearly,
        ),
        children: const [Text('Monthly'), Text('Yearly')],
      ),
    );
  }
}

/// Pinned header. Fixed 48dp extent (matches the data row height) and an
/// opaque background so scrolling rows pass cleanly underneath.
class _StickyHeader extends SliverPersistentHeaderDelegate {
  const _StickyHeader({required this.isMonthly});

  final bool isMonthly;

  @override
  double get minExtent => AppSizes.dataTableRowHeight;

  @override
  double get maxExtent => AppSizes.dataTableRowHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing:
          (theme.textTheme.labelMedium?.fontSize ?? 12) * kCapsLetterSpacing,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: _RowLayout(
        cells: [
          _Cell(isMonthly ? 'MONTH' : 'YEAR', style: style, alignEnd: false),
          _Cell('EMI', style: style),
          _Cell('PRINCIPAL', style: style),
          _Cell('INTEREST', style: style),
          _Cell('BALANCE', style: style),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyHeader oldDelegate) =>
      oldDelegate.isMonthly != isMonthly;
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.row,
    required this.periodLabel,
    required this.isAlt,
    required this.isBreakEven,
  });

  final AmortizationRow row;
  final String periodLabel;
  final bool isAlt;
  final bool isBreakEven;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color? background;
    if (isBreakEven) {
      background = scheme.primaryContainer;
    } else if (isAlt) {
      background = scheme.surfaceContainerHighest;
    } else {
      background = null;
    }

    final cellStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: isBreakEven ? FontWeight.w600 : null,
      color: isBreakEven ? scheme.onPrimaryContainer : null,
    );

    return Container(
      height: AppSizes.dataTableRowHeight,
      decoration: BoxDecoration(
        color: background,
        border: isBreakEven
            ? Border(left: BorderSide(color: scheme.primary, width: 3))
            : null,
      ),
      child: _RowLayout(
        cells: [
          _Cell(periodLabel, style: cellStyle, alignEnd: false),
          _Cell(_money(row.emi), style: cellStyle),
          _Cell(_money(row.principalComponent), style: cellStyle),
          _Cell(_money(row.interestComponent), style: cellStyle),
          _Cell(_money(row.outstandingBalance), style: cellStyle),
        ],
      ),
    );
  }

  static String _money(double value) => NumberFormatter.grouped(value.round());
}

class _RowLayout extends StatelessWidget {
  const _RowLayout({required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          Expanded(flex: _columnFlex[i], child: cells[i]),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {required this.style, this.alignEnd = true});

  final String text;
  final TextStyle? style;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingXS),
      child: Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(text, maxLines: 1, style: style),
        ),
      ),
    );
  }
}
