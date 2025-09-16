import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

class DeleteBudget implements UseCase<void, DeleteBudgetParams> {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBudgetParams params) async {
    return await repository.deleteBudget(params.budgetId);
  }
}

class DeleteBudgetParams extends Equatable {
  final int budgetId;
  // Kita tambahkan month & year di sini agar BLoC bisa me-refresh halaman dengan benar
  final int month;
  final int year;

  const DeleteBudgetParams({required this.budgetId, required this.month, required this.year});

  @override
  List<Object?> get props => [budgetId, month, year];
}