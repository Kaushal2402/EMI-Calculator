import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/metric_tile.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    required Brightness brightness,
    double monthlyEmi = 26034.867,
    double totalInterest = 3248368.1,
    double totalPayable = 6248368.1,
  }) {
    return MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SummaryCard(
              monthlyEmi: monthlyEmi,
              totalInterest: totalInterest,
              totalPayable: totalPayable,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders three tiles with labels', (tester) async {
    await tester.pumpWidget(host(brightness: Brightness.light));

    expect(find.byType(MetricTile), findsNWidgets(3));
    expect(find.text('MONTHLY EMI'), findsOneWidget);
    expect(find.text('TOTAL INTEREST'), findsOneWidget);
    expect(find.text('TOTAL PAYABLE'), findsOneWidget);
  });

  testWidgets('display-rounds each value to the nearest rupee, Indian format '
      '(SOW §4.3)', (tester) async {
    await tester.pumpWidget(host(brightness: Brightness.light));

    // 26034.867 -> 26,035 ; 32,48,368 ; 62,48,368
    expect(find.text('₹26,035'), findsOneWidget);
    expect(find.text('₹32,48,368'), findsOneWidget);
    expect(find.text('₹62,48,368'), findsOneWidget);
  });

  testWidgets('value uses tabular figures', (tester) async {
    await tester.pumpWidget(host(brightness: Brightness.light));

    final text = tester.widget<Text>(find.text('₹26,035'));
    expect(
      text.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    expect(text.style?.fontWeight, FontWeight.w700);
  });

  testWidgets('golden — light', (tester) async {
    await tester.pumpWidget(host(brightness: Brightness.light));
    await expectLater(
      find.byType(SummaryCard),
      matchesGoldenFile('goldens/summary_card_light.png'),
    );
  });

  testWidgets('golden — dark', (tester) async {
    await tester.pumpWidget(host(brightness: Brightness.dark));
    await expectLater(
      find.byType(SummaryCard),
      matchesGoldenFile('goldens/summary_card_dark.png'),
    );
  });
}
