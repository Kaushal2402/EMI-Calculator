/// Shared ad-layer providers (SOW §4.8).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Master switch for live AdMob widgets.
///
/// `true` on the shipping platforms (iOS + Android, SOW §3.1). Widget tests
/// override it to `false` so [`AdmobBannerWidget`] and the interstitial code
/// render their reserved-space placeholder and never touch the
/// `plugins.flutter.io/google_mobile_ads` platform channel.
final Provider<bool> adsEnabledProvider = Provider<bool>((ref) {
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
});
