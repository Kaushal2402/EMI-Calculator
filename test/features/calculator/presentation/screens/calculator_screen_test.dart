import 'package:emi_calculator/core/ads/ads_providers.dart';
import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amount_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/rate_input_field.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/tenure_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Run the engine synchronously so the CTA gate settles immediately.
        calcDebounceProvider.overrideWithValue(Duration.zero),
        // No live interstitial in widget tests.
        adsEnabledProvider.overrideWithValue(false),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/calculator',
      routes: [
        GoRoute(
          path: '/calculator',
          builder: (context, state) => const CalculatorScreen(),
        ),
        GoRoute(
          path: '/results',
          builder: (context, state) =>
              const Scaffold(body: Text('RESULTS PAGE')),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('opens with the Home Loan defaults (SOW §4.1)', (tester) async {
    await pump(tester);
    expect(find.text('30,00,000'), findsOneWidget);
    expect(find.text('8.50'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('editing an input flows into loanInputProvider', (tester) async {
    final container = await pump(tester);

    await tester.enterText(
      find.descendant(
        of: find.byType(AmountInputField),
        matching: find.byType(TextField),
      ),
      '2500000',
    );
    await tester.pump();

    expect(
      container.read(loanInputProvider).requireValue.principal,
      2500000,
    );
  });

  testWidgets('sections and CTA are present', (tester) async {
    await pump(tester);
    expect(find.text('PRINCIPAL AMOUNT'), findsOneWidget);
    expect(find.text('ANNUAL INTEREST RATE'), findsOneWidget);
    expect(find.text('LOAN TENURE'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'CALCULATE EMI'), findsOneWidget);
    expect(find.byType(AmountInputField), findsOneWidget);
    expect(find.byType(RateInputField), findsOneWidget);
    expect(find.byType(TenureInputField), findsOneWidget);
  });

  testWidgets('CALCULATE EMI navigates to /results', (tester) async {
    await pump(tester);
    final cta = find.widgetWithText(FilledButton, 'CALCULATE EMI');
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(find.text('RESULTS PAGE'), findsOneWidget);
  });

  testWidgets('switching loan type resets the form (AC-05)', (tester) async {
    final container = await pump(tester);

    container.read(loanInputProvider.notifier).setPrincipal(111);
    await tester.pump();

    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();

    final input = container.read(loanInputProvider).requireValue;
    expect(input.loanType, LoanType.personal);
    expect(input.principal, 300000);
    expect(input.annualRate, 13);
    expect(input.tenureMonths, 36);
    expect(find.text('3,00,000'), findsOneWidget);
    expect(find.text('13.00'), findsOneWidget);
  });

  testWidgets('renders in dark mode without layout errors', (tester) async {
    await pump(tester, themeMode: ThemeMode.dark);
    expect(tester.takeException(), isNull);
    expect(find.text('CALCULATE EMI'), findsOneWidget);
  });

  testWidgets('renders at 1.3x text scale without overflow', (tester) async {
    await pump(tester, textScale: 1.3);
    // Scroll through the whole form; any RenderFlex overflow throws here.
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
