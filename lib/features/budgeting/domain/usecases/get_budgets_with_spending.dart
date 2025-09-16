import 'package:equatable/equatable.dart'; // <-- Jangan lupa import ini
import 'package:fpdart/fpdart.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

class GetBudgetsWithSpending implements UseCase<List<BudgetWithSpending>, GetBudgetsParams> {
  final BudgetRepository repository;

  GetBudgetsWithSpending(this.repository);

  @override
  Future<Either<Failure, List<BudgetWithSpending>>> call(GetBudgetsParams params) async {
    return await repository.getBudgetsWithSpending(params.month, params.year);
  }
}

// <-- TAMBAHKAN KELAS INI DI BAWAHNYA
class GetBudgetsParams extends Equatable {
  final int month;
  final int year;

  const GetBudgetsParams({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}