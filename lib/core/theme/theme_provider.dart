import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier backing [themeModeProvider].
///
/// PHASE 0 SCAFFOLD: in-memory only, seeded to [ThemeMode.system]. Phase 3
/// (task 3.2) regenerates this with Riverpod codegen and persists the choice
/// to `SharedPreferences`.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  /// Cycles system → light → dark → system (SOW §5.4 theme toggle).
  void toggle() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}

/// App-wide [ThemeMode] (SOW §7.2 `themeProvider`).
final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
