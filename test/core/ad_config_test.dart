import 'package:emi_calculator/core/config/ad_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // `flutter test` runs in debug mode (kReleaseMode == false), which is exactly
  // the branch that must never serve production ad units.
  test('debug builds always resolve Google test unit IDs', () {
    expect(kReleaseMode, isFalse, reason: 'guard: these run in debug');

    expect(AdConfig.bannerUnitId, startsWith('ca-app-pub-3940256099942544/'));
    expect(
      AdConfig.interstitialUnitId,
      startsWith('ca-app-pub-3940256099942544/'),
    );
    expect(AdConfig.usingTestUnitIds, isTrue);
  });

  test('banner and interstitial IDs are distinct units', () {
    expect(AdConfig.bannerUnitId, isNot(AdConfig.interstitialUnitId));
  });
}
