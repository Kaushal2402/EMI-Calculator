# EMI Calculator — Build Task List

Derived from `emi-calculator-sow.md` (v1.0). Ordered from empty folder to store-ready
build. Each task has a **Definition of Done (DoD)** so progress is verifiable, not vibes.

Legend: `[ ]` todo · `[~]` in progress · `[x]` done · 🔒 = blocks later tasks

---

## Phase 0 — Project Setup & Scaffold  (SOW §7, §8 · Timeline Day 1 AM)

- [ ] **0.1 🔒 Create Flutter project**
  - `flutter create --org com.softpital --platforms=ios,android emi_calculator`
  - Set app name "EMI Calculator", bundle id `com.softpital.emicalculator`.
  - DoD: `flutter run` shows counter app on iOS sim + Android emulator.

- [ ] **0.2 🔒 Init git repo & branching model**
  - `git init`, add `.gitignore` (Flutter default + `.env`, `*.g.dart` kept, build/).
  - `main` (protected) + `develop`; feature branches `feat/<area>`.
  - Conventional Commits. First commit = clean scaffold.
  - DoD: repo pushed to remote, `main` + `develop` exist.

- [ ] **0.3 Configure `pubspec.yaml` dependencies** (SOW §9)
  - Add all runtime + dev deps at pinned versions from SOW.
  - `flutter pub get` clean, no version conflicts.
  - DoD: `flutter pub deps` resolves; app still builds.
  - **APPROVED 2026-09-06:** SOW §9's 2024-era pins do not resolve on the
    installed toolchain (Flutter 3.44.8 / Dart 3.12.2 / AGP 9 / Gradle 9).
    Client approved the modern coherent set instead:
    flutter_riverpod ^3.1.0, riverpod_annotation ^4.0.0, riverpod_generator
    ^4.0.0, riverpod_lint ^3.1.0, custom_lint ^0.8.1, go_router ^18.0.1,
    google_fonts ^8.2.1, fl_chart ^1.2.0, google_mobile_ads ^9.1.0,
    intl ^0.20.2, share_plus ^12.0.2, shared_preferences ^2.5.5,
    freezed ^3.2.3, freezed_annotation ^3.1.0, json_serializable ^6.11.2,
    very_good_analysis ^10.3.0, flutter_lints ^6.0.0, build_runner ^2.15.1.
    Implications for later phases: use `NotifierProvider` (not
    `StateNotifierProvider`); freezed classes are `abstract class X with _$X`.
  - **APPROVED 2026-09-06:** `dynamic_color ^2.1.0` added beyond SOW §9 to
    implement `DynamicColorBuilder` (SOW §6.1).

- [ ] **0.4 Analysis & lint gate**
  - Adopt `very_good_analysis` in `analysis_options.yaml`; wire `custom_lint` + `riverpod_lint`.
  - DoD: `flutter analyze` = 0 issues on scaffold (AC-08).

- [ ] **0.5 🔒 Clean Architecture folder scaffold** (SOW §8)
  - Create `core/`, `features/calculator/{data,domain,presentation}`, `features/info/`, `shared/`.
  - Add placeholder barrel files; no dead folders.
  - DoD: tree matches SOW §8 exactly; `flutter analyze` clean.

- [ ] **0.6 Design tokens as code** (SOW §6)
  - `app_colors.dart` (light+dark M3 scheme values), `app_typography.dart` (Poppins+Inter via `google_fonts`), `app_spacing.dart` (`kSpacingXS..kSpacing48`), `loan_defaults.dart`.
  - DoD: constants compile; a throwaway widget renders each text style.

- [ ] **0.7 Theme + MaterialApp.router shell** (SOW §6.4, §7.3)
  - `app_theme.dart` light/dark `ThemeData` (M3, tonal elevation), `DynamicColorBuilder` fallback to seed.
  - `app.dart` with `MaterialApp.router`.
  - DoD: app boots to blank themed screen; dark mode follows system.

- [ ] **0.8 🔒 GoRouter routes + empty screens** (SOW §7.3)
  - Routes `/`, `/calculator`, `/results`, `/info` (modal).
  - Empty `SplashScreen`, `CalculatorScreen`, `ResultsScreen`, `InfoBottomSheet`.
  - DoD: manual nav between all routes works; deep link to `/results` handled.

- [ ] **0.9 CI pipeline**
  - GitHub Actions (or equivalent): `flutter analyze` + `flutter test` + build debug APK on every PR.
  - DoD: green check on a trivial PR; failing analyze blocks merge (AC-08).

---

