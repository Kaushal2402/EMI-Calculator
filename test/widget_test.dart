import 'package:emi_calculator/app.dart';
import 'package:emi_calculator/core/ads/ads_providers.dart';
import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    // The splash auto-navigates to the calculator, which reads
    // `loanInputProvider` -> `sharedPreferencesProvider`. Provide a mock store.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          adsEnabledProvider.overrideWithValue(false),
        ],
        child: const EmiCalculatorApp(),
      ),
    );

    // Splash shows the app name and by-line (SOW §5.1).
    expect(find.text('EMI Calculator'), findsOneWidget);
    expect(find.text('by Softpital'), findsOneWidget);

    // Let the 1.5s splash timer resolve, then settle the calculator screen.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Landed on the calculator with its loan-type selector.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('CALCULATE EMI'), findsOneWidget);
  });
}
