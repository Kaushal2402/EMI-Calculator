import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/emi_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    required double principal,
    required double interest,
    required double totalPayable,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
          child: EmiChart(
            principal: principal,
            interest: interest,
            totalPayable: totalPayable,
          ),
        ),
      ),
    );
  }

  testWidgets('legend shows both segments with percentages that sum to 100', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(principal: 300000, interest: 300000, totalPayable: 600000),
    );
    await tester.pumpAndSettle();

    expect(find.text('Principal'), findsOneWidget);
    expect(find.text('Interest'), findsOneWidget);
    expect(find.text('50%'), findsNWidgets(2));
  });

  testWidgets(
    'legend percentages always sum to 100 even when rounding is odd',
    (
      tester,
    ) async {
      // 30,00,000 / 32,48,368 -> 48.0% / 52.0%
      await tester.pumpWidget(
        host(principal: 3000000, interest: 3248368, totalPayable: 6248368),
      );
      await tester.pumpAndSettle();

      expect(find.text('48%'), findsOneWidget);
      expect(find.text('52%'), findsOneWidget);
    },
  );

  testWidgets('legend shows the absolute value of each segment', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(principal: 3000000, interest: 3248368, totalPayable: 6248368),
    );
    await tester.pumpAndSettle();

    expect(find.text('₹30,00,000'), findsOneWidget);
    expect(find.text('₹32,48,368'), findsOneWidget);
  });

  testWidgets('centre shows the total payable', (tester) async {
    await tester.pumpWidget(
      host(principal: 3000000, interest: 3248368, totalPayable: 6248368),
    );
    await tester.pumpAndSettle();

    expect(find.text('₹62,48,368'), findsOneWidget);
    expect(find.text('TOTAL PAYABLE'), findsOneWidget);
  });

  testWidgets(
    'sweeps from empty to full on first render, settled after 1200ms',
    (tester) async {
      await tester.pumpWidget(
        host(principal: 300000, interest: 300000, totalPayable: 600000),
      );

      // Mid-animation: a non-zero filler segment exists (sweep < 1).
      await tester.pump(const Duration(milliseconds: 300));
      var data = tester.widget<PieChart>(find.byType(PieChart)).data;
      expect(data.sections.length, 3);

      await tester.pump(const Duration(milliseconds: 1200));
      data = tester.widget<PieChart>(find.byType(PieChart)).data;
      expect(data.sections.length, 2, reason: 'filler gone once fully swept');
      expect(data.sections[0].value, 300000);
      expect(data.sections[1].value, 300000);
    },
  );
}
