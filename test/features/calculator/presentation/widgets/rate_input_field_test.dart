import 'package:emi_calculator/features/calculator/presentation/widgets/rate_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  double? lastValue;

  Future<void> pump(WidgetTester tester, {double initial = 8.5}) async {
    lastValue = null;
    var current = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => RateInputField(
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

  testWidgets('renders the initial rate as XX.XX', (tester) async {
    await pump(tester);
    expect(find.text('8.50'), findsOneWidget);
  });

  testWidgets('typing a valid rate propagates it', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '9.25');
    await tester.pump();
    expect(lastValue, 9.25);
  });

  testWidgets('slider snaps to the 0.05 step and mirrors the field', (
    tester,
  ) async {
    await pump(tester);
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pumpAndSettle();

    expect(lastValue, isNotNull);
    expect(lastValue, inInclusiveRange(1, 36));
    expect(
      (lastValue! * 100).round() % 5,
      0,
      reason: 'rounded to a 0.05 step',
    );
    expect(find.text(lastValue!.toStringAsFixed(2)), findsOneWidget);
  });

  testWidgets('above-range entry is clamped to 36.00 on blur', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '50');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(lastValue, 36);
    expect(find.text('36.00'), findsOneWidget);
  });

  testWidgets('below-range entry shows an error and is not propagated', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '0.5');
    await tester.pump();
    expect(lastValue, isNull);
    expect(find.text('1.00% – 36.00%'), findsWidgets);
  });
}
