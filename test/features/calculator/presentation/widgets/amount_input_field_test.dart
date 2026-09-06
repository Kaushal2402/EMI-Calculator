import 'package:emi_calculator/core/utils/number_formatter.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amount_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double? lastValue;

  Future<void> pump(WidgetTester tester, {double initial = 3000000}) async {
    lastValue = null;
    var current = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AmountInputField(
              value: current,
              onChanged: (v) => setState(() {
                current = v;
                lastValue = v;
              }),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders the initial value grouped in the Indian system', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('30,00,000'), findsOneWidget);
  });

  testWidgets('typing a valid amount propagates the parsed value', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '4500000');
    await tester.pump();
    expect(lastValue, 4500000);
    // Re-grouped live.
    expect(find.text('45,00,000'), findsOneWidget);
  });

  testWidgets('slider and text field stay in sync', (tester) async {
    await pump(tester);
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pumpAndSettle();

    expect(lastValue, isNotNull);
    expect(lastValue! % 1000, 0, reason: 'slider snaps to ₹1,000');
    expect(lastValue, greaterThan(3000000));
    expect(
      find.text(NumberFormatter.grouped(lastValue!.round())),
      findsOneWidget,
      reason: 'text field mirrors the slider',
    );
  });

  testWidgets('below-range entry shows an error and is not propagated', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '999');
    await tester.pump();
    expect(lastValue, isNull);
    expect(find.text('₹10,000 – ₹5,00,00,000'), findsWidgets);
  });

  testWidgets('out-of-range entry is clamped on blur', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '99');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(lastValue, 10000);
    expect(find.text('10,000'), findsOneWidget);
  });
}
