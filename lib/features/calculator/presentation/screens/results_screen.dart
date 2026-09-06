import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/amortization_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/utils/emi_share_text.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/admob_banner_widget.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amortization_table.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/emi_chart.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/summary_card.dart';
import 'package:emi_calculator/shared/widgets/app_scaffold.dart';
import 'package:emi_calculator/shared/widgets/error_view.dart';
import 'package:emi_calculator/shared/widgets/section_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// Results screen (SOW §5.3).
///
/// Summary card, interest-vs-principal donut and the amortization schedule.
/// Everything is driven by the already-warm `emiResultProvider` (kept alive by
/// the Calculator screen), so the summary and chart paint on the first frame
/// with no async gap (AC-03). The whole screen is a single `CustomScrollView`
/// so the amortization header can pin under the AppBar as the rows scroll.
///
/// Share action and the AdMob banner land in Phases 6–7.
class ResultsScreen extends ConsumerWidget {
  /// Creates the results screen.
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(emiResultProvider);
    final result = resultAsync.value;
    final input = ref.watch(loanInputProvider).value;
    final canShare = result != null && input != null;

    return AppScaffold(
      title: 'Results',
      leading: BackButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.calculator),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: canShare
              ? () => _shareSummary(input: input, result: result)
              : null,
        ),
      ],
      // Banner pinned above the system nav, always on the results view
      // (SOW §4.8). It owns the bottom safe-area inset and collapses on a
      // load failure (offline) so no empty strip is left behind.
      bottomNavigationBar: const AdmobBannerWidget(),
      body: switch (resultAsync) {
        AsyncData(:final value) => _ResultsBody(result: value),
        AsyncError(:final error) => ErrorView(message: '$error'),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Opens the native share sheet with the SOW §4.7 plain-text summary
/// (AC-06). The share sheet itself is platform UI; the text is built by
/// [buildEmiShareText].
Future<void> _shareSummary({
  required LoanInput input,
  required EmiResult result,
}) {
  return SharePlus.instance.share(
    ShareParams(
      text: buildEmiShareText(input: input, result: result),
      subject: 'EMI Calculator Result',
    ),
  );
}

class _ResultsBody extends ConsumerWidget {
  const _ResultsBody({required this.result});

  final EmiResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewAsync = ref.watch(amortizationProvider);
    final principal = result.totalPayable - result.totalInterest;

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            const SizedBox(height: kSpacingLG),
            SummaryCard(
              monthlyEmi: result.monthlyEmi,
              totalInterest: result.totalInterest,
              totalPayable: result.totalPayable,
            ),
            const SizedBox(height: kSpacing24),
            const SectionLabel('Breakup'),
            const SizedBox(height: kSpacingLG),
            Center(
              child: EmiChart(
                principal: principal,
                interest: result.totalInterest,
                totalPayable: result.totalPayable,
              ),
            ),
          ]),
        ),
        switch (viewAsync) {
          AsyncData(:final value) => AmortizationTable(view: value),
          AsyncError(:final error) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: kSpacing24),
              child: ErrorView(message: '$error'),
            ),
          ),
          _ => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: kSpacing24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        },
        const SliverToBoxAdapter(
          child: SizedBox(height: kSpacing24),
        ),
      ],
    );
  }
}
