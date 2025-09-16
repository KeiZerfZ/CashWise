import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<BudgetWithSpending>>> getBudgetsWithSpending(int month, int year);
  Future<Either<Failure, void>> saveBudget(Budget budget);
  Future<Either<Failure, void>> deleteBudget(int budgetId);
}