/// AdMob unit-ID resolution (SOW §4.8, §13 D-07 · TASKS 7.2).
///
/// **Hard rule (client, 2026-09-06):**
/// * debug / profile builds → Google's public **test** unit IDs, always.
///   `.env` / `--dart-define` values are ignored here so a stray flag can never
///   serve production ads (and rack up policy strikes) during development.
/// * release builds → the **production** unit IDs injected at build time via
///   `--dart-define-from-file=.env` (see `.env.example`):
///
///   ```sh
///   flutter build appbundle --release --dart-define-from-file=.env
///   flutter build ipa       --release --dart-define-from-file=.env
///   ```
///
///   If a release build forgets the flag it falls back to the test IDs — safe
///   (no revenue, no policy risk); [AdConfig.usingTestUnitIds] flags it.
///
/// The native AdMob *application* ID is gated the same way but elsewhere, since
/// Gradle/Xcode can't read Dart defines: Android `build.gradle.kts` sets the
/// manifest placeholder per build type (debug → test, release → `.env`); iOS
/// `Debug.xcconfig` = test app ID, `Release.xcconfig` = prod app ID.
library;

import 'package:flutter/foundation.dart';

/// Google's public test unit IDs — safe in dev, never billable, never shipped.
///
/// Source: https://developers.google.com/admob/flutter/test-ads
class _TestAdUnits {
  static const String androidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
}

/// Resolved AdMob ad-unit IDs for the current build mode + platform.
class AdConfig {
  const AdConfig._();

  // Production IDs — only consulted in release builds. `defaultValue` keeps a
  // release build that forgot `--dart-define-from-file=.env` on the safe test
  // units rather than crashing or serving an empty ID.
  static const String _prodBannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: _TestAdUnits.androidBanner,
  );
  static const String _prodBannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: _TestAdUnits.iosBanner,
  );
  static const String _prodInterstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: _TestAdUnits.androidInterstitial,
  );
  static const String _prodInterstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: _TestAdUnits.iosInterstitial,
  );

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  /// Banner unit ID for the current build mode + platform (SOW §4.8, Results).
  static String get bannerUnitId {
    if (!kReleaseMode) {
      return _isIos ? _TestAdUnits.iosBanner : _TestAdUnits.androidBanner;
    }
    return _isIos ? _prodBannerIos : _prodBannerAndroid;
  }

  /// Interstitial unit ID for the current build mode + platform
  /// (SOW §4.8, every 5th calc).
  static String get interstitialUnitId {
    if (!kReleaseMode) {
      return _isIos
          ? _TestAdUnits.iosInterstitial
          : _TestAdUnits.androidInterstitial;
    }
    return _isIos ? _prodInterstitialIos : _prodInterstitialAndroid;
  }

  /// `true` when the resolved IDs are Google's test units — i.e. any non-release
  /// build, or a release build that was compiled without the `.env` defines.
  /// Surfaced for a debug badge / log line so a test build is never mistaken
  /// for a production one.
  static bool get usingTestUnitIds =>
      bannerUnitId.startsWith('ca-app-pub-3940256099942544') ||
      interstitialUnitId.startsWith('ca-app-pub-3940256099942544');
}
