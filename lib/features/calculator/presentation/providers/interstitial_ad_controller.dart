/// Interstitial ad controller (SOW §4.8).
///
/// Two triggers, both only ever presenting between screens (never during slider
/// editing, per AdMob policy):
///  * [InterstitialAdController.showOnCtaTap] — the CALCULATE EMI button. Client
///    asked (2026-09-06) for an ad on *every* tap; a
///    [kMinGapBetweenInterstitials] guard coalesces rapid re-taps so the
///    account isn't flagged for stacking full-screen ads.
///  * [InterstitialAdController.maybeShowAtBoundary] — the Results → back
///    button, gated to every [kInterstitialEveryNCalculations]th settled
///    recalculation ([interstitialCounterProvider]).
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

/// Epoch-ms of the last interstitial actually presented (any trigger).
const String _kLastShownAtMsKey = 'ads.interstitial_last_shown_ms';

/// Show an interstitial once per this many settled calculations (SOW §4.8) —
/// used by the Results-back boundary.
const int kInterstitialEveryNCalculations = 5;

/// Minimum gap between two interstitials, whatever the trigger. The CALCULATE
/// EMI CTA is wired to show on *every* tap (client request, 2026-09-06); this
/// guard stops rapid re-taps from stacking full-screen ads back-to-back, which
/// AdMob treats as a policy violation. It is invisible in the real flow (a user
/// cannot calculate → read Results → return → recalculate this fast).
const Duration kMinGapBetweenInterstitials = Duration(seconds: 15);

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
    if (_ad == null) {
      _retryCount = 0;
      _preload();
      return;
    }
    await _present(recordBoundary: true);
  }

  /// Client request (2026-09-06): present an interstitial on **every** CALCULATE
  /// EMI tap. Still only fires when [enabled], an ad is already loaded, and at
  /// least [kMinGapBetweenInterstitials] has passed since the previous one
  /// (rapid re-taps are coalesced — see the constant's note on AdMob policy).
  /// Always resolves; navigation should follow regardless.
  Future<void> showOnCtaTap() async {
    if (!enabled) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final lastMs = _prefs.getInt(_kLastShownAtMsKey) ?? 0;
    if (nowMs - lastMs < kMinGapBetweenInterstitials.inMilliseconds) {
      _preload();
      return;
    }
    if (_ad == null) {
      _retryCount = 0;
      _preload();
      return;
    }
    await _present(recordBoundary: false);
  }

  /// Presents the held ad and waits for dismissal. Records the show markers
  /// *before* `show()` so a crash mid-ad can't loop it.
  Future<void> _present({required bool recordBoundary}) async {
    final ad = _ad;
    if (ad == null) return;
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

    if (recordBoundary) await _prefs.setInt(_kLastShownKey, _count);
    await _prefs.setInt(
      _kLastShownAtMsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
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
