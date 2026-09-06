import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/loan_input_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/screens/results_screen.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/amortization_table.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/emi_chart.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> makeContainer() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        calcDebounceProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    ProviderContainer container, {
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: const ResultsScreen(),
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: child!,
          ),
        ),
      ),
    );
  }

  testWidgets('paints summary + chart on the first frame from a warm '
      'emiResultProvider (AC-03)', (tester) async {
    final container = await makeContainer();
    // Warm the engine the way the Calculator screen does before navigating.
    await container.read(emiResultProvider.future);

    await pumpScreen(tester, container);
    await tester.pump(); // a single frame — no settle

    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.text('₹26,035'), findsOneWidget, reason: 'Home default EMI');

    await tester.pumpAndSettle();
  });

  testWidgets('renders all three sections', (tester) async {
    final container = await makeContainer();
    await container.read(emiResultProvider.future);

    await pumpScreen(tester, container);
    await tester.pumpAndSettle();

    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.text('BREAKUP'), findsOneWidget);
    expect(find.byType(EmiChart), findsOneWidget);
    expect(find.text('AMORTIZATION'), findsOneWidget);
    expect(find.byType(AmortizationTable), findsOneWidget);
  });

  testWidgets('renders in dark mode without layout errors', (tester) async {
    final container = await makeContainer();
    await container.read(emiResultProvider.future);

    await pumpScreen(tester, container, themeMode: ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SummaryCard), findsOneWidget);
  });

  testWidgets('renders at 1.3x text scale without overflow', (tester) async {
    final container = await makeContainer();
    await container.read(emiResultProvider.future);

    await pumpScreen(tester, container, textScale: 1.3);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('360-row schedule is built lazily (AC-04)', (tester) async {
    final container = await makeContainer();
    await container.read(emiResultProvider.future);
    container.read(loanInputProvider.notifier).setTenureMonths(360);

    await pumpScreen(tester, container);
    await tester.pumpAndSettle();

    // Scroll the table into view so some rows are actually laid out.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    final builtRows = find.byWidgetPredicate(
      (w) => w.runtimeType.toString() == '_ScheduleRow',
    );
    final count = tester.widgetList(builtRows).length;

    expect(count, greaterThan(0));
    expect(
      count,
      lessThan(40),
      reason: 'only on-screen rows are instantiated, not all 360',
    );
  });
}
