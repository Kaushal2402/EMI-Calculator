import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/selected_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Segmented control for Home / Car / Personal loan (SOW §4.1, §5.2).
///
/// Height 40dp, fully-rounded 8dp corners (SOW §6.3). Switching a tab delegates
/// to [SelectedTabNotifier.select], which resets every input to that loan
/// type's preset defaults (AC-05).
class LoanTypeSelector extends ConsumerWidget {
  /// Creates a [LoanTypeSelector].
  const LoanTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTabProvider);

    return SizedBox(
      height: AppSizes.segmentedButtonHeight,
      child: SegmentedButton<LoanType>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: const StadiumBorder(),
        ),
        segments: const [
          ButtonSegment(
            value: LoanType.home,
            label: Text('Home'),
            icon: Icon(Icons.home_outlined),
          ),
          ButtonSegment(
            value: LoanType.car,
            label: Text('Car'),
            icon: Icon(Icons.directions_car_outlined),
          ),
          ButtonSegment(
            value: LoanType.personal,
            label: Text('Personal'),
            icon: Icon(Icons.person_outline),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (selection) =>
            ref.read(selectedTabProvider.notifier).select(selection.first),
      ),
    );
  }
}
