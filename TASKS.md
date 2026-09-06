# EMI Calculator — Build Task List

Derived from `emi-calculator-sow.md` (v1.0). Ordered from empty folder to store-ready
build. Each task has a **Definition of Done (DoD)** so progress is verifiable, not vibes.

Legend: `[ ]` todo · `[~]` in progress · `[x]` done · 🔒 = blocks later tasks

---

## Phase 0 — Project Setup & Scaffold  (SOW §7, §8 · Timeline Day 1 AM)

- [ ] **0.1 🔒 Create Flutter project**
  - `flutter create --org com.softpital --platforms=ios,android emi_calculator`
  - Set app name "EMI Calculator", bundle id `com.softpitalservices.emicalculator`.
  - DoD: `flutter run` shows counter app on iOS sim + Android emulator.
  - **CLIENT CONFIRMED 2026-09-06:** application/bundle id org segment renamed
    `softpital` → `softpitalservices`, so the id is now
    `com.softpitalservices.emicalculator`. Swept across Android
    (`applicationId`, `namespace`, Kotlin package + dir), iOS
    (`PRODUCT_BUNDLE_IDENTIFIER` for Runner Debug/Release/Profile;
    `RunnerTests` rebased to `com.softpitalservices.emicalculator.RunnerTests`).
    Branch `feat/rename-bundle-id`. No signing/keystore/store changes.

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

