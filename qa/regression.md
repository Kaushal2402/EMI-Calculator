# Manual Regression Script — EMI Calculator

Run **in full on one physical iOS device and one physical Android device** before
any release build (SOW §11, Phase 8.7). Also run the launch + happy-path subset
on an **Android 7 / API 24** emulator and an **iOS 14** simulator (AC-10).

Record device, OS version, build (`flutter --version`, app `version+build`),
date, tester. Mark each step **P / F / N/A** and file failures in `qa/bugs.md`.

| Field | Value |
|---|---|
| Device / OS | |
| App version+build | |
| Build type | debug / profile / release |
| Date / tester | |

---

## 0. Install & cold start

- [ ] Fresh install (uninstall first). App launches with no crash / ANR.
- [ ] Splash screen: gradient (primary 600→800), 80 dp app icon, "EMI
      Calculator", "by Softpital", 2 dp progress bar.
- [ ] Splash auto-advances to Calculator in ~1.5 s (no tap needed).
- [ ] **AC-02**: from tap-to-open to interactive Calculator < 2 s (mid-range
      Android; capture Perfetto/DevTools trace → `qa/evidence/ac02-*`).
- [ ] Kill and relaunch: last-used inputs and theme are restored (SOW §7.5).

## 1. Calculator screen — layout

- [ ] AppBar "EMI Calculator" + `?` info icon, 64 dp tall.
- [ ] Loan-type `SegmentedButton`: Home / Car / Personal, 40 dp, 16 dp side
      margins, distinct icons.
- [ ] Section labels (ALL CAPS, muted) for Principal / Interest Rate / Tenure.
- [ ] Each field: TextField (56 dp) + synced Slider + min/max range labels.
- [ ] Tenure has a Years / Months toggle.
- [ ] CALCULATE EMI filled button, 52 dp, pinned near bottom with 24 dp +
      safe-area bottom margin.
- [ ] Spacing matches SOW §5.2 (24 dp under AppBar, 20 dp between groups,
      32 dp above CTA).

## 2. Calculator screen — behaviour

- [ ] **AC-05** Tab → Home: 30,00,000 · 8.50% · 20 yr.
- [ ] **AC-05** Tab → Car: 8,00,000 · 9.00% · 5 yr.
- [ ] **AC-05** Tab → Personal: 3,00,000 · 13.00% · 3 yr.
- [ ] Switching tab after editing resets that type's defaults (no stale values).
- [ ] Principal: type `4500000` → renders `45,00,000` (Indian grouping); slider
      jumps to match.
- [ ] Principal below `10,000` / above `5,00,00,000` → clamped on blur, error
      shown, out-of-range value not used.
- [ ] Rate: type `8.55`, step is 0.05; above `36` / below `1` clamped on blur.
- [ ] Tenure: enter `18` in Years → toggle to Months shows `216`; internal value
      stays months. Range 1–30 yr / 12–360 mo enforced.
- [ ] Drag each slider fast: no jank, field updates live, no calculation errors.
- [ ] Real-time recalculation feels immediate (150 ms debounce) — no full-screen
      spinner between keystrokes.

## 3. Info bottom sheet (SOW §5.4)

- [ ] `?` opens a modal bottom sheet with a drag handle.
- [ ] Shows the EMI formula, plain-language "how it's computed", and app version.
- [ ] Height capped at 60% of screen; content scrolls inside.
- [ ] Drag-down and scrim tap both dismiss.

## 4. Results screen — layout (SOW §5.3)

- [ ] Tapping CALCULATE EMI navigates to Results.
- [ ] **AC-03** Results content visible < 300 ms after tap (DevTools timeline →
      `qa/evidence/ac03-*`). No visible loading flash.
- [ ] AppBar: back arrow, "Results", share icon (↗).
- [ ] SummaryCard: 3 metric tiles (Monthly EMI / Total Interest / Total
      Payable), outlined (elevation 0), 12 dp radius, 16 dp margins.
- [ ] Tile values: Indian format, tabular figures, bold; labels muted CAPS.
- [ ] "BREAKUP" section: 200 dp donut chart, centre = Total Payable, legend
      below with swatch + name + % + ₹ for Principal and Interest.
- [ ] Legend percentages sum to 100. Legend label text is default colour (not
      red/blue) with a coloured swatch (AC-09 fix).
