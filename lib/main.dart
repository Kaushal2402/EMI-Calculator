import 'dart:async';

import 'package:emi_calculator/app.dart';
import 'package:emi_calculator/core/ads/ads_bootstrap.dart';
import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only (SOW §5 shows portrait layouts only; tablet / landscape
  // layout is out of scope §10). The platform manifests lock this natively too
  // (AndroidManifest `screenOrientation`, iOS `UISupportedInterfaceOrientations`);
  // this call is the Flutter-level belt-and-braces.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Resolve SharedPreferences once, up front, so the state layer
  // (loanInputProvider / themeModeProvider) can restore synchronously off a
  // single overridden provider (SOW §7.5).
  final prefs = await SharedPreferences.getInstance();

  // Kick off AdMob init without awaiting it — the cold-start budget (AC-02)
  // must not pay for the ad SDK. Banner/interstitial widgets pick up ads once
  // this settles; failures are swallowed inside bootstrapAds.
  unawaited(bootstrapAds());

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EmiCalculatorApp(),
    ),
  );
}
