import 'package:emi_calculator/features/calculator/data/datasources/loan_local_datasource.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/repositories/loan_repository.dart';

/// Data-layer implementation of [LoanRepository] (SOW §7.5).
///
/// PHASE 0 SCAFFOLD: wiring only. DTO ↔ entity mapping and first-launch
/// defaults land in tasks 2.2 / 2.3.
class LoanRepositoryImpl implements LoanRepository {
  /// Creates the repository with its data source.
  const LoanRepositoryImpl(this._dataSource);

  final LoanLocalDataSource _dataSource;

  @override
  Future<LoanInput?> getLastInput() => _dataSource.readLastInput();

  @override
  Future<void> saveLastInput(LoanInput input) =>
      _dataSource.writeLastInput(input);
}
