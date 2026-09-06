import 'package:emi_calculator/core/utils/number_formatter.dart';
import 'package:flutter/services.dart';

/// [TextInputFormatter] that regroups the field's digits into the Indian
/// numeral system as the user types (SOW §4.2, `##,##,##,##0`).
///
/// Non-digits are stripped, the value is regrouped (`3000000` -> `30,00,000`)
/// and the caret is collapsed to the end. Editing the middle of a currency
/// amount is rare, so end-anchoring the caret is an acceptable trade for
/// always-correct grouping.
class IndianDigitsInputFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const IndianDigitsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return TextEditingValue.empty;

    // Trim leading zeros but keep a single '0'.
    final normalised = digits.replaceFirst(RegExp('^0+(?=.)'), '');
    final grouped = NumberFormatter.grouped(int.parse(normalised));
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}
