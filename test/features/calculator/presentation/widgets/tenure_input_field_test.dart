import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/tenure_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int? lastMonths;

  Future<void> pump(
    WidgetTester tester, {
    int initialMonths = 240,
    TenureUnit initialUnit = TenureUnit.years,
  }) async {
    lastMonths = null;
    var months = initialMonths;
    var unit = initialUnit;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => TenureInputField(
              months: months,
              unit: unit,
              onMonthsChanged: (v) => setState(() {
                months = v;
                lastMonths = v;
              }),
              onUnitChanged: (u) => setState(() => unit = u),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows years by default', (tester) async {
    await pump(tester);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('Yr/Mo toggle converts the display but keeps months internal', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Mo'));
    await tester.pumpAndSettle();

    expect(find.text('240'), findsOneWidget);
    expect(lastMonths, isNull, reason: 'toggling the unit is not an edit');
  });

  testWidgets('typing years is stored as months', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '15');
    await tester.pump();
    expect(lastMonths, 180);
  });

  testWidgets('typing months is stored verbatim', (tester) async {
    await pump(tester, initialMonths: 60, initialUnit: TenureUnit.months);
    await tester.enterText(find.byType(TextField), '96');
    await tester.pump();
    expect(lastMonths, 96);
  });

  testWidgets('slider and text field stay in sync (years)', (tester) async {
    await pump(tester);
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pumpAndSettle();

    expect(lastMonths, isNotNull);
    expect(lastMonths! % 12, 0, reason: 'years slider -> whole years');
    expect(find.text('${lastMonths! ~/ 12}'), findsOneWidget);
  });

  testWidgets('above-range years entry is clamped on blur', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '40');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(lastMonths, 360);
    expect(find.text('30'), findsOneWidget);
  });
}
