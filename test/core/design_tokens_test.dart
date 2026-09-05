import 'package:emi_calculator/core/constants/app_colors.dart';
import 'package:emi_calculator/core/constants/app_spacing.dart';
import 'package:emi_calculator/core/constants/app_typography.dart';
import 'package:emi_calculator/core/theme/app_theme.dart';
import 'package:emi_calculator/core/utils/number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Spacing tokens', () {
    test('follow the 4dp grid in ascending order (SOW §6.3)', () {
      const values = [
        kSpacingXS,
        kSpacingSM,
        kSpacingMD,
        kSpacingLG,
        kSpacingXL,
        kSpacing24,
        kSpacing32,
        kSpacing40,
        kSpacing48,
      ];
      expect(
        values,
        [4, 8, 12, 16, 20, 24, 32, 40, 48].map((e) => e.toDouble()),
        reason: 'unexpected token values',
      );
      for (final v in values) {
        expect(v % 4, 0, reason: '$v is not a multiple of 4');
      }
    });
  });

  group('NumberFormatter (Indian numeral system, SOW §4.2)', () {
    test('groups digits 3-2-2', () {
      expect(NumberFormatter.currency(12345678), '₹1,23,45,678');
      expect(NumberFormatter.currency(3000000), '₹30,00,000');
    });

    test('formats percentages with two decimals', () {
      expect(NumberFormatter.percent(8.5), '8.50%');
    });
  });

  testWidgets('every text style in the scale renders', (tester) async {
    final textTheme = AppTypography.textTheme(Brightness.light);
    final styles = <String, TextStyle?>{
      'displaySmall': textTheme.displaySmall,
      'headlineMedium': textTheme.headlineMedium,
      'headlineSmall': textTheme.headlineSmall,
      'titleLarge': textTheme.titleLarge,
      'titleMedium': textTheme.titleMedium,
      'bodyLarge': textTheme.bodyLarge,
      'bodyMedium': textTheme.bodyMedium,
      'labelLarge': textTheme.labelLarge,
      'labelMedium': textTheme.labelMedium,
      'labelSmall': textTheme.labelSmall,
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(AppColors.light),
        home: Scaffold(
          body: ListView(
            children: [
              for (final entry in styles.entries)
                Text(entry.key, style: entry.value),
            ],
          ),
        ),
      ),
    );

    for (final entry in styles.entries) {
      expect(entry.value, isNotNull, reason: '${entry.key} missing');
      expect(find.text(entry.key), findsOneWidget);
    }
  });
}
