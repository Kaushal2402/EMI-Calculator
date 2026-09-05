import 'package:intl/intl.dart';

/// Indian numeral-system formatting helpers (SOW §4.2).
///
/// Uses the pattern `##,##,##,##0.##` so grouping is 3-2-2-2
/// (e.g. `1,23,45,678`).
abstract final class NumberFormatter {
  NumberFormatter._();

  static final NumberFormat _indianGrouping = NumberFormat('##,##,##,##0.##');
  static final NumberFormat _indianInteger = NumberFormat('##,##,##,##0');

  /// Formats [value] with Indian digit grouping and no currency symbol.
  static String grouped(num value) => _indianGrouping.format(value);

  /// Formats [value] as `₹1,23,45,678` (rounded to whole rupees).
  static String currency(num value) =>
      '₹${_indianInteger.format(value.round())}';

  /// Formats [value] as `₹1,23,45,678.90` keeping up to two decimals.
  static String currencyPrecise(num value) =>
      '₹${_indianGrouping.format(value)}';

  /// Formats a percentage like `8.50%` (two decimals, SOW §4.2).
  static String percent(num value) => '${value.toStringAsFixed(2)}%';

  /// Compact rupee form used in tight UI (e.g. `₹32.4L`, `₹1.2Cr`).
  static String compactCurrency(num value) {
    final v = value.abs();
    if (v >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}K';
    return '₹${value.round()}';
  }
}
