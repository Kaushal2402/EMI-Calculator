# Acceptance Criteria — Status (SOW §11)

Phase 8 QA. Branch `feat/phase-8-qa`. Last updated **2026-09-06**.

Legend: **PASS** — met and evidenced in-repo · **PENDING-DEVICE** — logic/proxy
verified, final sign-off needs a physical device or booted simulator (not
available this session) · **WAIVED** — deviation documented, needs client
sign-off.

| # | Criterion | SOW verification method | Status | Evidence / how to finish |
|---|---|---|---|---|
| AC-01 | EMI formula within ±₹1 of standard calculators | Unit test, 20 reference cases | **PASS** | `test/features/calculator/domain/use_cases/calculate_emi_use_case_test.dart` — group *"reference cases (AC-01, ±₹1)"*, `has at least 20 reference cases` + per-case ±₹1 assertion; schedule invariants (Σprincipal ≈ P, final balance ≈ 0) in same file. |
| AC-02 | Launch to Calculator < 2 s on mid-range device | Manual + Perfetto trace | **PENDING-DEVICE** | Cold-start is structurally protected: `bootstrapAds()` is fire-and-forget in `lib/main.dart` (never awaited); splash is a 1.5 s timer. Run: profile build on a mid-range Android (e.g. Pixel 6a / SD 6-gen), `flutter run --profile`, capture Perfetto/DevTools timeline from process start to first Calculator frame; attach trace to `qa/evidence/ac02-coldstart.perfetto`. |
| AC-03 | Results screen renders < 300 ms of Calculate tap | Frame timeline, Riverpod devtools | **PENDING-DEVICE** (proxy PASS) | Proxy: `test/features/calculator/presentation/screens/results_screen_test.dart` — *"paints summary + chart on the first frame from a warm emiResultProvider (AC-03)"* asserts SummaryCard + EMI present after a single `pump()` (zero loading frames). Device: `flutter run --profile`, DevTools → Performance, measure pointer-up → first painted Results frame. |
| AC-04 | Amortization table 60 fps for 360 rows | Performance overlay | **PENDING-DEVICE** (proxy PASS) | Proxy: `results_screen_test.dart` — *"360-row schedule is built lazily (AC-04)"* asserts < 40 `_ScheduleRow` instances built (lazy `SliverList.builder`, fixed-height rows, no shadows). Device: profile build, Performance overlay, fling the 360-row list top↔bottom, confirm raster+UI bars under 16.6 ms with no janky frames; screenshot to `qa/evidence/ac04-scroll.png`. |
| AC-05 | Three loan-type defaults populate on tab switch | Manual + widget test | **PASS** | `test/features/calculator/presentation/widgets/loan_type_selector_test.dart` (Car + Personal→Home restore); `calculator_screen_test.dart` — *"switching loan type resets the form (AC-05)"*; `selected_tab_provider_test.dart`, `loan_input_provider_test.dart`. Defaults match SOW §4.1 (Home 30,00,000/8.5/240 · Car 8,00,000/9.0/60 · Personal 3,00,000/13.0/36). |
| AC-06 | Share sheet opens with correctly formatted text | Manual on device | **PENDING-DEVICE** (proxy PASS) | Proxy: `test/features/calculator/presentation/utils/emi_share_text_test.dart` — byte-for-byte match to SOW §4.7 template (7 tests); `results_screen_test.dart` — *"share button sends the SOW §4.7 summary to the platform share sheet (AC-06)"* mocks the `share_plus` channel and asserts payload. Device: tap Share on Results on iOS + Android, confirm the system sheet appears with the exact text; screenshot to `qa/evidence/ac06-share-{ios,android}.png`. |
| AC-07 | AdMob banner renders without overlapping content | Manual, various screen sizes | **PENDING-DEVICE** (proxy PASS) | Proxy: `test/features/calculator/presentation/widgets/admob_banner_widget_test.dart` — collapses to 0 px when disabled; while enabled it is *always* 0 or ≥ 50 px (never a partial overlapping band); `results_screen_test.dart` renders the screen with `adsEnabledProvider=false`. Device: real fill on ≥ 3 screen sizes (small phone, large phone, min-width), confirm the banner sits above the system nav with `system bottom inset + 8dp` and never covers the amortization table's last row. |
| AC-08 | Flutter Analyze 0 errors / 0 warnings | CI gate | **PASS** | `flutter analyze` → *"No issues found!"* (this session, 2026-09-06). `dart format --output=none --set-exit-if-changed .` clean. `dart run custom_lint` clean. Enforced by `.github/workflows/ci.yml` (Analyze / format / custom_lint / test steps). No hand-authored `// ignore` in `lib/` or `test/` — see "Static-analysis audit" below. |
| AC-09 | Light + dark, no WCAG AA contrast violations | Colour contrast analyser | **PASS (text) / WAIVED (2 non-text)** | `test/core/wcag_contrast_test.dart` computes WCAG 2.1 ratios for every painted fg/bg token pair in both schemes and fails below AA. All **text** pairs pass 4.5:1 (large/bold pass 3:1). Two fixes applied this session (see below). Two `outline`-border pairs fall below the 1.4.11 non-text 3:1 target and are **skipped with a written waiver** pending client sign-off — tracked `qa/bugs.md` **P1-01**. |
| AC-10 | No crash on iOS 14 / Android 7 (SDK 24) | Device farm / emulator | **PENDING-DEVICE** | Android `minSdk = 24` ✓ (`android/app/build.gradle.kts:39`). iOS deployment target is currently **13.0** (`ios/Runner.xcodeproj/project.pbxproj`), i.e. *below* the SOW §3.1 ≥ 14.0 floor — supports the target but widens the untested range; tracked `qa/bugs.md` **P2-03**. Boot an Android 7 (API 24) emulator + an iOS 14 simulator, run `qa/regression.md`, confirm no crash on launch / calculate / results / share / theme toggle. |

