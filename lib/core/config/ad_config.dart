/// AdMob unit-ID resolution (SOW §4.8, §13 D-07 · TASKS 7.2).
///
/// IDs are supplied at **build time** via `--dart-define-from-file=.env`
/// (see `.env.example`). When a key is absent the value falls back to Google's
/// public **test** unit ID, so `flutter run` and `flutter test` work with no
/// `.env` present. Release builds MUST pass the real values:
///
/// ```sh
/// flutter build appbundle --release --dart-define-from-file=.env
/// ```
///
/// The native AdMob *application* ID is injected separately (Android manifest
/// placeholder / iOS xcconfig) because Gradle and Xcode cannot read Dart
/// defines — see `android/app/build.gradle.kts` and `ios/Flutter/*.xcconfig`.
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

/// Resolved AdMob ad-unit IDs for the current platform.
class AdConfig {
  const AdConfig._();

  static const String _bannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: _TestAdUnits.androidBanner,
  );
  static const String _bannerIos = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: _TestAdUnits.iosBanner,
  );
  static const String _interstitialAndroid = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: _TestAdUnits.androidInterstitial,
  );
  static const String _interstitialIos = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS',
    defaultValue: _TestAdUnits.iosInterstitial,
  );

  /// Banner unit ID for the running platform (SOW §4.8 — Results screen).
  static String get bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS ? _bannerIos : _bannerAndroid;

  /// Interstitial unit ID for the running platform (SOW §4.8 — every 5th calc).
  static String get interstitialUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? _interstitialIos
      : _interstitialAndroid;

  /// `true` when the resolved IDs are Google's test units (no `.env` override).
  /// Surfaced for a debug banner / log line so a test build is never mistaken
  /// for a production one.
  static bool get usingTestUnitIds =>
      bannerUnitId.startsWith('ca-app-pub-3940256099942544') ||
      interstitialUnitId.startsWith('ca-app-pub-3940256099942544');
}
