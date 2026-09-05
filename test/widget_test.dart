import 'package:emi_calculator/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EmiCalculatorApp()),
    );

    // Splash shows the app name and by-line (SOW §5.1).
    expect(find.text('EMI Calculator'), findsOneWidget);
    expect(find.text('by Softpital'), findsOneWidget);

    // Let the 1.5s splash timer resolve so the test exits cleanly.
    await tester.pump(const Duration(seconds: 2));
  });
}
