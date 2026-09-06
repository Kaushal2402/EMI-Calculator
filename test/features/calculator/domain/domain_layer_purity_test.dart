@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture guard: the domain layer must not import Flutter, `dart:ui`, or
/// any plugin (Clean Architecture — SOW §7.1). Only `dart:` core libraries,
/// `package:meta`, `package:collection`, `package:freezed_annotation` and
/// other `package:emi_calculator/...domain/...` files are allowed.
void main() {
  final domainDir = Directory('lib/features/calculator/domain');

  final forbidden = <RegExp>[
    RegExp("import 'package:flutter/"),
    RegExp("import 'dart:ui'"),
    RegExp("import 'package:flutter_riverpod/"),
    RegExp("import 'package:riverpod"),
    RegExp("import 'package:shared_preferences/"),
    RegExp("import 'package:google_mobile_ads/"),
    RegExp("import 'package:go_router/"),
    RegExp("import 'package:fl_chart/"),
    RegExp("import 'package:google_fonts/"),
    RegExp("import 'package:share_plus/"),
    RegExp("import 'package:intl/"),
    // data / presentation layers must never be pulled into domain
    RegExp('domain/.*/data/'),
    RegExp('emi_calculator/features/[a-z_]+/data/'),
    RegExp('emi_calculator/features/[a-z_]+/presentation/'),
  ];

  test('every domain .dart file is free of Flutter/plugin imports', () {
    final dartFiles = domainDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    expect(dartFiles, isNotEmpty, reason: 'no domain files found');

    final violations = <String>[];
    for (final file in dartFiles) {
      final content = file.readAsStringSync();
      for (final pattern in forbidden) {
        if (pattern.hasMatch(content)) {
          violations.add('${file.path}: matches ${pattern.pattern}');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
