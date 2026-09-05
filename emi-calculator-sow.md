# Scope of Work
## EMI Calculator — Flutter Mobile Application (iOS & Android)

---

| Field | Detail |
|---|---|
| **Document Version** | 1.0 |
| **Prepared By** | Softpital (iTechAI) |
| **Date** | September 2026 |
| **Platform** | Flutter — iOS & Android |
| **Architecture** | Clean Architecture · Feature-First |
| **State Management** | Riverpod 2.x (code generation) |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Project Objectives](#2-project-objectives)
3. [Scope of Work](#3-scope-of-work)
4. [Feature Specifications](#4-feature-specifications)
5. [Screen-by-Screen Specification](#5-screen-by-screen-specification)
6. [Design System](#6-design-system)
7. [Technical Architecture](#7-technical-architecture)
8. [Folder Structure](#8-folder-structure)
9. [Package Dependencies](#9-package-dependencies)
10. [Out of Scope](#10-out-of-scope)
11. [Acceptance Criteria](#11-acceptance-criteria)
12. [Timeline](#12-timeline)
13. [Deliverables](#13-deliverables)

---

## 1. Executive Summary

The **EMI Calculator** is a standalone Flutter mobile application for iOS and Android that enables users to calculate Equated Monthly Instalments (EMI) for home loans, car loans, and personal loans. The app provides an amortization breakdown table and a visual chart comparing interest paid versus principal repaid over the loan tenure.

The product is monetised through in-app display advertising (Google AdMob). Its design is optimised for fast, frictionless daily use by salaried professionals, first-time home buyers, and anyone comparing loan offers.

---

## 2. Project Objectives

- **Primary:** Deliver a fully functional EMI calculator that returns accurate results for all three loan types.
- **Secondary:** Provide a full amortization schedule (monthly and yearly views) so users understand total cost over time.
- **Tertiary:** Display a clear interest-vs-principal visual breakdown that drives re-engagement and social sharing.
- **Business:** Integrate AdMob banner and interstitial ads without degrading the core user experience.

---

## 3. Scope of Work

### 3.1 In Scope

| # | Area | Description |
|---|---|---|
| 1 | Flutter App | Single codebase for iOS (≥ 14.0) and Android (≥ SDK 24 / Android 7.0) |
| 2 | EMI Engine | Pure Dart formula engine with zero external dependency |
| 3 | Loan Types | Home Loan, Car Loan, Personal Loan — each with preset defaults |
| 4 | Input Controls | Principal, Interest Rate, Tenure (months/years toggle) |
| 5 | Results View | Monthly EMI, Total Interest, Total Amount Payable |
| 6 | Amortization Table | Month-by-month and year-by-year schedule |
| 7 | Chart | Donut chart — interest vs principal ratio |
| 8 | Theme | Light and Dark mode (Material 3) |
| 9 | Ads | AdMob banner (results screen) + interstitial (every 5th calculation) |
| 10 | Sharing | Share result summary as plain text via system share sheet |

### 3.2 Out of Scope

Refer to [Section 10](#10-out-of-scope) for the explicit exclusion list.

---

## 4. Feature Specifications

### 4.1 Loan Type Selector

- Three segmented tabs: **Home Loan · Car Loan · Personal Loan**
- Switching tab resets inputs to that loan type's defaults (see table below)
- Each type carries a distinct icon for quick visual recognition

| Loan Type | Default Principal | Default Rate | Default Tenure |
|---|---|---|---|
| Home Loan | ₹30,00,000 | 8.50% p.a. | 20 years |
| Car Loan | ₹8,00,000 | 9.00% p.a. | 5 years |
| Personal Loan | ₹3,00,000 | 13.00% p.a. | 3 years |

### 4.2 Input Fields

| Field | Type | Constraints | Format |
|---|---|---|---|
| Principal Amount | Numeric + Slider | ₹10,000 – ₹5,00,00,000 | Indian number system (₹1,23,45,678) |
| Annual Interest Rate | Numeric + Slider | 1.00% – 36.00%, step 0.05% | XX.XX% |
| Loan Tenure | Numeric | 1–30 years · 12–360 months | Toggle switch: Years / Months |

- All fields support both **text entry** and **slider** interaction — they stay in sync.
- Indian numeral formatting applied via `intl` package (`NumberFormat('##,##,##,##0.##')`).
- Real-time calculation triggers on every input change (debounced 150 ms).

### 4.3 EMI Calculation Engine

**Formula:**

```
EMI = P × r × (1 + r)ⁿ / ((1 + r)ⁿ − 1)

Where:
  P = Principal loan amount
  r = Monthly interest rate (annual rate / 12 / 100)
  n = Loan tenure in months
```

**Computed outputs:**

| Output | Description |
|---|---|
| Monthly EMI | Rounded to nearest ₹1 |
| Total Interest Payable | EMI × n − P |
| Total Amount Payable | P + Total Interest |
| Interest-to-Principal Ratio | Used for chart rendering |

### 4.4 Amortization Schedule

- Toggle between **Monthly** and **Yearly** breakdown
- Each row shows: Month/Year, EMI, Principal Component, Interest Component, Outstanding Balance
- Tabular numerics use `tabular-nums` equivalent (`fontFeatures: [FontFeature.tabularFigures()]`)
- Sticky header row as table scrolls
- Highlight the **first row where cumulative principal > cumulative interest** (break-even point)

### 4.5 Visual Chart — Interest vs Principal

- **Type:** Animated donut chart (fl_chart `PieChart`)
- **Segments:** 
  - Interest Payable (accent colour — red/orange family)
  - Principal Amount (primary colour — blue family)
- **Centre label:** Total Amount Payable in large type
- **Legend:** Percentage + absolute value for each segment
- **Animation:** 1200ms ease-in-out on first render; instant update on slider drag

### 4.6 Result Summary Card

Displayed above the chart. Three metric tiles in a row:

| Tile | Label | Value |
|---|---|---|
| Left | Monthly EMI | ₹XX,XXX |
| Centre | Total Interest | ₹XX,XX,XXX |
| Right | Total Payable | ₹XX,XX,XXX |

### 4.7 Share Feature

- FAB or icon button on the Results screen
- Generates a formatted plain-text summary:

```
EMI Calculator Result — Softpital

Loan Type    : Home Loan
Principal    : ₹30,00,000
Interest Rate: 8.50% p.a.
Tenure       : 20 Years

Monthly EMI      : ₹26,035
Total Interest   : ₹32,48,400
Total Payable    : ₹62,48,400

Calculated using EMI Calculator App
```

- Opens native share sheet via `share_plus`

### 4.8 AdMob Integration

| Ad Unit | Placement | Trigger |
|---|---|---|
| Banner (320×50) | Bottom of Results screen, above system nav | Always visible on result view |
| Interstitial | Full screen | Every 5th calculation — never on first use |

---

## 5. Screen-by-Screen Specification

### 5.1 Splash Screen

```
┌─────────────────────────────┐
│                             │
│                             │
│          [App Icon]         │   ← 80×80dp, centred
│        EMI Calculator       │   ← Headline/28sp, bold
│         by Softpital        │   ← Body/14sp, muted
│                             │
│                             │
│  ████████████████░░░░░░░░   │   ← LinearProgressIndicator, 2dp height
└─────────────────────────────┘
```

- Duration: 1.5 s then auto-navigate to Home
- Gradient background: Primary 600 → Primary 800

---

### 5.2 Home / Calculator Screen

```
┌─────────────────────────────────┐
│ AppBar: "EMI Calculator"    [?] │   h = 64dp
├─────────────────────────────────┤
│ ╔═══════════════════════════╗   │
│ ║  Home  │  Car  │  Personal║   │   ← SegmentedButton, h = 40dp, mx = 16dp
│ ╚═══════════════════════════╝   │
│                                 │
│  ── Principal Amount ──         │   ← Section label, 12sp, caps, mt = 24dp
│  ┌─────────────────────────┐    │
│  │  ₹ 30,00,000            │    │   ← TextField h = 56dp, mx = 16dp
│  └─────────────────────────┘    │
│  ━━━━━━━━━━━━━━●━━━━━━━━━━━    │   ← Slider, mx = 16dp, mt = 8dp
│  ₹10K                  ₹5Cr    │   ← Range labels, 11sp, mt = 4dp
│                                 │
│  ── Annual Interest Rate ──     │   mt = 20dp
│  ┌─────────────────────────┐    │
│  │  8.50 %                 │    │
│  └─────────────────────────┘    │
│  ━━━━━━●━━━━━━━━━━━━━━━━━━━    │
│  1%                       36%   │
│                                 │
│  ── Loan Tenure ──              │   mt = 20dp
│  ┌──────────────┐ [ Yr | Mo ]   │   ← TextField + ToggleButtons, mt = 8dp
│  │  20          │               │
│  └──────────────┘               │
│  ━━━━━●━━━━━━━━━━━━━━━━━━━━    │
│  1 Yr                    30 Yr  │
│                                 │
│  ╔═══════════════════════════╗  │
│  ║     CALCULATE EMI         ║  │   ← FilledButton, h = 52dp, mx = 16dp, mb = 24dp
│  ╚═══════════════════════════╝  │
└─────────────────────────────────┘
```

**Spacing rules for this screen:**

| Element | Spacing |
|---|---|
| Screen horizontal padding | `EdgeInsets.symmetric(horizontal: 16)` |
| AppBar bottom to first widget | `24dp` |
| Section label top margin | `20dp` (first: `0dp`) |
| Section label bottom to field | `8dp` |
| Slider top margin | `8dp` |
| Slider range labels top | `4dp` |
| Between field groups | `20dp` |
| Calculate button top | `32dp` |
| Calculate button bottom | `24dp` (+ system bottom padding) |

---

### 5.3 Results Screen

```
┌─────────────────────────────────┐
│ ← Back   Results           [↗]  │   AppBar h = 64dp, [↗] = Share icon
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ ┌──────┐  ┌──────┐  ┌─────┐│ │   ← SummaryCard: 3 MetricTiles
│ │ │ EMI  │  │Int.  │  │Total││ │     Card mx=16, py=20, px=16
│ │ │26,035│  │32.4L │  │62.4L││ │     Tile gap = 8dp
│ │ └──────┘  └──────┘  └─────┘│ │     Value: 22sp, bold
│ └─────────────────────────────┘ │     Label: 11sp, muted caps
│                                 │
│  ── Breakup ──                  │   mt = 24dp, mx = 16dp
│         ┌────────┐              │
│         │  Donut │              │   ← PieChart: 200dp diameter
│         │ ₹62.4L │              │     Legend below, gap = 12dp
│         └────────┘              │
│  ■ Principal  48%  ₹30,00,000   │
│  ■ Interest   52%  ₹32,48,400   │
│                                 │
│  ── Amortization ──             │   mt = 24dp, mx = 16dp
│  [Monthly]  [Yearly]            │   ← ToggleButtons, h = 36dp
│  ┌──┬──────┬───────┬───────┬──┐ │
│  │Yr│  EMI │ Princ │  Int  │Bal│ │   ← DataTable sticky header
│  ├──┼──────┼───────┼───────┼──┤ │     Row h = 48dp
│  │ 1│26,035│ 4,168 │ 21,258│...│ │     Alt row bg: surface-variant
│  │ 2│26,035│ 4,510 │ ...   │...│ │
│  └──┴──────┴───────┴───────┴──┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │       AdMob Banner 320×50   │ │   ← Always pinned above system nav
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**Spacing rules for this screen:**

| Element | Spacing |
|---|---|
| Screen horizontal padding | `EdgeInsets.symmetric(horizontal: 16)` |
| SummaryCard top margin | `16dp` |
| SummaryCard elevation | `0` (outlined, not elevated) |
| SummaryCard border radius | `12dp` |
| Chart top margin | `24dp` |
| Chart container padding | `16dp` |
| Legend item gap | `8dp vertical` |
| Amortization section top margin | `24dp` |
| Table row height | `48dp` |
| AdMob banner bottom padding | `system bottom inset + 8dp` |

---

### 5.4 Info / About Bottom Sheet

- Triggered by `[?]` icon in Calculator AppBar
- Modal bottom sheet (drag to dismiss)
- Content: formula used, how EMI is computed, app version
- Max height: 60% of screen

---

## 6. Design System

### 6.1 Color Palette (Material 3 — Dynamic Color supported)

| Token | Light | Dark | Usage |
|---|---|---|---|
| `primary` | `#1565C0` | `#90CAF9` | Buttons, active states, sliders |
| `onPrimary` | `#FFFFFF` | `#003C8F` | Text on primary |
| `primaryContainer` | `#D3E4FF` | `#1565C0` | Segmented button active bg |
| `secondary` | `#E53935` | `#EF9A9A` | Interest segment, interest labels |
| `surface` | `#FAFAFA` | `#121212` | Screen backgrounds |
| `surfaceVariant` | `#EEF2FA` | `#1E1E1E` | Alternate table rows, card bg |
| `outline` | `#C5CAD3` | `#3A3A3A` | Text field borders |
| `onSurface` | `#1A1A2E` | `#E0E0E0` | Body text |
| `onSurfaceVariant` | `#5C6470` | `#A0A0A0` | Labels, hints, captions |

> Dynamic Color (`DynamicColorBuilder`) is supported on Android 12+. The palette above is the fallback seed.

### 6.2 Typography Scale

Uses **`Poppins`** (display / headings) + **`Inter`** (body / data) via `google_fonts`.

| Style | Font | Weight | Size | Line Height | Usage |
|---|---|---|---|---|---|
| `displaySmall` | Poppins | 700 | 36sp | 44dp | EMI value in summary |
| `headlineMedium` | Poppins | 600 | 28sp | 36dp | Screen titles |
| `headlineSmall` | Poppins | 600 | 24sp | 32dp | Section card headers |
| `titleLarge` | Poppins | 600 | 22sp | 28dp | Metric tile values |
| `titleMedium` | Inter | 500 | 16sp | 24dp | Input field text |
| `bodyLarge` | Inter | 400 | 16sp | 24dp | General body |
| `bodyMedium` | Inter | 400 | 14sp | 20dp | Secondary descriptions |
| `labelLarge` | Inter | 600 | 14sp | 20dp | Button labels |
| `labelMedium` | Inter | 500 | 12sp | 16dp | Table headers, caps labels |
| `labelSmall` | Inter | 400 | 11sp | 16dp | Slider range labels, hints |

Letter spacing for ALL CAPS labels: `0.08em`.

### 6.3 Spacing System

The app uses an **8dp base grid**. All spacing values are multiples of 4dp.

```
4dp   — Micro gap (icon-to-label, badge padding)
8dp   — Tight gap (within a row of chips)
12dp  — Default gap (between stacked form elements)
16dp  — Standard unit (horizontal screen padding, card insets)
20dp  — Loose gap (between labeled field groups)
24dp  — Section gap (between major content blocks)
32dp  — Generous gap (CTA button top margin)
40dp  — Large gap (top of first section below AppBar)
48dp  — Extra-large (hero metric vertical padding)
```

**Component sizing:**

| Component | Height | Border Radius |
|---|---|---|
| `AppBar` | 64dp | — |
| `FilledButton` (CTA) | 52dp | 12dp |
| `OutlinedButton` | 44dp | 8dp |
| `TextField` (Material 3) | 56dp | 12dp |
| `SegmentedButton` (loan type) | 40dp | 8dp (full) |
| `ToggleButton` (Yr/Mo) | 36dp | 8dp (full) |
| `SummaryCard` | auto | 12dp |
| `DataTable` row | 48dp | — |
| `BottomNavBar` | 80dp | — |
| `AdMob banner` | 50dp | — |

### 6.4 Elevation & Shadow

Material 3 tonal elevation is used — no custom shadows.

| Surface | Tonal Elevation |
|---|---|
| Screen background | Level 0 |
| Cards (SummaryCard, chart container) | Level 1 (4dp) |
| AppBar (on scroll) | Level 2 (8dp) |
| Modal bottom sheet | Level 3 (12dp) |
| FAB / Share button | Level 3 |

### 6.5 Iconography

- Icon library: **Material Symbols** (outlined weight 400, grade 0, size 24dp)
- Key icons: `calculate`, `home`, `directions_car`, `person`, `share`, `info_outline`, `expand_more`, `calendar_month`

---

## 7. Technical Architecture

### 7.1 Overview — Clean Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Presentation Layer                        │
│   Screens → Widgets → Providers (Riverpod StateNotifier)     │
├──────────────────────────────────────────────────────────────┤
│                       Domain Layer                            │
│         Use Cases · Entities · Repository Interfaces         │
├──────────────────────────────────────────────────────────────┤
│                        Data Layer                             │
│        Repository Implementations · Local Data Source        │
│              (SharedPreferences — last inputs)                │
└──────────────────────────────────────────────────────────────┘
```

### 7.2 State Management — Riverpod 2.x

Code-generation approach using `@riverpod` annotations.

| Provider | Type | Responsibility |
|---|---|---|
| `loanInputProvider` | `StateNotifierProvider` | Holds form state (principal, rate, tenure, type) |
| `emiResultProvider` | `FutureProvider` | Triggers calculation use case, exposes `EmiResult` |
| `amortizationProvider` | `Provider` | Derives schedule list from `emiResultProvider` |
| `selectedTabProvider` | `StateProvider<LoanType>` | Active loan type tab |
| `tenureUnitProvider` | `StateProvider<TenureUnit>` | Years vs Months toggle |
| `themeProvider` | `StateProvider<ThemeMode>` | App theme |

### 7.3 Navigation — GoRouter 14+

| Route | Path | Screen |
|---|---|---|
| Root | `/` | `SplashScreen` |
| Calculator | `/calculator` | `CalculatorScreen` |
| Results | `/results` | `ResultsScreen` |
| Info | `/info` (modal) | `InfoBottomSheet` |

### 7.4 EMI Calculation — Domain Layer

```dart
// entities/loan_input.dart
@freezed
class LoanInput with _$LoanInput {
  const factory LoanInput({
    required double principal,     // in ₹
    required double annualRate,    // as percentage, e.g. 8.5
    required int    tenureMonths,  // always stored in months
    required LoanType loanType,
  }) = _LoanInput;
}

// entities/emi_result.dart
@freezed
class EmiResult with _$EmiResult {
  const factory EmiResult({
    required double monthlyEmi,
    required double totalInterest,
    required double totalPayable,
    required double principalRatio,   // 0.0–1.0
    required double interestRatio,    // 0.0–1.0
    required List<AmortizationRow> schedule,
  }) = _EmiResult;
}

// use_cases/calculate_emi_use_case.dart
class CalculateEmiUseCase {
  EmiResult execute(LoanInput input) {
    final r = input.annualRate / 12 / 100;
    final n = input.tenureMonths;
    final p = input.principal;
    final emi = (r == 0) ? p / n : p * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
    final totalPayable = emi * n;
    final totalInterest = totalPayable - p;
    // ... build schedule
  }
}
```

### 7.5 Persistence

- Last-used inputs saved to `SharedPreferences` on every calculation
- Restored on app launch via the `loanInputProvider` initialiser
- Theme preference persisted to `SharedPreferences`

---

## 8. Folder Structure

```
lib/
├── main.dart
├── app.dart                        # MaterialApp.router, ThemeData, GoRouter
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart        # const double kSpacingXS = 4.0; etc.
│   │   └── loan_defaults.dart
│   ├── extensions/
│   │   ├── double_ext.dart         # .toIndianCurrency(), .toPercentage()
│   │   └── int_ext.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   └── utils/
│       └── number_formatter.dart   # Indian numeral system
│
├── features/
│   ├── calculator/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── loan_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── loan_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── loan_input.dart
│   │   │   │   ├── emi_result.dart
│   │   │   │   └── amortization_row.dart
│   │   │   ├── repositories/
│   │   │   │   └── loan_repository.dart
│   │   │   └── use_cases/
│   │   │       └── calculate_emi_use_case.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── loan_input_provider.dart
│   │       │   └── emi_result_provider.dart
│   │       ├── screens/
│   │       │   ├── calculator_screen.dart
│   │       │   └── results_screen.dart
│   │       └── widgets/
│   │           ├── loan_type_selector.dart
│   │           ├── amount_input_field.dart
│   │           ├── rate_input_field.dart
│   │           ├── tenure_input_field.dart
│   │           ├── summary_card.dart
│   │           ├── metric_tile.dart
│   │           ├── emi_chart.dart
│   │           ├── amortization_table.dart
│   │           └── admob_banner_widget.dart
│   │
│   └── info/
│       └── presentation/
│           ├── screens/
│           │   └── info_bottom_sheet.dart
│           └── providers/
│               └── theme_provider.dart
│
└── shared/
    └── widgets/
        ├── app_scaffold.dart
        ├── section_label.dart
        └── error_view.dart
```

---

## 9. Package Dependencies

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # UI / Fonts
  google_fonts: ^6.2.1
  fl_chart: ^0.68.0

  # Ads
  google_mobile_ads: ^5.1.0

  # Utilities
  intl: ^0.19.0
  share_plus: ^9.0.0
  shared_preferences: ^2.3.0

  # Data / Serialisation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  very_good_analysis: ^6.0.0
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.7
  riverpod_lint: ^2.3.13
```

---

## 10. Out of Scope

The following items are explicitly excluded from this engagement:

| # | Excluded Item |
|---|---|
| 1 | Backend API or cloud database of any kind |
| 2 | User accounts, login, or authentication |
| 3 | Loan comparison across multiple lenders |
| 4 | Live interest rate feeds or bank API integration |
| 5 | PDF export of the amortization schedule |
| 6 | Push notifications or reminders |
| 7 | Multi-currency support |
| 8 | Prepayment / part-payment simulation |
| 9 | Tablet-optimised layout |
| 10 | App Store / Play Store submission (asset preparation only) |
| 11 | Analytics integration (Firebase, Mixpanel, etc.) |
| 12 | Localisation beyond English (en) and Hindi (hi) number formatting |

---

## 11. Acceptance Criteria

| # | Criterion | Verification Method |
|---|---|---|
| AC-01 | EMI formula output matches standard financial calculators (e.g., BankBazaar) within ±₹1 rounding | Unit test with 20 reference cases |
| AC-02 | App launches and reaches Calculator screen within 2 s on a mid-range device | Manual + Perfetto trace |
| AC-03 | Results screen renders within 300 ms of tapping Calculate | Frame timeline, Riverpod devtools |
| AC-04 | Amortization table scrolls at 60 fps for a 360-row schedule | Flutter Performance overlay |
| AC-05 | All three loan type defaults populate correctly on tab switch | Manual + widget test |
| AC-06 | Share sheet opens with correctly formatted text | Manual on device |
| AC-07 | AdMob banner renders without overlapping content | Manual, various screen sizes |
| AC-08 | App passes Flutter Analyze with 0 errors, 0 warnings | CI gate |
| AC-09 | Light and dark themes render with no contrast violations (WCAG AA) | Colour contrast analyser |
| AC-10 | No crash on minimum supported OS versions (iOS 14, Android 7) | Device farm / emulator |

---

## 12. Timeline

| Day | Milestone | Deliverable |
|---|---|---|
| **Day 1 — AM** | Project setup, Clean Architecture scaffold, routing | Git repo, folder structure, empty screens |
| **Day 1 — PM** | Domain layer complete — entities, use case, unit tests | `EmiResult`, `CalculateEmiUseCase`, passing tests |
| **Day 2 — AM** | Presentation layer — Calculator Screen, all input widgets | Working inputs + real-time calculation |
| **Day 2 — PM** | Results Screen — summary card, donut chart, amortization table | Fully interactive results view |
| **Day 3 — AM** | AdMob integration, share feature, theme toggle | Ads + sharing working |
| **Day 3 — PM** | QA, bug fixes, Play Store / App Store asset prep | Release-ready APK + IPA |

> **Total estimated effort:** 3 development days (1 developer)

---

## 13. Deliverables

| # | Deliverable | Format |
|---|---|---|
| D-01 | Full Flutter source code | Git repository (feature-branched) |
| D-02 | Release APK (Android) | `.apk` — `app-release.apk` |
| D-03 | Release IPA (iOS) | `.ipa` — requires Apple Dev account |
| D-04 | App icon set | PNG — all Android mipmap + iOS @1x/@2x/@3x |
| D-05 | Play Store screenshots (6×) | 1080×1920 PNG |
| D-06 | App Store screenshots (6×) | 1290×2796 PNG (iPhone 15 Pro Max) |
| D-07 | AdMob unit IDs config | `.env` file (test + production IDs) |
| D-08 | This SOW document | `emi-calculator-sow.md` |

---

*Document prepared by Softpital (iTechAI) · September 2026 · Version 1.0*  
*All spacing values in dp (density-independent pixels). All monetary values in Indian Rupees (₹).*
