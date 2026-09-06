import 'package:emi_calculator/core/utils/indian_number_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = IndianDigitsInputFormatter();

  TextEditingValue format(String input) => formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: input,
      selection: TextSelection.collapsed(offset: input.length),
    ),
  );

  test('regroups digits into the Indian numeral system', () {
    expect(format('3000000').text, '30,00,000');
    expect(format('12345678').text, '1,23,45,678');
    expect(format('500').text, '500');
  });

  test('strips non-digits and leading zeros', () {
    expect(format(r'3,00,0a00$').text, '3,00,000');
    expect(format('0000042').text, '42');
    expect(format('0').text, '0');
  });

  test('empty input clears the field', () {
    expect(format('').text, '');
    expect(format('abc').text, '');
  });

  test('caret is collapsed to the end', () {
    final result = format('3000000');
    expect(result.selection, const TextSelection.collapsed(offset: 9));
  });
}
