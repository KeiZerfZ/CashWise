import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/budgeting/data/datasources/budget_local_data_source.dart';
import 'package:cashwise/features/budgeting/data/models/budget_model.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

// Ini adalah kelas PEKERJA yang menjalankan semua tugas di dalam KONTRAK BudgetRepository.
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<BudgetWithSpending>>> getBudgetsWithSpending(int month, int year) async {
    try {
      final result = await localDataSource.getBudgetsWithSpending(month, year);
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveBudget(Budget budget) async {
    try {
      // FIX DI SINI: Terjemahkan dari Entity (resep murni) ke format Drift
      final budgetModel = BudgetModel.fromEntity(budget);
      final companion = budgetModel.toCompanion();
      await localDataSource.saveBudget(companion);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(int budgetId) async {
    try {
      await localDataSource.deleteBudget(budgetId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}