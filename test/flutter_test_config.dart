import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global test bootstrap (picked up automatically by `flutter test`).
///
/// * Disables `google_fonts` runtime fetching so tests never hit the network.
/// * Loads the bundled brand faces (Poppins / Inter, declared in
///   `pubspec.yaml`) into the test font manager so widget goldens render the
///   real glyphs instead of `.notdef` block boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await _loadFont('Poppins', const [
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-Medium.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
    'assets/fonts/Poppins-Bold.ttf',
  ]);
  await _loadFont('Inter', const ['assets/fonts/Inter-Variable.ttf']);

  await testMain();
}

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}
