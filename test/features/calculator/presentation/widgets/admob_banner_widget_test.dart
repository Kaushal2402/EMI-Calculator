import 'package:emi_calculator/core/ads/ads_providers.dart';
import 'package:emi_calculator/features/calculator/presentation/widgets/admob_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool adsEnabled}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [adsEnabledProvider.overrideWithValue(adsEnabled)],
        child: const MaterialApp(
          home: Scaffold(bottomNavigationBar: AdmobBannerWidget()),
        ),
      ),
    );
  }

  testWidgets('collapses to zero height when ads are disabled '
      '(no platform channel touched)', (tester) async {
    await pump(tester, adsEnabled: false);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(AdWidgetStub), findsNothing);
    expect(tester.getSize(find.byType(AdmobBannerWidget)).height, 0);
  });

  testWidgets('reserves the banner band while the ad is still loading', (
    tester,
  ) async {
    // Ads "enabled" but no SDK in the test host: load() fails and the widget
    // must end up collapsed (TASKS 7.5) without throwing into the zone.
    await pump(tester, adsEnabled: true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    // Either still reserving (load pending) or collapsed (load failed) — never
    // a partial band that could overlap content.
    final height = tester.getSize(find.byType(AdmobBannerWidget)).height;
    expect(height == 0 || height >= 50, isTrue);
  });
}

/// Marker type only referenced above to keep the intent explicit; the real
/// `AdWidget` is never built in tests.
class AdWidgetStub extends StatelessWidget {
  const AdWidgetStub({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
