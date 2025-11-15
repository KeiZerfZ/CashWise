import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class GetGoalDetails implements UseCase<List<SavingContribution>, Params> {
  final SavingGoalRepository repository;
  GetGoalDetails(this.repository);

  @override
  Future<Either<Failure, List<SavingContribution>>> call(Params params) async {
    return await repository.getGoalContributions(params.goalId);
  }
}

class Params extends Equatable {
  final int goalId;
  const Params({required this.goalId});
  @override
  List<Object> get props => [goalId];
}