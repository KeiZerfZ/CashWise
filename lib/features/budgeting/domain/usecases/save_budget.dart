import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

// Implementasi UseCase dengan Type 'void' dan Params 'SaveBudgetParams'
class SaveBudget implements UseCase<void, SaveBudgetParams> {
  final BudgetRepository repository;

  SaveBudget(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, void>>
  @override
  Future<Either<Failure, void>> call(SaveBudgetParams params) async {
    return await repository.saveBudget(params.budget);
  }
}

// Class untuk membungkus parameter yang dibutuhkan oleh 'call'
class SaveBudgetParams extends Equatable {
  final Budget budget;

  const SaveBudgetParams({required this.budget});

  @override
  List<Object?> get props => [budget];
}

