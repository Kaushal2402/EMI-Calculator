import 'package:emi_calculator/features/calculator/presentation/providers/interstitial_ad_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<InterstitialAdController> makeController({
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = await SharedPreferences.getInstance();
  // enabled:false -> no ad SDK is touched; the counter + boundary logic still
  // runs, which is what these tests exercise.
  return InterstitialAdController(store, enabled: false);
}

void main() {
  test('never due before the first full group of 5 calculations', () async {
    final c = await makeController();
    for (var i = 0; i < 4; i++) {
      await c.registerCalculation();
      expect(c.isDueAtBoundary, isFalse, reason: 'calc ${i + 1}');
    }
  });

  test('due once the 5th calculation lands', () async {
    final c = await makeController();
    for (var i = 0; i < 5; i++) {
      await c.registerCalculation();
    }
    expect(c.isDueAtBoundary, isTrue);
  });

  test('maybeShowAtBoundary is a no-op when ads are disabled and always '
      'resolves', () async {
    final c = await makeController();
    for (var i = 0; i < 5; i++) {
      await c.registerCalculation();
    }
    await c.maybeShowAtBoundary(); // must not throw / hang
    // Disabled controller cannot present, so the "last shown" marker is
    // untouched and it stays due.
    expect(c.isDueAtBoundary, isTrue);
  });

  test('stays due across repeated boundary checks until an ad is actually '
      'shown (no double-fire within a group)', () async {
    // Simulate a group already consumed: count 5, last-shown 5 -> not due.
    final c = await makeController(
      prefs: {
        'ads.calc_count': 5,
        'ads.calc_count_at_last_interstitial': 5,
      },
    );
    expect(c.isDueAtBoundary, isFalse);

    // Four more calcs — still within the same next group, not due yet.
    for (var i = 0; i < 4; i++) {
      await c.registerCalculation();
    }
    expect(c.isDueAtBoundary, isFalse);

    // 10th calc completes the next group -> due again.
    await c.registerCalculation();
    expect(c.isDueAtBoundary, isTrue);
  });

  test('robust to a burst that overshoots an exact multiple', () async {
    // Jump straight past 5 to 7 without a boundary check in between.
    final c = await makeController(prefs: {'ads.calc_count': 7});
    expect(c.isDueAtBoundary, isTrue);
  });

  test('showOnCtaTap is a safe no-op when ads are disabled and always '
      'resolves', () async {
    final c = await makeController();
    await c.showOnCtaTap(); // must not throw / hang
    await c.showOnCtaTap(); // repeated taps are fine too
  });
}
