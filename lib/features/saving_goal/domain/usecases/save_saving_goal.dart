import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class SaveSavingGoal implements UseCase<void, SavingGoal> {
  final SavingGoalRepository repository;
  SaveSavingGoal(this.repository);

  @override
  Future<Either<Failure, void>> call(SavingGoal goal) async {
    return await repository.saveSavingGoal(goal);
  }
}