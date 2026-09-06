import 'package:emi_calculator/features/calculator/data/models/loan_input_dto.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const homeInput = LoanInput(
    principal: 3000000,
    annualRate: 8.5,
    tenureMonths: 240,
    loanType: LoanType.home,
  );

  group('LoanInputDto', () {
    test('entity → DTO → entity round-trips unchanged', () {
      final restored = LoanInputDto.fromEntity(homeInput).toEntity();
      expect(restored, homeInput);
    });

    test(
      'encode → decode → entity round-trips unchanged for every LoanType',
      () {
        for (final type in LoanType.values) {
          final input = LoanInput(
            principal: 123456.78,
            annualRate: 12.35,
            tenureMonths: 77,
            loanType: type,
          );
          final json = LoanInputDto.fromEntity(input).encode();
          expect(
            LoanInputDto.decode(json).toEntity(),
            input,
            reason: type.name,
          );
        }
      },
    );

    test('encode writes the current schema version', () {
      final dto = LoanInputDto.fromEntity(homeInput);
      expect(dto.schemaVersion, LoanInputDto.currentSchemaVersion);
      expect(dto.toJson()['schemaVersion'], LoanInputDto.currentSchemaVersion);
    });

    test('fromJson tolerates integer-valued principal/rate', () {
      final dto = LoanInputDto.fromJson(const {
        'principal': 800000,
        'annualRate': 9,
        'tenureMonths': 60,
        'loanType': 'car',
      });
      expect(dto.toEntity().principal, 800000.0);
      expect(dto.toEntity().annualRate, 9.0);
    });

    test('fromJson defaults schemaVersion to 1 when absent', () {
      final dto = LoanInputDto.fromJson(const {
        'principal': 300000.0,
        'annualRate': 13.0,
        'tenureMonths': 36,
        'loanType': 'personal',
      });
      expect(dto.schemaVersion, 1);
    });

    test('fromJson throws FormatException on a missing field', () {
      expect(
        () => LoanInputDto.fromJson(const {
          'principal': 300000.0,
          'annualRate': 13.0,
          'loanType': 'personal',
        }),
        throwsFormatException,
      );
    });

    test('fromJson throws FormatException on a mistyped field', () {
      expect(
        () => LoanInputDto.fromJson(const {
          'principal': 'lots',
          'annualRate': 13.0,
          'tenureMonths': 36,
          'loanType': 'personal',
        }),
        throwsFormatException,
      );
    });

    test('fromJson throws FormatException on an unknown loanType', () {
      expect(
        () => LoanInputDto.fromJson(const {
          'principal': 300000.0,
          'annualRate': 13.0,
          'tenureMonths': 36,
          'loanType': 'boat',
        }),
        throwsFormatException,
      );
    });

    test('decode throws FormatException on malformed JSON', () {
      expect(() => LoanInputDto.decode('{not json'), throwsFormatException);
    });

    test('decode throws FormatException when JSON is not an object', () {
      expect(() => LoanInputDto.decode('[1,2,3]'), throwsFormatException);
    });
  });
}
