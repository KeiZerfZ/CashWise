import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart' as drift;
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';
import 'package:cashwise/features/budgeting/data/datasources/budget_local_data_source.dart';

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
      final budgetCompanion = BudgetsCompanion(
        id: budget.id == 0 ? const drift.Value.absent() : drift.Value(budget.id),
        categoryId: drift.Value(budget.categoryId),
        amount: drift.Value(budget.amount),
        month: drift.Value(budget.month),
        year: drift.Value(budget.year),
      );
      await localDataSource.saveBudget(budgetCompanion);
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