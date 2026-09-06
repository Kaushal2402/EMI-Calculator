import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Phase 8.5 — the app is portrait-locked (SOW §5 layouts are portrait;
/// landscape / tablet layout is out of scope §10). Enforced in three places:
/// `main()` (Flutter `SystemChrome`), the Android manifest, and the iOS
/// Info.plist. Exercising the real `main()` here is impractical (its
/// fire-and-forget `bootstrapAds()` hits unmocked ad/UMP plugin channels), so
/// each enforcement point is asserted at its source.
void main() {
  test('main() pins SystemChrome to portrait before runApp', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, contains('SystemChrome.setPreferredOrientations'));
    expect(source, contains('DeviceOrientation.portraitUp'));
    expect(source, contains('DeviceOrientation.portraitDown'));
    expect(source, isNot(contains('DeviceOrientation.landscape')));
  });

  test('AndroidManifest locks the activity to portrait', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:screenOrientation="portrait"'));
  });

  test('iOS Info.plist offers no landscape orientation', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, isNot(contains('UIInterfaceOrientationLandscapeLeft')));
    expect(plist, isNot(contains('UIInterfaceOrientationLandscapeRight')));
    expect(plist, contains('UIInterfaceOrientationPortrait'));
  });
}
