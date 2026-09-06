import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Global test bootstrap (picked up automatically by `flutter test`).
///
/// Disables `google_fonts` runtime font fetching so tests never hit the
/// network — every run resolves the same bundled fallback metrics, which keeps
/// golden files deterministic across machines and CI.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
