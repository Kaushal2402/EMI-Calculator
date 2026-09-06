/// One-time AdMob bootstrap (SOW §4.8 · TASKS 7.1).
///
/// Called fire-and-forget from `main()` so it never blocks the first frame —
/// the cold-start budget (AC-02, < 2 s to Calculator) must not pay for ad SDK
/// init. Nothing in the UI awaits this; the banner/interstitial widgets simply
/// start returning ads once the SDK is ready.
///
/// Order matters:
///  1. iOS App Tracking Transparency prompt — resolved before anything else so
///     the SDK picks up the tracking authorization status on start-up.
///  2. UMP (Google's Consent Management) — request the consent info and show
///     the GDPR/consent form if the user's region requires one.
///  3. `MobileAds.instance.initialize()`.
library;

import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Guards against a double init if `main()` is ever re-entered (hot restart).
bool _started = false;

/// Requests ATT (iOS), gathers UMP consent, then initialises the Mobile Ads SDK.
///
/// Safe to call more than once — subsequent calls are no-ops. Never throws:
/// any failure is logged and swallowed so a flaky ad SDK / consent service
/// can't break app launch (SOW §4.8 "without degrading the core user
/// experience").
Future<void> bootstrapAds() async {
  if (_started) return;
  _started = true;

  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _requestAttPermission();
    }

    await _gatherUmpConsent();

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

/// Shows the system ATT prompt once (no-op if already answered).
Future<void> _requestAttPermission() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

/// Runs the UMP consent flow: refresh the consent info, then load + show the
/// consent form if it is required and available. Always completes — on any
/// error we log and carry on (the SDK then serves non-personalised ads where
/// consent is missing). A 10 s cap keeps a wedged consent service from
/// stalling ad init indefinitely.
Future<void> _gatherUmpConsent() {
  final done = Completer<void>();
  void finish([Object? _]) {
    if (!done.isCompleted) done.complete();
  }

  try {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        // Consent info refreshed — present the form if one is due.
        unawaited(
          ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (error != null) {
              debugPrint(
                'UMP consent form error ${error.errorCode}: ${error.message}',
              );
            }
            finish();
          }),
        );
      },
      (error) {
        debugPrint(
          'UMP consent info update failed ${error.errorCode}: ${error.message}',
        );
        finish();
      },
    );
  } on Object catch (error) {
    debugPrint('UMP consent flow threw: $error');
    finish();
  }

  return done.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () => debugPrint('UMP consent flow timed out — continuing'),
  );
}

/// Test seam: lets a test reset the once-only guard.
@visibleForTesting
void resetAdsBootstrapForTest() => _started = false;
