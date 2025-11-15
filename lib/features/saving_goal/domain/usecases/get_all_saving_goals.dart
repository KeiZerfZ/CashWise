import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal_with_details.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class GetAllSavingGoals implements UseCase<List<SavingGoalWithDetails>, NoParams> {
  final SavingGoalRepository repository;
  GetAllSavingGoals(this.repository);

  @override
  Future<Either<Failure, List<SavingGoalWithDetails>>> call(NoParams params) async {
    return await repository.getAllSavingGoals();
  }
}