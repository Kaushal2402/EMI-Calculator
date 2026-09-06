import 'dart:async';

import 'package:emi_calculator/core/ads/ads_providers.dart';
import 'package:emi_calculator/core/config/ad_config.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 320×50 AdMob banner pinned above the system nav on the Results screen
/// (SOW §4.8, §5.3 · TASKS 7.3).
///
/// Layout contract (AC-07 — "renders without overlapping content"):
/// * While loading or once loaded it occupies a fixed
///   [`AppSizes.adBannerHeight`] band plus `system bottom inset + 8dp` padding,
///   so content above it never shifts when the creative appears.
/// * On a hard load failure (e.g. offline) it collapses to zero height — no
///   permanent empty strip (TASKS 7.5, "collapse gracefully").
///
/// In widget tests [adsEnabledProvider] is overridden to `false`, so this
/// renders [SizedBox.shrink] and never touches the ad platform channel.
class AdmobBannerWidget extends ConsumerStatefulWidget {
  /// Creates an [AdmobBannerWidget].
  const AdmobBannerWidget({super.key});

  @override
  ConsumerState<AdmobBannerWidget> createState() => _AdmobBannerWidgetState();
}

class _AdmobBannerWidgetState extends ConsumerState<AdmobBannerWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(adsEnabledProvider)) {
      _loadAd();
    }
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            unawaited(ad.dispose());
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _loaded = true;
            _failed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          unawaited(ad.dispose());
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _loaded = false;
            _failed = true;
          });
        },
      ),
    );
    unawaited(ad.load());
  }

  @override
  void dispose() {
    unawaited(_bannerAd?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(adsEnabledProvider) || _failed) {
      return const SizedBox.shrink();
    }

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(bottom: bottomInset + kSpacingSM),
      alignment: Alignment.center,
      height: AppSizes.adBannerHeight + bottomInset + kSpacingSM,
      child: _loaded && _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
