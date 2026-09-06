import 'package:emi_calculator/core/constants/loan_defaults.dart';
import 'package:emi_calculator/features/calculator/data/datasources/loan_local_datasource.dart';
import 'package:emi_calculator/features/calculator/domain/entities/loan_input.dart';
import 'package:emi_calculator/features/calculator/domain/repositories/loan_repository.dart';

/// Data-layer implementation of [LoanRepository] (SOW §7.5).
///
/// A thin adapter over [LoanLocalDataSource]. DTO ↔ entity mapping lives in the
/// data source (see `LoanInputDto`); this class adds only the first-launch
/// fallback (task 2.3) when nothing has been persisted yet.
class LoanRepositoryImpl implements LoanRepository {
  /// Creates the repository with its data source.
  const LoanRepositoryImpl(this._dataSource);

  final LoanLocalDataSource _dataSource;

  @override
  Future<LoanInput> getLastInput() async {
    final stored = await _dataSource.readLastInput();
    return stored ?? firstLaunchLoanInput();
  }

  @override
  Future<void> saveLastInput(LoanInput input) =>
      _dataSource.writeLastInput(input);
}
