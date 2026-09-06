import 'package:emi_calculator/app.dart';
import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve SharedPreferences once, up front, so the state layer
  // (loanInputProvider / themeModeProvider) can restore synchronously off a
  // single overridden provider (SOW §7.5).
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EmiCalculatorApp(),
    ),
  );
}
