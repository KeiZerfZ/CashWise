// lib/features/budgeting/domain/usecases/save_budget.dart

import 'package:fpdart/fpdart.dart'; // <-- DIUBAH dari dartz ke fpdart
import 'package:equatable/equatable.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

class SaveBudget implements UseCase<void, SaveBudgetParams> {
  final BudgetRepository repository;

  SaveBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveBudgetParams params) {
    return repository.saveBudget(params.budget);
  }
}

class SaveBudgetParams extends Equatable {
  final Budget budget;

  const SaveBudgetParams({required this.budget});

  @override
  List<Object?> get props => [budget];
}