## Phase 1 — Domain Layer + Tests  (SOW §7.4 · Timeline Day 1 PM)

- [x] **1.1 🔒 Entities**
  - `LoanInput` (freezed), `EmiResult` (freezed), `AmortizationRow` (freezed), `LoanType` + `TenureUnit` enums.
  - Run `build_runner`; commit generated files per repo policy.
  - DoD: entities compile; `==`/`copyWith` generated.
  - **DONE 2026-09-06** (branch `feat/domain-layer`, commit `e0c4e60`): freezed 3 syntax
    (`@freezed abstract class X with _$X`); `*.freezed.dart` committed. `analyze` 0/0.

- [x] **1.2 🔒 `CalculateEmiUseCase`**
  - Implement EMI formula (SOW §4.3) incl. `r == 0` guard.
  - Build full month-by-month amortization schedule (principal/interest split, outstanding balance).
  - Compute totals + principal/interest ratios.
  - DoD: pure function, no Flutter imports, no side effects.
  - **DONE 2026-09-06** (commit `caf6853`): reduce-balance formula; final instalment
    absorbs residual float drift so balance closes at exactly 0. Purity enforced by
    `domain_layer_purity_test.dart`. Domain values are **unrounded** (per SOW §7.4 code
    sample); display rounding is presentation's job — noted for Phase 5.

