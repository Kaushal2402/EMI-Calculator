import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpSplash(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
        GoRoute(
          path: '/calculator',
          builder: (_, _) => const Scaffold(body: Text('CALCULATOR PAGE')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light(),
      ),
    );
  }

  testWidgets('shows the app name, by-line, icon art and progress bar', (
    tester,
  ) async {
    await pumpSplash(tester);

    expect(find.text('EMI Calculator'), findsOneWidget);
    expect(find.text('by Softpital'), findsOneWidget);

    // App icon art on its rounded card.
    expect(
      find.image(const AssetImage('assets/icon/app_icon.png')),
      findsOneWidget,
    );
    final iconBox = tester.widget<Container>(
      find
          .ancestor(
            of: find.image(const AssetImage('assets/icon/app_icon.png')),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(iconBox.constraints?.maxWidth, SplashScreen.iconSize);

    // Slim progress bar.
    final bar = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(bar.minHeight, 3);

    // Drain the pending navigation timer.
    await tester.pump(SplashScreen.displayDuration);
    await tester.pumpAndSettle();
  });

  testWidgets('stays on splash before 1.5s, then navigates to /calculator', (
    tester,
  ) async {
    await pumpSplash(tester);

    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('EMI Calculator'), findsOneWidget);
    expect(find.text('CALCULATOR PAGE'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('CALCULATOR PAGE'), findsOneWidget);
    expect(find.text('EMI Calculator'), findsNothing);
  });

  testWidgets('cancels the timer when disposed early (no navigation)', (
    tester,
  ) async {
    await pumpSplash(tester);
    await tester.pump(const Duration(milliseconds: 500));

    // Replace the tree before the timer fires.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
  });
}
