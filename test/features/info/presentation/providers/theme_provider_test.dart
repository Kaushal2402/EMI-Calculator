import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/provider_fakes.dart';

void main() {
  ProviderContainer containerWith(FakeLoanLocalDataSource ds) =>
      ProviderContainer.test(
        overrides: [loanLocalDataSourceProvider.overrideWithValue(ds)],
      );

  test('defaults to ThemeMode.system when nothing is persisted', () async {
    final container = containerWith(FakeLoanLocalDataSource());

    expect(await container.read(themeModeProvider.future), ThemeMode.system);
  });

  test('restores the persisted ThemeMode on init', () async {
    final container = containerWith(
      FakeLoanLocalDataSource(storedThemeMode: ThemeMode.dark),
    );

    expect(await container.read(themeModeProvider.future), ThemeMode.dark);
  });

  test('setThemeMode applies immediately and persists once', () async {
    final ds = FakeLoanLocalDataSource();
    final container = containerWith(ds);
    await container.read(themeModeProvider.future);

    await container
        .read(themeModeProvider.notifier)
        .setThemeMode(ThemeMode.dark);

    expect(container.read(themeModeProvider).value, ThemeMode.dark);
    expect(ds.storedThemeMode, ThemeMode.dark);
    expect(ds.writeThemeCallCount, 1);
  });

  test('a change persisted by one container is restored by the next', () async {
    final ds = FakeLoanLocalDataSource();

    final first = containerWith(ds);
    await first.read(themeModeProvider.future);
    await first.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);

    // New container, same backing store (simulates an app restart).
    final second = containerWith(ds);
    expect(await second.read(themeModeProvider.future), ThemeMode.light);
  });

  test('toggle cycles system -> light -> dark -> system', () async {
    final ds = FakeLoanLocalDataSource();
    final container = containerWith(ds);
    await container.read(themeModeProvider.future);
    final notifier = container.read(themeModeProvider.notifier);

    await notifier.toggle();
    expect(container.read(themeModeProvider).value, ThemeMode.light);
    await notifier.toggle();
    expect(container.read(themeModeProvider).value, ThemeMode.dark);
    await notifier.toggle();
    expect(container.read(themeModeProvider).value, ThemeMode.system);
  });
}