- [ ] Donut animates once (~1200 ms ease) on first render.
- [ ] "AMORTIZATION" section: Monthly / Yearly toggle; sticky header row;
      columns Period / EMI / Principal / Interest / Balance; 48 dp rows;
      alternating row tint.
- [ ] Break-even row (first period where principal component > interest
      component) highlighted (primaryContainer fill + 3 px primary left rule).
- [ ] Numbers use tabular figures and stay column-aligned.

## 5. Results screen — behaviour

- [ ] Monthly ↔ Yearly toggle re-renders the table; break-even highlight tracks
      the mode.
- [ ] Scroll the whole screen: header pins, no overflow, no clipped text.
- [ ] **AC-04** 360-month loan (₹50,00,000 / 8% / 30 yr): fling the amortization
      list top→bottom→top with the Performance overlay on — 60 fps, no red
      frames (→ `qa/evidence/ac04-*`).
- [ ] Final row outstanding balance ≈ ₹0; sum of principal column ≈ principal.
- [ ] Back returns to Calculator with inputs intact.

## 6. Share (SOW §4.7)

- [ ] **AC-06** Share icon opens the **system** share sheet.
- [ ] Shared text matches the SOW §4.7 template exactly for the Home default
      (header "EMI Calculator Result — Softpital", aligned colons, footer
      "Calculated using EMI Calculator App"). Screenshot → `qa/evidence/ac06-*`.
- [ ] Share to Notes/Mail: text pastes intact, ₹ and line breaks preserved.
- [ ] Share works for all three loan types and after changing inputs.

## 7. Ads (SOW §4.8) — device only

- [ ] **AC-07** Banner (320×50) pinned at the bottom of Results, above the
      system nav, with `system bottom inset + 8 dp` padding.
- [ ] Banner never overlaps the amortization table's last row or the share FAB;
      content above it does not shift when the ad loads.
- [ ] Check on ≥ 3 screen sizes (small phone, large phone, tablet-width / split
      view): no overlap, no layout break.
- [ ] Interstitial: does **not** show on the 1st calculation. Shows on the 5th
      calculation (count calculations from a fresh launch); dismiss returns to
      Results, no state loss.
- [ ] Interstitial never interrupts mid-input or mid-scroll.
- [ ] Airplane mode / no network: banner collapses to 0 px (no empty strip),
      interstitial silently skipped, rest of the app fully usable.
- [ ] Release build shows **production** ad units only; debug build shows Google
      test units only (verify via `adb logcat` / Console).

## 8. iOS privacy prompts (iOS device only)

- [ ] First launch: ATT prompt appears exactly once.
- [ ] Deny ATT → app still works, ads still render (non-personalised).
- [ ] EEA locale (e.g. set region to Germany): UMP / GDPR consent form appears
      before ads; choices are honoured; "Manage" path reachable.
- [ ] Non-EEA locale: no consent form.

## 9. Theming & accessibility

- [ ] Toggle system Light ↔ Dark: every screen re-themes with no unreadable
      text, no invisible borders/icons, chart + table legible in both.
- [ ] Theme choice persists across relaunch.
- [ ] OS font size → largest: Calculator and Results remain usable, no clipped
      or overlapping text, CTA reachable (widget tests cover 1.3×; verify the
      device max).
- [ ] Display zoom / smallest width device: no horizontal scroll, no overflow.
- [ ] TalkBack / VoiceOver: loan-type tabs, fields, sliders, CALCULATE, share,
      and table are focusable and announced sensibly; slider announces its
      value.
- [ ] Portrait lock: rotate the device on every screen — UI stays portrait
      (Calculator, Results, Info sheet, interstitial).

## 10. Robustness

- [ ] Rapid CALCULATE taps: single navigation, no duplicate Results.
- [ ] Background the app mid-calculation, return: state intact.
- [ ] Rotate + background + low-memory (Android "Don't keep activities"): app
      restores to a sane state, no crash.
- [ ] Deep spam of tab switches + slider drags for ~30 s: no crash, no leak
      (watch memory in DevTools).

## 11. Min-OS smoke (AC-10)

Run steps 0–6 + 9 (theme/rotation) on:

- [ ] Android 7.0 emulator (API 24) — no crash, layout intact.
- [ ] iOS 14 simulator — no crash, layout intact.

---

### Sign-off

All steps P (or F triaged in `qa/bugs.md` and accepted) · evidence in
`qa/evidence/` · date · tester · build hash.