## AC-09 — contrast fixes applied this session

| Change | File | Reason |
|---|---|---|
| Dark `onPrimaryContainer` `#D3E4FF` → `#E7F0FF` | `lib/core/constants/app_colors.dart` | Dark segmented-button active label and amortization break-even row text were 4.46:1 on `primaryContainer` — below AA normal-text 4.5:1. Now **5.01:1**. `onPrimaryContainer` is **not** one of the 9 SOW §6.1-pinned tokens. |
| Chart legend label text no longer painted in the segment colour | `lib/features/calculator/presentation/widgets/emi_chart.dart` | `secondary` `#E53935` as `bodyMedium` text on `surface` is **4.05:1** — below AA. The label now uses default `onSurface`; the coloured 12×12 swatch still carries the segment identity (matches the SOW §5.3 mock). |

## AC-09 — measured contrast ratios (2026-09-06)

Text pairs must be ≥ 4.5:1 (normal) / ≥ 3:1 (bold ≥ 14 pt or ≥ 18 pt).

| Pair | Light | Dark |
|---|---|---|
| onSurface / surface | 16.34 | 14.19 |
| onSurfaceVariant / surface | 5.73 | 7.16 |
| onSurface / surfaceContainerHighest | 15.20 | 12.63 |
| onSurfaceVariant / surfaceContainerHighest | 5.33 | 6.38 |
| onPrimary / primary (CTA label) | 5.75 | 5.87 |
| primary / surface (slider/accent) | 5.51 | 10.71 |
| onPrimaryContainer / primaryContainer (segmented active) | 13.27 | **5.01** (was 4.46) |
| onSecondaryContainer / secondaryContainer | 13.26 | 7.24 |
| error / surface | 6.26 | 10.97 |
| onError / error | 6.54 | 7.66 |
| secondary / surface (legend swatch, non-text ≥ 3) | 4.05 | 8.71 |
| onSecondary / secondary (scheme role, unpainted) | 4.23 | 6.14 |
| **outline / surface** (non-text ≥ 3 — **WAIVED P1-01**) | **1.58** | **1.65** |
| **outline / surfaceContainerHighest** (**WAIVED P1-01**) | **1.47** | **1.47** |

## Static-analysis audit (AC-08 / Phase 8.8)

`grep -rn "// *ignore" lib test` → every hit is inside generated `*.freezed.dart`
files (`// ignore_for_file: type=lint` + freezed's per-line
`cast_nullable_to_non_nullable`). These are tool-generated, re-created by
`build_runner`, and out of scope for hand-editing. **Zero hand-authored
`// ignore` / `// ignore_for_file` in first-party `lib/` or `test/` code.**

## Device-pass checklist (everything PENDING-DEVICE, one place)

Run `qa/regression.md` on a physical iOS device + physical Android device, then:

1. **AC-02** cold-start Perfetto trace (mid-range Android) < 2 s.
2. **AC-03** DevTools frame timeline: Calculate tap → Results painted < 300 ms.
3. **AC-04** Performance overlay: 360-row amortization fling stays 60 fps.
4. **AC-06** system share sheet shows the SOW §4.7 text (iOS + Android).
5. **AC-07** banner fill on ≥ 3 screen sizes, no content overlap; interstitial
   only on every 5th calculation, never the 1st.
6. **AC-10** launch + full happy path on Android 7 (API 24) + iOS 14, no crash.
7. iOS: ATT prompt shows once; UMP/GDPR consent form shows in an EEA locale;
   airplane-mode → banner collapses, app still fully usable.

Drop artefacts in `qa/evidence/` and flip the rows above to PASS.
