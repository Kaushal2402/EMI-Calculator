/// Data-transfer object for [LoanInput] persistence (SOW §7.5).
///
/// Lives in the data layer only. It owns the on-disk JSON shape and the
/// mapping to/from the domain [LoanInput] entity so that neither the domain
/// nor `SharedPreferences` needs to know about the other.
library;

import 'dart:convert';

import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';

/// Serialisable representation of a [LoanInput].
///
/// Persisted as a single JSON string under one `SharedPreferences` key. The
/// [schemaVersion] field lets future migrations detect and upgrade old blobs
/// instead of silently discarding them.
class LoanInputDto {
  /// Creates a DTO from primitive values.
  const LoanInputDto({
    required this.principal,
    required this.annualRate,
    required this.tenureMonths,
    required this.loanType,
    this.schemaVersion = currentSchemaVersion,
  });

  /// Builds a DTO from a domain [LoanInput].
  factory LoanInputDto.fromEntity(LoanInput input) => LoanInputDto(
    principal: input.principal,
    annualRate: input.annualRate,
    tenureMonths: input.tenureMonths,
    loanType: input.loanType.name,
  );

  /// Builds a DTO from a decoded JSON map.
  ///
  /// Throws [FormatException] if a required field is missing or has the wrong
  /// type, or if [loanType] is not a known [LoanType] name.
  factory LoanInputDto.fromJson(Map<String, dynamic> json) {
    final principal = json['principal'];
    final annualRate = json['annualRate'];
    final tenureMonths = json['tenureMonths'];
    final loanType = json['loanType'];

    if (principal is! num ||
        annualRate is! num ||
        tenureMonths is! num ||
        loanType is! String) {
      throw const FormatException('LoanInputDto: missing or mistyped field');
    }
    if (!LoanType.values.any((t) => t.name == loanType)) {
      throw FormatException('LoanInputDto: unknown loanType "$loanType"');
    }

    final version = json['schemaVersion'];
    return LoanInputDto(
      principal: principal.toDouble(),
      annualRate: annualRate.toDouble(),
      tenureMonths: tenureMonths.toInt(),
      loanType: loanType,
      schemaVersion: version is num ? version.toInt() : 1,
    );
  }

  /// Decodes a stored JSON string into a DTO.
  ///
  /// Throws [FormatException] on invalid JSON or invalid shape.
  factory LoanInputDto.decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('LoanInputDto: not a JSON object');
    }
    return LoanInputDto.fromJson(decoded);
  }

  /// Current on-disk schema version.
  static const int currentSchemaVersion = 1;

  /// Principal loan amount, in ₹.
  final double principal;

  /// Annual interest rate as a percentage (e.g. `8.5`).
  final double annualRate;

  /// Loan tenure in months.
  final int tenureMonths;

  /// [LoanType] name (`home` / `car` / `personal`).
  final String loanType;

  /// Schema version of this blob.
  final int schemaVersion;

  /// Maps to the domain entity.
  LoanInput toEntity() => LoanInput(
    principal: principal,
    annualRate: annualRate,
    tenureMonths: tenureMonths,
    loanType: LoanType.values.byName(loanType),
  );

  /// JSON map representation.
  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'principal': principal,
    'annualRate': annualRate,
    'tenureMonths': tenureMonths,
    'loanType': loanType,
  };

  /// Encodes to a storable JSON string.
  String encode() => jsonEncode(toJson());
}
