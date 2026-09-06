@Tags(['preview'])
library;

import 'package:emi_calculator/core/ads/ads_providers.dart';
import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:emi_calculator/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:emi_calculator/features/calculator/presentation/screens/results_screen.dart';
import 'package:emi_calculator/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full-screen visual previews. Not a CI gate — run explicitly with
/// `flutter test --update-goldens test/preview` to regenerate the PNGs under
/// `test/preview/goldens/` for design review.
void main() {
  Future<ProviderContainer> container() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        calcDebounceProvider.overrideWithValue(Duration.zero),
        adsEnabledProvider.overrideWithValue(false),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> shoot(
    WidgetTester tester, {
    required String name,
    required Widget screen,
    required ProviderContainer c,
    Brightness brightness = Brightness.light,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532); // iPhone 13/14 @3x
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        home: UncontrolledProviderScope(container: c, child: screen),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      // Screens with an indefinite animation (splash progress bar) never
      // settle — pump enough for the icon asset to decode, then snapshot.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(tester.takeException(), isNull);

    // Pixel comparison only runs when explicitly regenerating
    // (`flutter test --update-goldens test/preview`). A plain `flutter test`
    // still pumps every screen — catching layout overflow / build errors —
    // but skips the full-screen snapshot match, which is too host-sensitive
    // (macOS vs CI Linux AA) to gate on. See qa/bugs.md P2-01.
    if (autoUpdateGoldenFiles) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    }
    // For `settle: false` screens (splash) we deliberately stop before the
    // 1.5s navigation timer fires; `SplashScreen.dispose` cancels it at
    // teardown, so nothing leaks.
  }

  testWidgets('splash — light', (tester) async {
    await shoot(
      tester,
      name: 'splash_light',
      screen: const SplashScreen(),
      c: await container(),
      settle: false,
    );
  });

  testWidgets('calculator — light', (tester) async {
    await shoot(
      tester,
      name: 'calculator_light',
      screen: const CalculatorScreen(),
      c: await container(),
    );
  });

  testWidgets('calculator — dark', (tester) async {
    await shoot(
      tester,
      name: 'calculator_dark',
      screen: const CalculatorScreen(),
      c: await container(),
      brightness: Brightness.dark,
    );
  });

  testWidgets('results — light', (tester) async {
    final c = await container();
    await c.read(emiResultProvider.future);
    await shoot(
      tester,
      name: 'results_light',
      screen: const ResultsScreen(),
      c: c,
    );
  });

  testWidgets('results — dark', (tester) async {
    final c = await container();
    await c.read(emiResultProvider.future);
    await shoot(
      tester,
      name: 'results_dark',
      screen: const ResultsScreen(),
      c: c,
      brightness: Brightness.dark,
    );
  });
}
