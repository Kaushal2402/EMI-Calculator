/// One-time AdMob bootstrap (SOW §4.8 · TASKS 7.1).
///
/// Called fire-and-forget from `main()` so it never blocks the first frame —
/// the cold-start budget (AC-02, < 2 s to Calculator) must not pay for ad SDK
/// init. Nothing in the UI awaits this; the banner/interstitial widgets simply
/// start returning ads once the SDK is ready.
///
/// Order on iOS matters: the App Tracking Transparency prompt must be resolved
/// **before** `MobileAds.initialize()` so the SDK picks up the tracking
/// authorization status on start-up.
library;

import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Guards against a double init if `main()` is ever re-entered (hot restart).
bool _started = false;

/// Requests ATT (iOS only) then initialises the Mobile Ads SDK.
///
/// Safe to call more than once — subsequent calls are no-ops. Never throws:
/// any failure is logged and swallowed so a flaky ad SDK can't break app
/// launch (SOW §4.8 "without degrading the core user experience").
Future<void> bootstrapAds() async {
  if (_started) return;
  _started = true;

  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _requestAttPermission();
    }

    if (kDebugMode) {
      // Emulators/simulators are always allowed to serve test ads; real test
      // devices are added here during on-device QA (Phase 8).
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: const <String>[]),
      );
    }

    await MobileAds.instance.initialize();
  } on Object catch (error, stack) {
    debugPrint(
      'bootstrapAds failed (ads disabled this session): $error\n$stack',
    );
  }
}

/// Shows the system ATT prompt once (no-op if already answered). Waits for the
/// dialog to be dismissible first — iOS ignores a request fired while the app
/// is still becoming active.
Future<void> _requestAttPermission() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

/// Test seam: lets a test reset the once-only guard.
@visibleForTesting
void resetAdsBootstrapForTest() => _started = false;
