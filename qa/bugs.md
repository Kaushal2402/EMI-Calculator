# Bug Triage — EMI Calculator

Phase 8.9. Priority: **P0** ship-blocker (crash / data-wrong / unusable) ·
**P1** must-fix before release (visible defect, spec/AC deviation) · **P2**
should-fix (polish, edge case, tech-debt) that can ship as a known issue.

Status: OPEN / IN-PROGRESS / FIXED / WAIVED (client-accepted) / WONTFIX.

Seeded from Phase 8.3 / 8.5 / 8.6 findings on `feat/phase-8-qa` (2026-09-06).
No P0s found this session.

| ID | Pri | Area | Summary | Status | Detail / action |
|---|---|---|---|---|---|
| P1-01 | P1 | Design tokens / a11y (AC-09) | `outline` border contrast is 1.47–1.65:1 against `surface` / `surfaceContainerHighest` in **both** themes — below the WCAG 1.4.11 non-text 3:1 target for an active-control boundary. Affects TextField borders and the *outlined* SummaryCard (elevation 0, so the border is its only edge). | RESOLVED via option (a)+(c) (2026-09-06, branch `feat/premium-ui-ads-icon`) | The premium-UI refresh **stops painting the low-contrast `outline`** where it was the problem: `inputDecorationTheme` resting/enabled border is now `BorderSide.none` (filled fill + floating label carry the affordance; focus shows a 2 dp `primary` ring), and `SummaryCard` no longer relies on an edge — the headline sits on a `primaryContainer` panel and the sub-metrics on `surfaceContainerHighest` chips, with the outer `cardTheme` border softened to `outlineVariant`. `outline` itself is untouched (still SOW §6.1 verbatim). `test/core/wcag_contrast_test.dart` keeps the two `outline` pairs `skip`-ped as a guard against re-introducing a resting border. |
| P1-02 | P1 | Layout / a11y (8.5) | ~~No portrait lock~~ — app rotated freely; SOW §5 is portrait-only and tablet/landscape layout is out of scope §10, so landscape produced an unspecced, cramped layout. | FIXED (this session) | Locked in three places: `lib/main.dart` `SystemChrome.setPreferredOrientations([portraitUp, portraitDown])`; `AndroidManifest.xml` activity `android:screenOrientation="portrait"`; iOS `Info.plist` `UISupportedInterfaceOrientations` (+`~ipad`) reduced to Portrait only. Guard test: `test/platform/portrait_lock_test.dart`. Re-verify visually on device (regression §9). |
| P2-01 | P2 | Test infra (8.6) | Golden PNGs are generated on macOS; CI runs `flutter test` on `ubuntu-latest`. Flutter goldens can differ by host platform (anti-aliasing). Text renders as block glyphs (google_fonts runtime fetch disabled) so shaping isn't a factor, but arc/AA rendering in `emi_chart` goldens is the most exposed. | OPEN | Matches the pre-existing `summary_card` golden pattern (already committed, CI green), so no regression. Mitigation options if CI flakes: a dedicated Linux "golden" job that regenerates + diffs, or a small tolerance via `flutter_test`'s `goldenFileComparator`, or the `alchemist` package (needs SOW §9 dependency approval). Do **not** add a dep without sign-off. |
| P2-02 | P2 | Widget (8.6) | No golden for `AdmobBannerWidget`. | WAIVED | Nothing deterministic to snapshot: ads-disabled → `SizedBox.shrink` (0 px); ads-enabled → a live platform view that can't render in `flutter test`. Behaviour (collapse vs reserve ≥ 50 px, never a partial band) is covered by `admob_banner_widget_test.dart`. Visual check is regression §7. |
| P2-03 | P2 | Build config (AC-10) | iOS deployment target is `13.0` (`ios/Runner.xcodeproj/project.pbxproj`, Podfile line commented). SOW §3.1 / AC-10 state the floor is iOS **14.0**. | OPEN | Functionally supports the target and then some, but it widens the shipped range beyond the QA matrix. Decide with client: bump `IPHONEOS_DEPLOYMENT_TARGET`/Podfile to `14.0` to match the SOW, or record iOS 13 as an intentionally supported bonus and add it to the device matrix. Fold into Phase 9.5 (iOS release build). |
| P2-04 | P2 | Test hygiene | `flutter test` prints many `google_fonts was unable to load font …` errors. They are non-fatal (runtime fetching is disabled on purpose in `test/flutter_test_config.dart`) and tests pass, but the noise hides real warnings. | OPEN | Optional: silence by bundling the Poppins/Inter `.ttf`s as test assets, or filter in `flutter_test_config.dart`. Low value; leave unless it bites. |

## Notes

- **AC-01..AC-08** show no defects this session. AC-02/03/04/06/07/10 remain
  PENDING-DEVICE (see `qa/acceptance.md`) — not bugs, just unverified until the
  device pass.
- `flutter analyze` 0/0, `dart format` clean, `dart run custom_lint` clean,
  `flutter test` 245 passing / 4 skipped (the 4 = P1-01 outline waivers).
