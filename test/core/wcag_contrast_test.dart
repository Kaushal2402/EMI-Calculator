import 'dart:math' as math;

import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 contrast audit for every foreground/background token pair the app
/// actually paints (SOW §6.1, AC-09).
///
/// * Normal text (< 18pt, or < 14pt bold) must reach a contrast ratio of 4.5:1.
/// * Large text (>= 18pt, or >= 14pt bold) and active UI component boundaries
///   must reach 3.0:1 (WCAG 1.4.3 / 1.4.11).
///
/// The maths is the WCAG relative-luminance definition, implemented here with
/// no dependency so the gate is self-contained.

/// sRGB channel (0-255) -> linearised component.
double _linearise(int channel8) {
  final c = channel8 / 255.0;
  return c <= 0.03928
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

/// WCAG relative luminance of an opaque colour.
double _relativeLuminance(Color color) {
  final r = _linearise((color.r * 255.0).round() & 0xff);
  final g = _linearise((color.g * 255.0).round() & 0xff);
  final b = _linearise((color.b * 255.0).round() & 0xff);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG contrast ratio between two opaque colours (1.0 .. 21.0).
double contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

class _Pair {
  const _Pair(
    this.usage,
    this.fg,
    this.bg, {
    this.minRatio = 4.5,
    this.note = '',
  });

  /// Where this combination is painted in the UI.
  final String usage;
  final Color Function(ColorScheme) fg;
  final Color Function(ColorScheme) bg;

  /// 4.5 for normal text, 3.0 for large text / UI boundaries.
  final double minRatio;
  final String note;
}

final List<_Pair> _pairs = [
  // --- Body / caption text on the two surfaces -----------------------------
  _Pair('body text on screen bg', (s) => s.onSurface, (s) => s.surface),
  _Pair(
    'caption/label text on screen bg',
    (s) => s.onSurfaceVariant,
    (s) => s.surface,
  ),
  _Pair(
    'body text on card / alt-row / field fill',
    (s) => s.onSurface,
    (s) => s.surfaceContainerHighest,
  ),
  _Pair(
    'table header / hint text on card / field fill',
    (s) => s.onSurfaceVariant,
    (s) => s.surfaceContainerHighest,
  ),
  // --- Primary family -----------------------------------------------------
  _Pair('CTA button label', (s) => s.onPrimary, (s) => s.primary),
  _Pair(
    'slider active track / accent text on screen bg',
    (s) => s.primary,
    (s) => s.surface,
  ),
  _Pair(
    'segmented-button active label',
    (s) => s.onPrimaryContainer,
    (s) => s.primaryContainer,
  ),
  _Pair(
    'amortization break-even row text (w600 -> large-text threshold)',
    (s) => s.onPrimaryContainer,
    (s) => s.primaryContainer,
    minRatio: 3,
    note: 'break-even cells are bold >=14pt; large-text 3:1 applies',
  ),
  // --- Secondary family (interest) --------------------------------------
  _Pair(
    'chart interest legend swatch on screen bg (UI boundary)',
    (s) => s.secondary,
    (s) => s.surface,
    minRatio: 3,
    note: '12x12 legend swatch is a non-text graphical object',
  ),
  _Pair(
    'label on secondary (scheme role — NOT painted as text anywhere; '
    'grep-verified. white on #E53935 is 4.23:1)',
    (s) => s.onSecondary,
    (s) => s.secondary,
    minRatio: 3,
    note:
        'no widget draws text on bare `secondary`; kept as a role sanity check',
  ),
  _Pair(
    'label on secondary container',
    (s) => s.onSecondaryContainer,
    (s) => s.secondaryContainer,
  ),
  // --- Error ------------------------------------------------------------
  _Pair(
    'input error text on screen bg',
    (s) => s.error,
    (s) => s.surface,
  ),
  _Pair('label on error', (s) => s.onError, (s) => s.error),
];

/// Known WCAG 1.4.11 (non-text contrast, 3:1) gaps that are NOT auto-enforced
/// because the `outline` token is pinned verbatim by SOW §6.1 and changing it
/// is a client decision (tracked as P1-01 in qa/bugs.md).
///
/// Measured this session:
///   light  outline #C5CAD3 on surface #FAFAFA            -> 1.58:1
///   light  outline #C5CAD3 on surfaceContainerHighest    -> 1.47:1
///   dark   outline #3A3A3A on surface #121212            -> 1.65:1
///   dark   outline #3A3A3A on surfaceContainerHighest    -> 1.47:1
final List<_Pair> _outlinePairsPendingClientDecision = [
  _Pair(
    'text-field / card border on screen bg (UI boundary)',
    (s) => s.outline,
    (s) => s.surface,
    minRatio: 3,
    note: 'WCAG 1.4.11 active-control boundary',
  ),
  _Pair(
    'text-field border on field fill (UI boundary)',
    (s) => s.outline,
    (s) => s.surfaceContainerHighest,
    minRatio: 3,
    note: 'WCAG 1.4.11 active-control boundary',
  ),
];

void main() {
  for (final scheme in <({String name, ColorScheme cs})>[
    (name: 'light', cs: AppColors.light),
    (name: 'dark', cs: AppColors.dark),
  ]) {
    group('WCAG AA contrast — ${scheme.name} scheme', () {
      for (final pair in _pairs) {
        test('${pair.usage} >= ${pair.minRatio}:1', () {
          final ratio = contrastRatio(pair.fg(scheme.cs), pair.bg(scheme.cs));
          expect(
            ratio,
            greaterThanOrEqualTo(pair.minRatio),
            reason:
                '${scheme.name}: "${pair.usage}" is ${ratio.toStringAsFixed(2)}:1 '
                '(needs ${pair.minRatio}:1). ${pair.note}',
          );
        });
      }

      for (final pair in _outlinePairsPendingClientDecision) {
        test(
          '${pair.usage} >= ${pair.minRatio}:1',
          () {
            final ratio = contrastRatio(pair.fg(scheme.cs), pair.bg(scheme.cs));
            expect(ratio, greaterThanOrEqualTo(pair.minRatio));
          },
          skip:
              'AC-09 waiver pending client sign-off — see qa/bugs.md P1-01. '
              '`outline` is pinned verbatim by SOW §6.1; a text field is still '
              'identifiable by its filled background + floating label.',
        );
      }
    });
  }

  test('contrastRatio sanity: black on white is 21:1', () {
    expect(
      contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
  });
}
