import 'package:emi_calculator/core/constants/app_info.dart';
import 'package:emi_calculator/core/router/app_router.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/features/info/presentation/screens/info_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1,
  }) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/info'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/info',
          pageBuilder: (_, _) =>
              const ModalBottomSheetPage<void>(child: InfoBottomSheet()),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
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
    );
  }

  testWidgets('shows the formula, how-computed text and app version', (
    tester,
  ) async {
    await pumpHost(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(
      find.text('EMI = P × r × (1 + r)ⁿ / ((1 + r)ⁿ − 1)'),
      findsOneWidget,
    );
    expect(find.textContaining('reduces the principal'), findsOneWidget);
    expect(find.text('EMI Calculator v$kAppVersion'), findsOneWidget);
  });

  testWidgets('is a modal bottom sheet with a drag handle', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    // The Material drag handle renders as a small rounded bar; showDragHandle
    // wires it up on the BottomSheet.
    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.showDragHandle, isTrue);
    expect(sheet.enableDrag, isTrue);
  });

  testWidgets('height is capped at 60% of screen height', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpHost(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final sheetSize = tester.getSize(find.byType(BottomSheet));
    expect(sheetSize.height, lessThanOrEqualTo(900 * 0.6 + 0.5));
    // Content is scrollable so it stays usable under the cap.
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('drags down to dismiss', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(InfoBottomSheet), findsOneWidget);

    // Drag from the drag-handle region at the top of the sheet.
    final rect = tester.getRect(find.byType(BottomSheet));
    await tester.flingFrom(
      rect.topCenter + const Offset(0, 12),
      const Offset(0, 600),
      1500,
    );
    await tester.pumpAndSettle();

    expect(find.byType(InfoBottomSheet), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('renders in dark mode and at 1.3x text scale without overflow', (
    tester,
  ) async {
    await pumpHost(tester, themeMode: ThemeMode.dark, textScale: 1.3);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Scroll the capped sheet to exercise the full content.
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('EMI Calculator v$kAppVersion'), findsOneWidget);
  });
}
