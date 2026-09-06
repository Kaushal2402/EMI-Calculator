import 'package:emi_calculator/core/providers/persistence_providers.dart';
import 'package:emi_calculator/features/calculator/data/repositories/loan_repository_impl.dart';
import 'package:emi_calculator/features/calculator/domain/repositories/loan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide [LoanRepository] (SOW §7.2 / §7.5).
///
/// Thin composition root: wires [LoanRepositoryImpl] to the shared
/// [loanLocalDataSourceProvider]. Override this in provider tests with a fake
/// repository so the state layer can be exercised without `SharedPreferences`.
final Provider<LoanRepository> loanRepositoryProvider =
    Provider<LoanRepository>(
      (ref) => LoanRepositoryImpl(ref.watch(loanLocalDataSourceProvider)),
    );
