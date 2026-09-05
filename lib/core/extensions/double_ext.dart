import 'package:emi_calculator/core/utils/number_formatter.dart';

/// Convenience formatting extensions on [double] (SOW §8 `double_ext.dart`).
extension DoubleFormatX on double {
  /// `₹1,23,45,678` — Indian currency, rounded to whole rupees.
  String toIndianCurrency() => NumberFormatter.currency(this);

  /// `₹32.4L` / `₹1.2Cr` — compact currency for tight layouts.
  String toCompactCurrency() => NumberFormatter.compactCurrency(this);

  /// `8.50%` — two-decimal percentage.
  String toPercentage() => NumberFormatter.percent(this);

  /// Clamps this value into `[min, max]` as a [double].
  double clampTo(double min, double max) => clamp(min, max).toDouble();
}
