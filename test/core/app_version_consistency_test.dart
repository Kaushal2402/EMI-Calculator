import 'dart:io';

import 'package:emi_calculator/core/constants/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASKS 9.3 — the in-app version string is a hand-synced mirror of the
/// `<name>` part of `pubspec.yaml`'s `version:` line. This test fails the build
/// if the two drift. See docs/VERSIONING.md.
void main() {
  test('kAppVersion matches the version name in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml must declare `version: <x.y.z>+<build>`',
    );

    final versionName = match!.group(1);
    expect(
      kAppVersion,
      versionName,
      reason:
          'Update kAppVersion in lib/core/constants/app_info.dart to '
          '"$versionName" (see docs/VERSIONING.md).',
    );
  });
}
