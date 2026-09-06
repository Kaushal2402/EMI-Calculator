/// Interstitial ad — "boundary" model (SOW §4.8, client-approved 2026-09-06).
///
/// The persisted counter advances on **every settled recalculation**
/// ([interstitialCounterProvider], same signal as
/// `calculationPersistenceProvider`). The full-screen ad is only ever
/// *presented* from [InterstitialAdController.maybeShowAtBoundary], which the
/// CALCULATE EMI button calls just before navigating to Results — so it never
/// interrupts slider editing (AdMob policy) and never shows on first use.
library;

import 'dart:async';

import 'package:emi_calculator/core/ads/ads_providers.dart';
import 'package:emi_calculator/core/config/ad_config.dart';
import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/features/calculator/domain/entities/emi_result.dart';
import 'package:emi_calculator/features/calculator/presentation/providers/emi_result_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Total settled recalculations ever (persisted).
const String _kCalcCountKey = 'ads.calc_count';

/// Value of [_kCalcCountKey] the last time an interstitial was shown.
const String _kLastShownKey = 'ads.calc_count_at_last_interstitial';

/// Show an interstitial once per this many settled calculations (SOW §4.8).
const int kInterstitialEveryNCalculations = 5;

/// Owns the interstitial ad instance, the persisted calculation counter and the
/// "is one due?" decision.
class InterstitialAdController {
  /// Creates the controller. Starts preloading immediately when [enabled].
  InterstitialAdController(this._prefs, {required this.enabled}) {
    if (enabled) _preload();
  }

  final SharedPreferences _prefs;

  /// `false` in widget tests and on unsupported platforms — every method
  /// becomes a no-op and the ad SDK is never touched.
  final bool enabled;

  InterstitialAd? _ad;
  bool _loading = false;

  /// Back-off retry for a failed preload so a flaky first fill (offline at
  /// launch, slow SDK init) doesn't leave the slot empty until calc #10.
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const Duration _retryBackoff = Duration(seconds: 20);

  int get _count => _prefs.getInt(_kCalcCountKey) ?? 0;
  int get _lastShownCount => _prefs.getInt(_kLastShownKey) ?? 0;

  /// Bumps the persisted counter. Called once per settled calculation by
  /// [interstitialCounterProvider]. Runs regardless of [enabled] — counting is
  /// cheap and keeps the cadence correct if ads are toggled on later.
  Future<void> registerCalculation() async {
    await _prefs.setInt(_kCalcCountKey, _count + 1);
  }

  /// `true` when a full group of [kInterstitialEveryNCalculations] calculations
  /// has completed since the last time an interstitial was shown. Robust to
  /// bursty counting (never "misses" an exact multiple), and false until the
  /// user has done at least one full group — so never on first use.
  bool get isDueAtBoundary {
    final count = _count;
    if (count < kInterstitialEveryNCalculations) return false;
    return count ~/ kInterstitialEveryNCalculations >
        _lastShownCount ~/ kInterstitialEveryNCalculations;
  }

  /// Shows the interstitial if one is due *and* already loaded, then completes.
  /// Safe to `await` from a navigation handler: it always returns, whether it
  /// showed an ad, wasn't due, or had nothing loaded in time.
  Future<void> maybeShowAtBoundary() async {
    if (!enabled || !isDueAtBoundary) return;

    final ad = _ad;
    if (ad == null) {
      // Nothing ready this window — make sure one is loading for next time.
      _retryCount = 0;
      _preload();
      return;
    }
    _ad = null;
    _retryCount = 0;

    final dismissed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        if (!dismissed.isCompleted) dismissed.complete();
        _preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        unawaited(ad.dispose());
        if (!dismissed.isCompleted) dismissed.complete();
        _preload();
      },
    );

    // Record the show *before* presenting so a crash mid-ad can't loop it.
    await _prefs.setInt(_kLastShownKey, _count);
    await ad.show();
    await dismissed.future;
  }

  void _preload() {
    if (!enabled || _loading || _ad != null) return;
    _loading = true;
    unawaited(
      InterstitialAd.load(
        adUnitId: AdConfig.interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _ad = ad;
            _loading = false;
            _retryCount = 0;
            _retryTimer?.cancel();
          },
          onAdFailedToLoad: (error) {
            _ad = null;
            _loading = false;
            _scheduleRetry();
          },
        ),
      ).catchError((Object _) {
        // No ad SDK (tests) / transient failure — stay adless, retry next window.
        _loading = false;
        _scheduleRetry();
      }),
    );
  }

  /// Queues another [_preload] after a fixed back-off, up to [_maxRetries]
  /// times. Reset once a load finally succeeds or an ad is shown.
  void _scheduleRetry() {
    if (!enabled || _ad != null || _retryCount >= _maxRetries) return;
    if (_retryTimer?.isActive ?? false) return;
    _retryCount++;
    _retryTimer = Timer(_retryBackoff, _preload);
  }

  /// Disposes any held ad. Call from the provider's `onDispose`.
  void dispose() {
    _retryTimer?.cancel();
    unawaited(_ad?.dispose());
    _ad = null;
  }
}

/// App-wide [InterstitialAdController].
final Provider<InterstitialAdController> interstitialAdControllerProvider =
    Provider<InterstitialAdController>((ref) {
      final controller = InterstitialAdController(
        ref.watch(sharedPreferencesProvider),
        enabled: ref.watch(adsEnabledProvider),
      );
      ref.onDispose(controller.dispose);
      return controller;
    });

/// Side-effect provider: increments the persisted calculation counter once per
/// settled `AsyncData<EmiResult>` (identical re-emissions ignored), mirroring
/// `calculationPersistenceProvider`. A long-lived consumer (the app root) must
/// `watch` it.
final Provider<void> interstitialCounterProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<EmiResult>>(emiResultProvider, (previous, next) {
    if (next is! AsyncData<EmiResult>) return;
    if (previous is AsyncData<EmiResult> && previous.value == next.value) {
      return;
    }
    unawaited(ref.read(interstitialAdControllerProvider).registerCalculation());
  });
});