- [x] **1.3 🔒 Reference unit tests (AC-01)**
  - ≥20 reference cases cross-checked against a standard calculator (BankBazaar) within ±₹1.
  - Edge cases: min/max principal, 1-month tenure, 360-month tenure, 1% and 36% rate, 0-interest.
  - Schedule invariants: last balance ≈ 0, Σ principal ≈ P, Σ interest ≈ totalInterest.
  - DoD: `flutter test` green; coverage of use case ≥ 95%.
  - **DONE 2026-09-06** (commit `caf6853`): 24 reference cases at ±₹1 (3 anchored to
    SOW §4.7's ₹26,035 figure). `flutter test` green (74 tests). Use-case line
    coverage **100%**.

- [x] **1.4 Yearly aggregation logic**
  - Derive year-by-year rows from monthly schedule; identify break-even row (cumulative principal > cumulative interest) (SOW §4.4).
  - DoD: unit test asserts break-even index for Home Loan default.
  - **DONE 2026-09-06** (commit `5e7715a`). **DECISION 2026-09-06 (client-approved):**
    break-even = standard amortization **crossover** — first row where the payment's
    principal component > its interest component — NOT literal cumulative sums.
    Rationale: SOW §4.4's "cumulative" wording is loose; under the literal reading the
    Home Loan default never breaks even (total interest > total principal). Crossover is
    well-defined for every positive-rate loan. Home Loan default break-even = monthly
    index 142 (month 143) / yearly index 12 (year 13). Predicate lives in
    `find_break_even_row_use_case.dart` `_isBreakEven`.

- [x] **1.5 Repository interface + local datasource contract**
  - `LoanRepository` interface in domain; `loan_local_datasource.dart` contract (SharedPreferences).
  - DoD: interface has no implementation leak into domain.
  - **DONE 2026-09-06** (commit `40ba048`): `getLastInput`/`saveLastInput` +
    `readLastInput`/`writeLastInput` contracts; serialisation deferred to task 2.1.
    No leak — enforced by `domain_layer_purity_test.dart`.

---

## Phase 2 — Data Layer  (SOW §7.5)

- [ ] **2.1 `LoanLocalDataSource` impl** — persist/restore last `LoanInput` + `ThemeMode` to SharedPreferences.
  - DoD: widget/integration test writes then reads back identical input.

- [ ] **2.2 `LoanRepositoryImpl`** — wires datasource to domain interface; maps DTO ↔ entity.
  - DoD: unit test with fake datasource; no `SharedPreferences` in domain.

- [ ] **2.3 First-launch defaults** — when no persisted state, seed Home Loan defaults (SOW §4.1).
  - DoD: fresh install opens with ₹30,00,000 / 8.50% / 20 yrs.

---

## Phase 3 — State Management (Riverpod)  (SOW §7.2)

- [ ] **3.1 🔒 `loanInputProvider`** (`StateNotifier`) — principal, rate, tenure(months), loanType; async init from repository.
- [ ] **3.2 `selectedTabProvider`, `tenureUnitProvider`, `themeProvider`** (StateProviders) + theme persistence.
- [ ] **3.3 `emiResultProvider`** — runs `CalculateEmiUseCase` on input; debounced 150 ms (SOW §4.2).
- [ ] **3.4 `amortizationProvider`** — derives monthly/yearly schedule + break-even from result.
- [ ] **3.5 Persistence side-effect** — every successful calculation writes inputs to SharedPreferences.
  - DoD (phase): provider unit tests with `ProviderContainer`; tab switch resets to that type's defaults (AC-05).

---

## Phase 4 — Calculator Screen  (SOW §5.2 · Timeline Day 2 AM)

- [ ] **4.1 `AppScaffold` + `SectionLabel` shared widgets** — caps label, `0.08em` tracking, spacing per §6.3.
- [ ] **4.2 `LoanTypeSelector`** — `SegmentedButton`, 3 tabs w/ icons; switch → reset inputs (AC-05).
- [ ] **4.3 `AmountInputField`** — TextField + Slider synced; Indian numeral formatting via `intl` `##,##,##,##0.##`; range ₹10K–₹5Cr.
- [ ] **4.4 `RateInputField`** — TextField + Slider; 1.00–36.00%, step 0.05%; `XX.XX%` format.
- [ ] **4.5 `TenureInputField`** — TextField + Slider + Yr/Mo `ToggleButtons`; 1–30 yr / 12–360 mo; keeps months internally.
- [ ] **4.6 Real-time calc wiring** — every input change (debounced 150 ms) updates `emiResultProvider`.
- [ ] **4.7 CALCULATE EMI button** — `FilledButton` h52/r12; navigates to `/results`.
- [ ] **4.8 Input validation & errors** — clamp out-of-range, block non-numeric, show helper text; no crash on empty field.
- [ ] **4.9 Spacing audit** — match the §5.2 spacing table pixel-for-pixel.
  - DoD (phase): widget tests for sync + defaults; manual check light/dark; `flutter analyze` clean.

---

## Phase 5 — Results Screen  (SOW §5.3 · Timeline Day 2 PM)

- [ ] **5.1 `MetricTile` + `SummaryCard`** — 3 tiles (EMI / Total Interest / Total Payable); outlined, r12, elevation 0; `tabular figures`.
- [ ] **5.2 `EmiChart`** — `fl_chart` PieChart donut, 200dp; Principal (primary) vs Interest (secondary); centre = Total Payable; legend w/ % + absolute; 1200 ms ease-in-out first render, instant on drag (SOW §4.5).
- [ ] **5.3 `AmortizationTable`** — Monthly/Yearly `ToggleButtons`; columns Yr/Mo, EMI, Principal, Interest, Balance; sticky header; alt-row `surfaceVariant`; row h48; `FontFeature.tabularFigures()`.
- [ ] **5.4 Break-even highlight** — highlight first row where cumulative principal > cumulative interest (SOW §4.4).
- [ ] **5.5 Performance pass** — 360-row list scrolls at 60 fps; use `ListView.builder`/lazy `DataTable` alternative (AC-04).
- [ ] **5.6 Results render budget** — visible within 300 ms of Calculate tap; verify via devtools timeline (AC-03).
  - DoD (phase): golden test for SummaryCard; perf overlay screenshot attached to PR.

---

## Phase 6 — Info Sheet, Sharing, Splash  (SOW §5.1, §5.4, §4.7 · Timeline Day 3 AM)

- [ ] **6.1 `InfoBottomSheet`** — modal, drag-to-dismiss, max 60% height; formula text, how-computed, app version from `package_info`.
- [ ] **6.2 Splash screen** — app icon, gradient Primary600→800, `LinearProgressIndicator`, 1.5 s → `/calculator`.
- [ ] **6.3 Share feature** — icon/FAB on Results; build exact plain-text summary from SOW §4.7; open native sheet via `share_plus` (AC-06).
  - DoD: share text matches template byte-for-byte for Home Loan default; manual test on real iOS + Android.

---

## Phase 7 — AdMob Integration  (SOW §4.8 · Timeline Day 3 AM)

- [ ] **7.1 🔒 `google_mobile_ads` setup** — iOS `Info.plist` `GADApplicationIdentifier` + SKAdNetwork ids; Android `AndroidManifest` APPLICATION_ID; ATT prompt on iOS.
- [ ] **7.2 `.env` for ad unit IDs** (D-07) — `flutter_dotenv` or `--dart-define`; test IDs default, prod IDs gated by build flavor; `.env` git-ignored, `.env.example` committed.
- [ ] **7.3 `AdmobBannerWidget`** — 320×50 pinned above system nav on Results; reserves space, never overlaps content (AC-07).
- [ ] **7.4 Interstitial** — counter in persistent storage; show on every 5th calculation, never on first use; preload next.
- [ ] **7.5 Failure handling** — ad load failure = collapse gracefully, no layout shift, no crash offline.
  - DoD (phase): manual on 3 screen sizes; airplane-mode test; consent/ATT flow verified.

---

## Phase 8 — QA, Accessibility, Hardening  (SOW §11 · Timeline Day 3 PM)

- [ ] **8.1 Full acceptance-criteria pass (AC-01…AC-10)** — tick each with its stated verification method; record evidence in `/qa/acceptance.md`.
- [ ] **8.2 Cold-start budget** — Calculator reachable < 2 s on mid-range device; Perfetto/Perfetto trace attached (AC-02).
- [ ] **8.3 Contrast / WCAG AA** — run contrast analyser on light + dark; fix violations (AC-09).
- [ ] **8.4 Min-OS smoke** — no crash on iOS 14 + Android 7 (SDK 24) emulators/devices (AC-10).
- [ ] **8.5 Orientation & text-scale** — usable at 1.3× font scale; portrait-locked if that's the decision (tablet layout is out of scope §10).
- [ ] **8.6 Widget + golden test suite** — key widgets, both themes; CI runs them.
- [ ] **8.7 Manual regression script** — `/qa/regression.md` checklist executed on iOS + Android.
- [ ] **8.8 Static analysis final gate** — `flutter analyze` 0/0, `dart format` clean, no `// ignore` without reason (AC-08).
- [ ] **8.9 Bug triage & fix** — burn down P0/P1; P2+ logged as issues.

---

## Phase 9 — Release Assets & Build  (SOW §13 · Deliverables)

- [ ] **9.1 App icon set (D-04)** — 1024px master → all Android mipmap densities + iOS @1x/@2x/@3x via `flutter_launcher_icons`.
- [ ] **9.2 Splash native config** — `flutter_native_splash` for both platforms matching in-app splash.
- [ ] **9.3 Versioning** — set `version: 1.0.0+1`; document bump policy.
- [ ] **9.4 Android release build (D-02)** — create upload keystore, configure signing (not in VCS), `flutter build apk --release` + `--split-per-abi`, and `appbundle`.
  - DoD: `app-release.apk` installs on clean device; ProGuard/R8 rules for ads OK.
- [ ] **9.5 iOS release build (D-03)** — set team/signing, `flutter build ipa --release`; requires Apple Developer account.
  - DoD: `.ipa` produced; validates in Xcode Organizer / `altool`.
- [ ] **9.6 Play Store screenshots (D-05)** — 6× 1080×1920 PNG from a real run.
- [ ] **9.7 App Store screenshots (D-06)** — 6× 1290×2796 PNG (iPhone 15 Pro Max).
- [ ] **9.8 Store metadata draft** — title, short/long description, keywords, privacy-policy URL, data-safety / App Privacy answers (AdMob = data collected).
- [ ] **9.9 Deliverables bundle** — D-01…D-08 collected; `.env` (test+prod) handed over securely, not in repo.

---

## Phase 10 — Publish  (store submission — asset prep only per §10, full submit if authorised)

- [ ] **10.1 Pre-submission checklist** — bundle id, version, min-OS, permissions strings, ad content rating, export-compliance answer.
- [ ] **10.2 Play Console** — internal-testing track upload → closed test → production rollout (staged %); complete content rating + data safety.
- [ ] **10.3 App Store Connect** — TestFlight build → app review submission; App Privacy + age rating; screenshots + metadata.
- [ ] **10.4 AdMob prod linkage** — apps linked in AdMob console; prod ad unit IDs live; `app-ads.txt` published on the developer domain.
- [ ] **10.5 Post-release monitoring** — watch crash-free rate + ad fill for 48 h; hotfix branch ready.
- [ ] **10.6 Handover** — tag `v1.0.0`, release notes, README (setup, build, env, release steps), architecture doc.

> Note: SOW §10 item 10 marks store *submission* as out of scope (asset prep only).
> Do Phase 10.1 + assets regardless; run 10.2–10.4 only on written client authorisation.

---

## Cross-cutting standards (apply to every task)

- Clean Architecture boundaries respected — domain has zero Flutter/plugin imports.
- Every use case and provider covered by tests before the PR is opened.
- No task is "done" until `flutter analyze` is 0/0 and CI is green.
- Each PR: small, single-purpose, screenshots for UI, linked to the task id above.
- Accessibility and light/dark parity checked per screen, not deferred to Phase 8.
- Secrets (`.env`, keystore, provisioning) never committed.
