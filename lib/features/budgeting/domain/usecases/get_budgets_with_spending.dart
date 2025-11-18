import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

// Implementasi UseCase dengan Type 'List<BudgetWithSpending>' dan Params 'GetBudgetsParams'
class GetBudgetsWithSpending implements UseCase<List<BudgetWithSpending>, GetBudgetsParams> {
  final BudgetRepository repository;

  GetBudgetsWithSpending(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, List<BudgetWithSpending>>>
  @override
  Future<Either<Failure, List<BudgetWithSpending>>> call(GetBudgetsParams params) async {
    return await repository.getBudgetsWithSpending(params.month, params.year);
  }
}

// Class untuk membungkus parameter yang dibutuhkan oleh 'call'
class GetBudgetsParams extends Equatable {
  final int month;
  final int year;

  const GetBudgetsParams({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

