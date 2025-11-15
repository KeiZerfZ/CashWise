import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class DeleteSavingGoal implements UseCase<void, Params> {
  final SavingGoalRepository repository;
  DeleteSavingGoal(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async {
    return await repository.deleteSavingGoal(params.goalId);
  }
}

class Params extends Equatable {
  final int goalId;
  const Params({required this.goalId});
  @override
  List<Object> get props => [goalId];
}