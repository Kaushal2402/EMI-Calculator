import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier backing [themeModeProvider] (SOW §7.2 `themeProvider`, §7.5).
///
/// [build] restores the persisted [ThemeMode] from the shared
/// [loanLocalDataSourceProvider] (key `settings.theme_mode`), defaulting to
/// [ThemeMode.system] when the user has never chosen one. Every change is
/// written straight back through the data source — there is no theme repository
/// in the domain layer (Phase 2.1 decision), so the provider talks to the data
/// source directly.
///
/// SOW §7.2 lists a `StateProvider<ThemeMode>`; persistence makes restore
/// asynchronous, so this is an [AsyncNotifierProvider].
class ThemeModeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final stored = await ref.watch(loanLocalDataSourceProvider).readThemeMode();
    return stored ?? ThemeMode.system;
  }

  /// Persists and applies [mode].
  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref.read(loanLocalDataSourceProvider).writeThemeMode(mode);
  }

  /// Cycles system → light → dark → system (SOW §5.4 theme toggle).
  Future<void> toggle() async {
    final next = switch (state.value ?? ThemeMode.system) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }
}

/// App-wide [ThemeMode] (SOW §7.2 `themeProvider`).
final AsyncNotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    AsyncNotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