- [x] **2.1 `LoanLocalDataSource` impl** — persist/restore last `LoanInput` + `ThemeMode` to SharedPreferences.
  - DoD: widget/integration test writes then reads back identical input.
  - **DONE 2026-09-06** (branch `feat/data-layer`, commit `f1de00d`): `LoanInputDto`
    (data-layer, hand-written JSON mapping, `schemaVersion` field for future
    migrations) + `LoanLocalDataSourceImpl` over `SharedPreferences`. Last input =
    one JSON string at key `calculator.last_input`; enums by `.name`,
    order-independent; corrupt/incompatible blob degrades to `null` (no throw).
    **DECISION:** theme persistence added to the same datasource contract
    (`readThemeMode`/`writeThemeMode`, key `settings.theme_mode` = `ThemeMode.name`)
    — no theme repo in domain, Phase 3.2 wires the provider. Data layer imports
    `flutter` `ThemeMode` (allowed — only domain is purity-gated).
    **DEVIATION:** added `data/models/` dir (not in SOW §8's illustrative tree) for
    `loan_input_dto.dart` — standard Clean Architecture data-layer location.
    25 new tests (round-trip identity for every `LoanInput` + `ThemeMode`, simulated
    restart, corrupt-blob handling). `analyze` 0/0.

- [x] **2.2 `LoanRepositoryImpl`** — wires datasource to domain interface; maps DTO ↔ entity.
  - DoD: unit test with fake datasource; no `SharedPreferences` in domain.
  - **DONE 2026-09-06** (commit `07fd372`): thin adapter delegating
    `getLastInput`/`saveLastInput` to `LoanLocalDataSource`. DTO ↔ entity mapping
    stays in the datasource (per the 1.5 contract), so the repo owns only wiring +
    (in 2.3) the first-launch fallback. No `shared_preferences` import in `domain/`
    — enforced by `domain_layer_purity_test.dart`. Unit-tested against an in-memory
    `FakeLoanLocalDataSource`.

- [x] **2.3 First-launch defaults** — when no persisted state, seed Home Loan defaults (SOW §4.1).
  - DoD: fresh install opens with ₹30,00,000 / 8.50% / 20 yrs.
  - **DONE 2026-09-06** (commit `36ddd91`). **DECISION:** `LoanRepository.getLastInput()`
    changed from `Future<LoanInput?>` to non-nullable `Future<LoanInput>` — the
    repo returns the Home Loan preset on a cold start (or unreadable blob) so the
    Phase 3 provider never special-cases `null`. Defaults live in
    `core/constants/loan_defaults.dart` as `loanInputFromDefaults(LoanType)` /
    `firstLaunchLoanInput()` — one source of truth, reused by the AC-05 tab-switch
    reset. Test proves a fresh install yields ₹30,00,000 / 8.50% / 240 months.

---

## Phase 3 — State Management (Riverpod)  (SOW §7.2)

- [x] **3.1 🔒 `loanInputProvider`** (`StateNotifier`) — principal, rate, tenure(months), loanType; async init from repository.
  - **DONE 2026-09-06** (branch `feat/state-management`, commit `39ff3fa`):
    `AsyncNotifierProvider<LoanInputNotifier, LoanInput>` in
    `features/calculator/presentation/providers/loan_input_provider.dart`.
    `build()` awaits `loanRepositoryProvider.getLastInput()` — no null / cold-start
    branch (repo yields the Home Loan preset, Phase 2.3). Mutators `setLoanType`
    (AC-05 full reset via `loanInputFromDefaults`), `setPrincipal`, `setAnnualRate`,
    `setTenureMonths`, `setInput`.
  - **DECISION — `AsyncNotifier`, not `StateNotifier`:** SOW §7.2 predates Riverpod
    3; the approved set forbids `StateNotifier`. Repo restore is async, so
    `AsyncNotifier` (consumers get `AsyncValue<LoanInput>`, `loading` for the first
    frame only). Riverpod 3 has no `valueOrNull` — used `AsyncValue.value`.
  - **DEVIATION — hand-written, not `@riverpod` codegen:** codegen derives the
    provider symbol from the Notifier class name; the only class name yielding the
    SOW symbol `loanInputProvider` is `LoanInput`, which collides with the domain
    entity this file imports. Renaming would ripple through the brief + Phases 4/5.
    The rest of the provider layer is already hand-written `Notifier`s (the exact
    shape codegen expands to), so this is consistent. No `*.g.dart` for providers;
    freezed entity codegen is unaffected. `custom_lint`/`riverpod_lint` pass.
  - **DEVIATION — `core/providers/`:** added `persistence_providers.dart`
    (`sharedPreferencesProvider` — overridden in `main()`/tests;
    `loanLocalDataSourceProvider`) as a shared composition root, reused by
    `themeModeProvider`. `loanRepositoryProvider` lives in the calculator
    providers dir. `main()` now resolves `SharedPreferences` up front and overrides.
  - 6 tests (`ProviderContainer.test` + `FakeLoanRepository`, no SharedPreferences).
- [x] **3.2 `selectedTabProvider`, `tenureUnitProvider`, `themeProvider`** (StateProviders) + theme persistence.
  - **DONE 2026-09-06** (commit `89f99da`):
    * `selectedTabProvider` → `NotifierProvider<LoanType>`
      (`selected_tab_provider.dart`). State is **derived** from
      `loanInputProvider.loanType` (one source of truth — tab & form can't
      disagree); `select(type)` delegates to `LoanInputNotifier.setLoanType`, which
      performs the AC-05 reset. `build()` returns `kDefaultLoanType` until the
      async input resolves.
    * `tenureUnitProvider` → `NotifierProvider<TenureUnit>`
      (`tenure_unit_provider.dart`). Presentation-only Yr/Mo toggle
      (`select` / `toggle`); input stays in months.
    * `themeProvider` → `AsyncNotifierProvider<ThemeMode>` — kept the source of
      truth in `core/theme/theme_provider.dart` (`themeModeProvider`), re-exported
      by `features/info/presentation/providers/theme_provider.dart`. `build()`
      restores via `loanLocalDataSourceProvider.readThemeMode()` (key
      `settings.theme_mode`), default `ThemeMode.system`; `setThemeMode`/`toggle`
      write straight back (no domain theme repo — Phase 2.1). `app.dart` reads
      `.value ?? ThemeMode.system`.
  - **DECISION:** all three are `NotifierProvider`/`AsyncNotifierProvider`, not
    `StateProvider` (SOW §7.2 wording predates the approved Riverpod 3 set).
  - 12 tests (selectedTab 4, tenureUnit 3, theme 5).
- [x] **3.3 `emiResultProvider`** — runs `CalculateEmiUseCase` on input; debounced 150 ms (SOW §4.2).
  - **DONE 2026-09-06** (commit `ff14ac9`): `FutureProvider<EmiResult>` awaiting
    `loanInputProvider.future`, then waiting `calcDebounceProvider`
    (default `kCalcDebounce` = 150 ms) before running the use case. On each input
    change Riverpod disposes the prior run; an `onDispose` flag makes the
    superseded run return a never-completing future so its result is discarded —
    rapid edits collapse to one calculation. `calcDebounceProvider` is overridable
    (`Duration.zero` in most tests; small non-zero to assert coalescing).
    Pure derivation — no persistence. 4 tests incl. a call-counting spy use case.
- [x] **3.4 `amortizationProvider`** — derives monthly/yearly schedule + break-even from result.
  - **DONE 2026-09-06** (commit `4b511b8`): `FutureProvider<AmortizationView>`
    derived from `emiResultProvider` (pure, inherits its debounce).
    `AmortizationView` = monthly schedule + yearly aggregation
    (`AggregateYearlyScheduleUseCase`) + monthly & yearly break-even indices
    (`FindBreakEvenRowUseCase` crossover, per 1.4). Home default break-even
    142 / 12. 5 tests (incl. partial trailing year, zero-interest → index 0).
- [x] **3.5 Persistence side-effect** — every successful calculation writes inputs to SharedPreferences.
  - **DONE 2026-09-06** (commit `b151da8`): `calculationPersistenceProvider`
    (`Provider<void>`) `ref.listen`s `emiResultProvider` and, on each new
    `AsyncData<EmiResult>` (identical re-emissions ignored), fires
    `loanRepository.saveLastInput(currentInput)` from the listener callback —
    **not** in a getter; `emiResultProvider` stays pure. `app.dart` `watch`es it
    for the app lifetime. One settled calc ⇒ exactly one save (rapid edits already
    coalesced upstream). 4 tests.
  - DoD (phase): provider unit tests with `ProviderContainer`; tab switch resets to that type's defaults (AC-05).
  - **PHASE 3 DONE 2026-09-06** — 31 new provider tests, `flutter test` 130 green,
    `flutter analyze` 0/0, `dart format` clean, `dart run custom_lint` clean.
    Branch `feat/state-management` (not merged, not pushed).

---

## Phase 4 — Calculator Screen  (SOW §5.2 · Timeline Day 2 AM)

- [x] **4.1 `AppScaffold` + `SectionLabel` shared widgets** — caps label, `0.08em` tracking, spacing per §6.3.
  - **DONE 2026-09-06** (branch `feat/calculator-screen`): both already existed from
    Phase 0 and were spec-correct — `SectionLabel` uses `labelMedium` (12sp) upper-cased,
    `onSurfaceVariant`, `fontSize * kCapsLetterSpacing` (0.08em) tracking; `AppScaffold`
    applies `EdgeInsets.symmetric(horizontal: 16)` and a 64dp AppBar via `appBarTheme`.
    No code change. New shared piece added: `InputSlider`
    (`features/calculator/presentation/widgets/input_slider.dart`) — the Slider + min/max
    caption row (`labelSmall`/`onSurfaceVariant`, 4dp below the track), so the
    slider/range-label spacing lives in one place.
- [x] **4.2 `LoanTypeSelector`** — `SegmentedButton`, 3 tabs w/ icons; switch → reset inputs (AC-05).
  - **DONE 2026-09-06**: `ConsumerWidget`, `SizedBox(height: 40)` + `SegmentedButton`
    (`StadiumBorder`, `shrinkWrap` tap target). Icons `home_outlined` /
    `directions_car_outlined` / `person_outline` (SOW §6.5). `onSelectionChanged` →
    `selectedTabProvider.notifier.select()`, which delegates to
    `LoanInputNotifier.setLoanType` for the full AC-05 reset. Tests:
    `loan_type_selector_test.dart` (3 segments render; tap Car resets to car presets;
    Personal→Home restores Home presets).
- [x] **4.3 `AmountInputField`** — TextField + Slider synced; Indian numeral formatting via `intl` `##,##,##,##0.##`; range ₹10K–₹5Cr.
  - **DONE 2026-09-06**: dumb `StatefulWidget` (`value` + `onChanged`), owns only its
    `TextEditingController`. Live grouping via new `IndianDigitsInputFormatter`
    (`core/utils/indian_number_input_formatter.dart`, reuses `NumberFormatter.grouped`);
    caret end-anchored. `prefixText: '₹ '`, helper text = the range. Controller re-syncs
    from `value` only while unfocused (no cursor jump). Slider via `InputSlider`,
    `minLabel '₹10K'` / `maxLabel '₹5Cr'`.
  - **DECISION — principal slider snaps to ₹1,000.** SOW §4.2 specifies a step only for
    the rate; a continuous 10k–5Cr track is unusable. Drags snap to ₹1,000; the text
    field still accepts any exact rupee value in range. **CONFIRMED 2026-09-06 (client):**
    keep the ₹1,000 slider snap.
- [x] **4.4 `RateInputField`** — TextField + Slider; 1.00–36.00%, step 0.05%; `XX.XX%` format.
  - **DONE 2026-09-06**: same dumb-widget pattern. `suffixText: ' %'`, text shown as
    `toStringAsFixed(2)`, `FilteringTextInputFormatter.allow('[0-9.]')`. Slider
    `divisions: ((36-1)/0.05).round()` = 700; drags rounded to the 0.05 step and
    re-parsed via `toStringAsFixed(2)` to kill float drift.
- [x] **4.5 `TenureInputField`** — TextField + Slider + Yr/Mo `ToggleButtons`; 1–30 yr / 12–360 mo; keeps months internally.
  - **DONE 2026-09-06**: parent holds canonical `months`; `unit` only changes display /
    entry. Years mode → slider 1–30, `display = months ~/ 12`, `months = years*12`;
    Months mode → slider 12–360, verbatim. `_UnitToggle` = `ToggleButtons` clamped to
    36dp, radius 8, centred in a 56dp box to line up with the field. Switching the unit
    is not an edit (no `onMonthsChanged`).
- [x] **4.6 Real-time calc wiring** — every input change (debounced 150 ms) updates `emiResultProvider`.
  - **DONE 2026-09-06**: no widget-level debounce (already in `emiResultProvider`, task
    3.3). Field `onChanged`s call the `loanInputProvider` mutators; `_CalculatorForm`
    `watch`es `emiResultProvider` to keep the engine warm so `/results` paints
    immediately (AC-03) and to disable the CTA if the engine ever errors.
- [x] **4.7 CALCULATE EMI button** — `FilledButton` h52/r12; navigates to `/results`.
  - **DONE 2026-09-06**: `FilledButton` (h52/r12 from `filledButtonTheme`), 32dp top /
    24dp + system-inset bottom, `context.push('/results')`. `calculator_screen_test.dart`
    asserts navigation.
- [x] **4.8 Input validation & errors** — clamp out-of-range, block non-numeric, show helper text; no crash on empty field.
  - **DONE 2026-09-06**: input formatters block non-numeric at the source. While typing:
    out-of-range or empty → `errorText` shown, value **not** propagated (last valid value
    stays in `loanInputProvider`, so the engine never sees NaN). On blur / submit: parse,
    clamp into range, normalise the text, propagate. Every field carries permanent
    helper text with its allowed range.
- [x] **4.9 Spacing audit** — match the §5.2 spacing table pixel-for-pixel.
  - **DONE 2026-09-06**: all gaps use `app_spacing.dart` tokens — 24 (AppBar→selector),
    8 (label→field), 8 (field→slider), 4 (slider→range labels), 20 (between groups),
    32 (CTA top), 24 + `MediaQuery.viewPadding.bottom` (CTA bottom); horizontal 16 from
    `AppScaffold`.
  - **DEVIATION — selector → first section label = 20dp, not the diagram's 24dp.** The
    §5.2 ASCII diagram annotates the first label `mt = 24dp`; the §5.2 **spacing table**
    says "Section label top margin 20dp (first: 0dp)" + "Between field groups 20dp". The
    table wins per the phase brief. "first: 0dp" is read as "no extra margin beyond the
    inter-group gap"; the selector is treated as a group peer, so the standard 20dp
    applies between it and the Principal group. A literal 0dp there is visually cramped.
    **CONFIRMED 2026-09-06 (client):** table wins — keep 20dp.
- **CONFIRMED 2026-09-06 (client):** providers stay hand-written `Notifier`s (not
  `@riverpod` codegen) — the accepted deviation from Phase 3 is now a settled decision.
- **PHASE 4 DONE 2026-09-06** — branch `feat/calculator-screen` (not merged, not pushed).
  `flutter analyze` 0/0 · `dart format` clean · `dart run custom_lint` clean ·
  `flutter test` 160 green (+30 over Phase 3). Light/dark + 1.3× text-scale regression-
  tested in `calculator_screen_test.dart`.
  `flutter analyze` 0/0, `dart format` clean, `dart run custom_lint` clean,
  `flutter test` **160 green** (+28 vs Phase 3's 130; +2 pre-existing `widget_test.dart`
  updated to override `sharedPreferencesProvider` now that splash lands on a live
  calculator). New tests: `indian_number_input_formatter_test` (5),
  `amount_input_field_test` (6), `rate_input_field_test` (6), `tenure_input_field_test`
  (7), `loan_type_selector_test` (3), `calculator_screen_test` (9 incl. dark-mode +
  1.3× text-scale no-overflow regression). Light/dark parity and 1.3× text scale
  verified by widget test (`tester.takeException()` null after scrolling the full form).
  DoD (phase): widget tests for sync + defaults ✓ (AC-05); `flutter analyze` clean ✓.

  **RECOMMENDATION — codegen vs hand-written Notifiers (from the Phase 4 brief's open
  decision): keep the deviation.** The `LoanInput` symbol collision is real, the
  entire provider layer is already consistent hand-written `Notifier`s (the exact shape
  codegen expands to), `riverpod_lint`/`custom_lint` pass, and renaming `loanInputProvider`
  would churn the SOW, the brief and Phases 3–5 for zero runtime benefit. Not worth it.

---

## Phase 5 — Results Screen  (SOW §5.3 · Timeline Day 2 PM)

- [x] **5.1 `MetricTile` + `SummaryCard`** — 3 tiles (EMI / Total Interest / Total Payable); outlined, r12, elevation 0; `tabular figures`.
  - **DONE 2026-09-06** (branch `feat/results-screen`): `MetricTile` = value
    (`titleLarge` token bumped to `w700`, `FontFeature.tabularFigures()`,
    shrink-to-fit so long amounts / large text scales never overflow) over a
    4dp gap over an ALL-CAPS `labelSmall` label (`onSurfaceVariant`, `0.08em`
    tracking). `SummaryCard` = `Card` (elevation 0 / r12 / outline all inherited
    from `cardTheme`), inner padding `py=20 / px=16`, three `Expanded` tiles
    with 8dp `SizedBox` gaps. Outer `mx=16` is the screen padding, so the card
    `margin` is `EdgeInsets.zero`. Widgets take **unrounded** `EmiResult`
    figures and apply SOW §4.3 display rounding themselves via
    `double_ext.toIndianCurrency()` (nearest ₹1, Indian numerals).
  - **DECISION — all three tiles use full Indian format, not the §5.3 ASCII's
    compact `32.4L` form.** SOW §4.6's tile table shows `₹XX,XX,XXX`; the ASCII
    mock is space-constrained shorthand. Full values are exact and fit via the
    tile's `FittedBox` scale-down. Flag if the client wants compact.
  - 5 tests incl. per-value rounding (`26034.867 → ₹26,035`) and light+dark
    **golden files** (`.../widgets/goldens/summary_card_{light,dark}.png`).
- [x] **5.2 `EmiChart`** — `fl_chart` PieChart donut, 200dp; Principal (primary) vs Interest (secondary); centre = Total Payable; legend w/ % + absolute; 1200 ms ease-in-out first render, instant on drag (SOW §4.5).
  - **DONE 2026-09-06**: `fl_chart` **1.x** `PieChart` (API differs from SOW
    §4.5's 0.68 sketch — treated as intent). 200dp diameter, section radius 26,
    `centerSpaceRadius = 100 − 26`. Principal segment `scheme.primary`, interest
    `scheme.secondary`. Legend below: 12dp gap to the donut, 8dp between the two
    rows; each row = 12dp rounded swatch + name (tinted to the segment colour) +
    `Spacer` + whole-number `%` + absolute `₹` value, both tabular.
  - **DECISION — animation via a dedicated `AnimationController`, not
    `PieChart`'s implicit tween.** A 1200ms ease-in-out controller sweeps the
    donut from empty→full on first mount using a third *filler* section sized
    `total × (1 − f)`; `PieChart` itself runs `duration: Duration.zero`, so once
    the controller completes (`f == 1`) later prop changes (slider drags on a
    still-mounted chart) snap with no re-animation — exactly the SOW rule.
  - **DECISION — centre label = `headlineSmall` + full `toIndianCurrency()`
    inside a `FittedBox`,** with a small `TOTAL PAYABLE` caps caption above it.
    "Large type" is honoured (as large as fits the 132dp hole); full value keeps
    it exact vs the ASCII's `₹62.4L`. Flag if the client wants the compact form.
  - 5 tests: legend names, `%` summing to 100 (incl. the 48/52 rounding case),
    absolute values, centre label, and the first-render sweep settling at 1200ms.
- [x] **5.3 `AmortizationTable`** — Monthly/Yearly `ToggleButtons`; columns Yr/Mo, EMI, Principal, Interest, Balance; sticky header; alt-row `surfaceVariant`; row h48; `FontFeature.tabularFigures()`.
  - **DONE 2026-09-06**: new **presentation-only** provider
    `amortizationUnitProvider` → `NotifierProvider<AmortizationUnit>`
    (`monthly` default), deliberately separate from `tenureUnitProvider` per the
    phase brief — new `AmortizationUnit { monthly, yearly }` enum rather than
    reusing `TenureUnit`, which means something else.
  - `AmortizationTable` renders as a **sliver** (`SliverMainAxisGroup`) so it
    drops straight into the Results screen's single `CustomScrollView`: own
    `SectionLabel('Amortization')` (`mt=24`), `h36` `ToggleButtons`, then a
    **`SliverPersistentHeader(pinned: true)`** header (48dp extent, opaque
    `surface` bg + bottom divider) that sticks under the AppBar while rows
    scroll. Columns share a `_columnFlex = [3,4,4,4,5]` list between header and
    rows so they stay aligned; first column header is `MONTH`/`YEAR` by mode.
    Rows: 48dp, whole-rupee Indian grouping (no `₹` to save width, matching the
    ASCII), `FontFeature.tabularFigures()` on every numeric cell, alt-row bg =
    `surfaceContainerHighest` (the token SOW calls `surfaceVariant`). Every cell
    is a `FittedBox` scale-down for large text scales.
- [x] **5.4 Break-even highlight** — highlight first row where cumulative principal > cumulative interest (SOW §4.4).
  - **DONE 2026-09-06**: highlight index comes from `amortizationProvider`'s
    `monthlyBreakEvenIndex` / `yearlyBreakEvenIndex` (the **crossover**
    definition settled in task 1.4 — first period whose principal component >
    its interest component). Applied in **both** Monthly and Yearly modes.
  - **DECISION — highlight styling (SOW doesn't specify):** `primaryContainer`
    row fill + a 3px `primary` leading rule + `w600` cell text +
    `onPrimaryContainer` text colour. Clearly distinct from the alt-row
    `surfaceVariant` tint in both themes. Flag if the client wants something
    subtler.
  - Home Loan default: Monthly row highlighted at index 142 (month 143), Yearly
    at index 12 (year 13) — asserted by widget tests.
- [x] **5.5 Performance pass** — 360-row list scrolls at 60 fps; use `ListView.builder`/lazy `DataTable` alternative (AC-04).
  - **DONE 2026-09-06**: rows are a lazy `SliverList.builder` — **no** 360-child
    `DataTable`. Each row is a fixed-height `Container` + `Row` of `Expanded`
    cells (no per-row `Expensive` layout, no shadows — M3 tonal only). Widget
    test with a 360-month schedule asserts `< 40` `_ScheduleRow` instances are
    ever built (only the on-screen window), which is the structural guarantee
    behind AC-04.
  - **EVIDENCE / METHOD for the on-device 60fps check (deferred to Phase 8.2 /
    device pass, no mid-range device in this environment):** run a profile build,
    enable the Performance overlay (`flutter run --profile`, `P`), open Results
    with the Home default, fling the amortization list top→bottom→top. Expect
    the raster + UI bars to stay under the 16.6ms line with no red frames.
    Capture the overlay screenshot into `/qa/`. Same for a 360-month loan.
- [x] **5.6 Results render budget** — visible within 300 ms of Calculate tap; verify via devtools timeline (AC-03).
  - **DONE 2026-09-06**: Results screen is one `CustomScrollView` fed by the
    **warm** `emiResultProvider` (kept alive by the Calculator form, Phase 4.6),
    so `SummaryCard` + `EmiChart` build on the **first frame** with no async
    gap. `amortizationProvider` is a pure derivation of the already-resolved
    result (yearly aggregation + crossover scan over ≤360 rows, sub-millisecond)
    that settles on the same microtask drain; a spinner sliver is only a
    fallback. Widget test pumps the screen after warming the provider and
    asserts `SummaryCard` + the `₹26,035` EMI are present after a **single**
    `tester.pump()` (no `pumpAndSettle`) — i.e. zero frames of loading state.
  - **EVIDENCE / METHOD for the on-device 300ms check (deferred to Phase 8):**
    `flutter run --profile`, DevTools → Performance → Timeline; tap CALCULATE
    EMI; measure from the pointer-up event to the first fully-painted Results
    frame. Expect < 300ms (the calc itself already ran on the Calculator screen).
  - DoD (phase): golden test for SummaryCard ✓ (light + dark); perf overlay
    screenshot — **method documented above, capture deferred to the Phase 8
    device pass** (no mid-range device available here).
- **PHASE 5 DONE 2026-09-06** — branch `feat/results-screen` (not merged, not
  pushed). `flutter analyze` 0/0 · `dart format .` clean · `dart run custom_lint`
  clean · `flutter test` **183 green** (+23 vs Phase 4's 160). New tests:
  `summary_card_test` (5, incl. 2 goldens), `emi_chart_test` (5),
  `amortization_unit_provider_test` (3), `amortization_table_test` (5),
  `results_screen_test` (5). Light/dark parity + 1.3× text scale verified by
  widget test (`takeException()` null after scrolling the full screen in both
  themes). Also added `test/flutter_test_config.dart` to disable `google_fonts`
  runtime fetching so goldens are deterministic.
  **NEEDS CLIENT CONFIRMATION:** (a) full Indian format vs compact `32.4L` in
  the summary tiles + chart centre; (b) break-even row highlight styling
  (`primaryContainer` fill + primary rule); (c) on-device perf captures
  (AC-03/AC-04) to be produced in the Phase 8 device pass.
  **CONFIRMED 2026-09-06 (client):** (a) full Indian format — keep as built
  (`₹62,48,368`, no compact `L`/`Cr` in tiles or chart centre); (b) break-even
  highlight styling approved as built (`primaryContainer` fill + 3px `primary`
  leading rule + `w600`); (c) on-device AC-03/AC-04 perf evidence to be captured
  in the Phase 8 device pass. No code changes — branch ready to merge.

---

## Phase 6 — Info Sheet, Sharing, Splash  (SOW §5.1, §5.4, §4.7 · Timeline Day 3 AM)

- [x] **6.1 `InfoBottomSheet`** — modal, drag-to-dismiss, max 60% height; formula text, how-computed, app version from `package_info`.
  - **DONE 2026-09-06** (branch `feat/info-share-splash`, commit `787470f`): `/info` is now
    a real modal bottom sheet, not a full-screen dialog. New public
    `ModalBottomSheetPage<T>` in `app_router.dart` wraps `ModalBottomSheetRoute`
    (`showDragHandle: true`, `enableDrag: true`, `useSafeArea: true`,
    `constraints: maxHeight = 60% of screen height`); the `[?]` AppBar icon's
    existing `context.push(AppRoutes.info)` now opens it. `InfoBottomSheet` rebuilt
    as scrollable content only (no `Scaffold`/`AppBar`): the SOW §4.3 formula in a
    tinted code block, a plain-language "how the EMI is computed" paragraph +
    `Total Interest = EMI × n − P` / `Total Payable = P + Total Interest`, then
    `EMI Calculator v<version>` / `by Softpital`. All spacing from `app_spacing`
    tokens, colours from the scheme.
  - **DECISION — app version source (interim, needs client OK):** `package_info_plus`
    is NOT in SOW §9. Rather than block, added `core/constants/app_info.dart` with
    `kAppVersion = '1.0.0'` (hand-synced with `pubspec.yaml` `version:`), documented
    as interim. **PROPOSAL for client:** approve adding `package_info_plus` (same
    precedent as `dynamic_color`) so the version is read from the platform at
    runtime; otherwise keep the const and formalise the bump in Phase 9.3.
  - 5 widget tests (`info_bottom_sheet_test.dart`): content present, drag-handle +
    `enableDrag` wired, height ≤ 60% of a 900px screen with scrollable content,
    fling-from-handle dismisses, dark mode + 1.3× text scale no-overflow.
- [x] **6.2 Splash screen** — app icon, gradient Primary600→800, `LinearProgressIndicator`, 1.5 s → `/calculator`.
  - **DONE 2026-09-06** (commit `787470f`): 80dp icon (`Icons.calculate`, placeholder
    until the Phase 9.1 launcher art), `EMI Calculator` headline
    (`headlineMedium` = Poppins 28sp, forced `FontWeight.bold`), muted `by Softpital`
    (`bodyMedium`, `onPrimary` @ 0.8α), 2dp `LinearProgressIndicator`. Auto-navigates
    to `/calculator` after `SplashScreen.displayDuration` (1.5s, now a named const so
    tests reference it). Timer cancelled on dispose.
  - **DECISION — gradient stops.** SOW §5.1 asks for "Primary 600 → Primary 800" but
    §6.1's palette only defines a single `primary` token (no 600/800 steps). Both
    stops are derived from `scheme.primary`: top = `lerp(primary, white, 0.12)` (≈600),
    bottom = `lerp(primary, black, 0.24)` (≈800). No hardcoded hex.
  - 3 tests (`splash_screen_test.dart`): name/by-line/80dp icon/2dp bar present;
    stays on splash at 1.4s then lands on `/calculator` by 1.6s; timer cancels on
    early dispose (no exception). `widget_test.dart` "App boots to the splash screen"
    still green (already overrides `sharedPreferencesProvider`).
- [x] **6.3 Share feature** — icon/FAB on Results; build exact plain-text summary from SOW §4.7; open native sheet via `share_plus` (AC-06).
  - DoD: share text matches template byte-for-byte for Home Loan default; manual test on real iOS + Android.
  - **DONE 2026-09-06** (commit `787470f`): Results `AppBar` share icon (placeholder
    `onPressed: () {}` from Phase 5) now calls
    `SharePlus.instance.share(ShareParams(text: ..., subject: 'EMI Calculator Result'))`
    (share_plus 12.x API — the deprecated static `Share.share` is avoided). Button is
    disabled until both `emiResultProvider` and `loanInputProvider` have values. Text
    built by pure `buildEmiShareText({input, result})` in
    `features/calculator/presentation/utils/emi_share_text.dart`: header
    `EMI Calculator Result — Softpital` (U+2014 em dash), input block (label
    `padRight(13)`), result block (label `padRight(17)`), footer
    `Calculated using EMI Calculator App`, blocks separated by blank lines, no
    trailing newline. Loan-type labels `Home Loan` / `Car Loan` / `Personal Loan`;
    rate `"<x>% p.a."`; tenure via `int.toTenureLabel()`; currency via
    `double.toIndianCurrency()`.
  - **DECISION — display rounding basis (SOW §4.3).** The §4.7 template's
    `₹32,48,400` / `₹62,48,400` are only reproducible from the **rounded** EMI:
    share text uses `roundedEmi = result.monthlyEmi.round()`, then
    `Total Payable = roundedEmi × n`, `Total Interest = Total Payable − P`. The
    unrounded `EmiResult` totals would give `₹62,48,368`-ish.
  - **CONFIRMED 2026-09-06 (client): leave both as-is — settled.** The share text
    keeps `roundedEmi × n` (reproduces §4.7 exactly); the Results `SummaryCard` keeps
    independent per-value rounding of the unrounded `EmiResult`. The resulting ~₹30
    cross-surface difference is **intentional and accepted**, not a bug. A `//`
    comment at the rounding site in `emi_share_text.dart` points here so it is not
    "fixed" later. No code change.
  - 7 tests (`emi_share_text_test.dart`): byte-for-byte template match for the Home
    Loan default, colon alignment, Car/Personal labels + figures, rounded-EMI totals,
    fractional-year tenure. Plus 1 widget test in `results_screen_test.dart` that
    mocks the `dev.fluttercommunity.plus/share` platform channel and asserts the tap
    sends exactly `buildEmiShareText(...)`.
  - **DEFERRED:** AC-06 final check = manual share on real iOS + Android (native sheet
    can't run in a widget test) — Phase 8 device pass.

**PHASE 6 DONE 2026-09-06** — branch `feat/info-share-splash`, merged to `develop`
via `--no-ff` in `da2092c` (not pushed — `develop` stays ahead of `origin/develop`).
Branch deleted post-merge (Phase 1–5 pattern).
`flutter analyze` 0/0 · `dart format` clean · `dart run custom_lint` clean ·
`flutter test` **198 green** (+15 vs Phase 5's 183). New tests:
`emi_share_text_test` (7), `splash_screen_test` (3), `info_bottom_sheet_test` (5).
New deviation from SOW §8 tree: `features/calculator/presentation/utils/` for
`emi_share_text.dart` (standard presentation-helper location).
**CONFIRMED 2026-09-06 (client):**
* App version — **keep the `kAppVersion = '1.0.0'` const** in
  `core/constants/app_info.dart`; do **not** add `package_info_plus`. Version
  handling is formalised in Phase 9.3. (Bundle-id / applicationId is **not** touched
  in this branch — see the report's bundle-id discrepancy note.)
* Share-text vs SummaryCard rounding — **left as-is, settled.** Share uses
  `roundedEmi × n` (byte-for-byte §4.7); SummaryCard rounds each unrounded value
  independently. The ~₹30 cross-surface difference is intentional.
Unblocks **Phase 7 — AdMob** (`AdmobBannerWidget` on Results, interstitial-every-5th-calc).

---

## Phase 7 — AdMob Integration  (SOW §4.8 · Timeline Day 3 AM)

**CLIENT DECISIONS 2026-09-06 (Phase 7 kickoff):**
* Ad unit IDs loaded via **`--dart-define-from-file=.env`** (no new runtime dep) —
  not `flutter_dotenv`. Native *app* ID injected separately (Gradle reads `.env`;
  iOS xcconfig).
* **iOS ATT** — approved adding `app_tracking_transparency ^2.0.7` (latest; not
  `^5.x`). Addition beyond SOW §9 (precedent: `dynamic_color`).
* **Interstitial counter** — client chose "every settled recalculation". **OPEN /
  flagged back to client:** firing a full-screen ad mid-slider-drag violates AdMob
  policy ("interstitial without warning while the user interacts"). Proposed
  compromise: counter still increments per settled recalc, but the interstitial is
  only *presented* at a natural boundary (next CALCULATE EMI tap / Results entry),
  never on first use. **Awaiting confirmation before building 7.4.**
* Production AdMob IDs — **RECEIVED from client 2026-09-06** (publisher
  `pub-6537371585934021`). Written to git-ignored `.env`:
  - Android app `…~4107919860`, banner `…/6948388978`, interstitial `…/4978148400`
  - iOS app `…~9820140496`, banner `…/3254732140`, interstitial `…/8889473254`
  `.env.example` keeps Google **test** IDs as the committed template. Release
  builds pass `--dart-define-from-file=.env`; `debug` builds use test IDs
  (Android Gradle gates the native app ID per build type; iOS Debug.xcconfig
  keeps the test app ID, Release.xcconfig carries the prod one).
* Pending confirm (defaults assumed): UMP consent request wired now (ships in
  `google_mobile_ads`, no dep); `minSdk` pinned to 24; banner = fixed footer on
  Results; branch `feat/admob-integration` off `develop`, `--no-ff`, not pushed.

- [x] **7.1 🔒 `google_mobile_ads` setup** — iOS `Info.plist` `GADApplicationIdentifier` + SKAdNetwork ids; Android `AndroidManifest` APPLICATION_ID; ATT prompt on iOS.
  - **DONE 2026-09-06** (branch `feat/admob-integration`):
    * `pubspec.yaml` — added `app_tracking_transparency: ^2.0.7` (client-approved,
      beyond SOW §9). `google_mobile_ads: ^9.1.0` was already present from Phase 0.
    * **Android** `AndroidManifest.xml` — added `<uses-permission INTERNET>`, the
      `com.google.android.gms.ads.APPLICATION_ID` `<meta-data>` (value =
      `${admobAppId}` placeholder), plus `OPTIMIZE_INITIALIZATION` /
      `OPTIMIZE_AD_LOADING` flags so the SDK defers heavy init to our own
      `bootstrapAds()` (protects AC-02). `app/build.gradle.kts` — pinned
      `minSdk = 24` (was `flutter.minSdkVersion` = 21; SOW AC-10 + GMA 9.x needs
      23+); parses project-root `.env` for `ADMOB_APP_ID_ANDROID` → sets
      `manifestPlaceholders["admobAppId"]` **per build type** — `debug` always
      uses Google's test app ID, `release` uses the `.env` value (prod), with a
      test-ID fallback when `.env` is absent (CI).
    * **iOS** `Info.plist` — `GADApplicationIdentifier = $(ADMOB_APP_ID_IOS)`,
      `NSUserTrackingUsageDescription`, and the full Google `SKAdNetworkItems`
      list (43 IDs). `ios/Flutter/Debug.xcconfig` = test app ID,
      `Release.xcconfig` = **prod** app ID (`…~9820140496`).
    * `lib/core/ads/ads_bootstrap.dart` — `bootstrapAds()`: iOS ATT request
      (only when `notDetermined`) → `MobileAds.instance.initialize()`; wrapped in
      `try/on Object catch` so a flaky SDK can never break launch; `_started`
      one-shot guard + `resetAdsBootstrapForTest()`. Called **fire-and-forget**
      (`unawaited`) from `main()` so the cold-start budget (AC-02) doesn't pay
      for ad init.
    * **VERIFIED:** `flutter build apk --debug` → merged manifest `APPLICATION_ID`
      = **test** app ID; `flutter build apk --release --dart-define-from-file=.env`
      → merged manifest `APPLICATION_ID` = **prod** `…~4107919860` (build-type
      gating confirmed). Single `INTERNET` permission. `flutter analyze` 0/0,
      `flutter test` 200 green. **iOS build not run here** (toolchain/pods) —
      deferred to the Phase 8 device pass, same as prior phases' on-device checks.
- [x] **7.2 `.env` for ad unit IDs** (D-07) — `flutter_dotenv` or `--dart-define`; test IDs default, prod IDs gated by build flavor; `.env` git-ignored, `.env.example` committed.
  - **DONE 2026-09-06**: `lib/core/config/ad_config.dart` — `AdConfig` resolves
    `bannerUnitId` / `interstitialUnitId` per `defaultTargetPlatform`.
  - **HARD MODE GATE (client, 2026-09-06): debug → test, release → prod.**
    `AdConfig` branches on `kReleaseMode`: any debug/profile build returns the
    hardcoded Google **test** unit IDs and ignores `.env` entirely (even if
    `--dart-define-from-file=.env` is passed); **release** builds return the
    `String.fromEnvironment` values from `.env`, falling back to test IDs if the
    flag was forgotten (`usingTestUnitIds` flags that). Same gate on the native
    app ID: Android `build.gradle.kts` sets the manifest placeholder per build
    type; iOS `Debug.xcconfig` = test app ID, `Release.xcconfig` = prod.
  - `.env` git-ignored (`.env` + `.env.*`, `!.env.example`); `.env.example`
    committed with test IDs + the consumption rules.
  - **VERIFIED in the built binary:** `flutter build apk --release
    --dart-define-from-file=.env` → `strings lib/*/libapp.so` contains **only**
    `ca-app-pub-6537371585934021/6948388978` (prod banner), zero test unit IDs.
    Debug behaviour locked by `test/core/ad_config_test.dart` (runs in
    `kReleaseMode == false` → asserts test IDs + `usingTestUnitIds`).
- [x] **7.3 `AdmobBannerWidget`** — 320×50 pinned above system nav on Results; reserves space, never overlaps content (AC-07).
  - **DONE 2026-09-06**: `admob_banner_widget.dart` rebuilt from the Phase 0
    no-op into a `ConsumerStatefulWidget`. Loads a `BannerAd`
    (`AdConfig.bannerUnitId`, `AdSize.banner` = 320×50, `const AdRequest()`) in
    `initState` **only when** `adsEnabledProvider` is true. Layout: a fixed
    `Container` of `AppSizes.adBannerHeight (50) + bottom safe-area inset +
    kSpacingSM (8)` (SOW §5.3 "system bottom inset + 8dp"), `surface`
    background, ad centred. While the creative is still loading the band is
    reserved (no content shift on fill, AC-07); on `onAdFailedToLoad` the
    widget flips `_failed` and collapses to `SizedBox.shrink()` (7.5). Ad
    disposed in `dispose()`; late `onAdLoaded` after unmount is disposed too.
  - New provider `lib/core/ads/ads_providers.dart` `adsEnabledProvider`
    (`Provider<bool>`, true on iOS/Android). Widget tests override it to
    `false` so the platform channel is never hit.
  - Wired on `ResultsScreen` via `AppScaffold.bottomNavigationBar` (the slot
    already earmarked "e.g. AdMob banner on Results"). Removed the old
    `_ResultsBody` trailing `SizedBox(kSpacing24 + bottomInset)` — the banner
    now owns the bottom inset; trailing gap is a flat `kSpacing24`.
  - Tests: `admob_banner_widget_test.dart` (2 — disabled path collapses to 0
    height with no channel touch; "enabled" path in the SDK-less test host
    ends collapsed-or-reserved, never a partial band, no zone exception).
    `results_screen_test.dart` `makeContainer()` now overrides
    `adsEnabledProvider(false)`.
  - **DEFERRED to Phase 8 device pass:** real fill on 3 screen sizes,
    airplane-mode collapse, no-overlap visual check on device (AC-07 final).
- [ ] **7.4 Interstitial** — counter in persistent storage; show on every 5th calculation, never on first use; preload next.  *(BLOCKED on the interstitial-timing confirmation above.)*
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
