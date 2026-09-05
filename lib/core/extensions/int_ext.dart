/// Convenience extensions on [int] (SOW §8 `int_ext.dart`).
extension IntTenureX on int {
  /// Treats this int as a month count and renders it as `20 Years` /
  /// `18 Months` / `1 Year 6 Months`.
  String toTenureLabel() {
    final years = this ~/ 12;
    final months = this % 12;
    final parts = <String>[
      if (years > 0) '$years ${years == 1 ? 'Year' : 'Years'}',
      if (months > 0) '$months ${months == 1 ? 'Month' : 'Months'}',
    ];
    return parts.isEmpty ? '0 Months' : parts.join(' ');
  }

  /// Whole years contained in this month count.
  int get asWholeYears => this ~/ 12;
}
