import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class AddContribution implements UseCase<void, SavingContribution> {
  final SavingGoalRepository repository;
  AddContribution(this.repository);

  @override
  Future<Either<Failure, void>> call(SavingContribution contribution) async {
    return await repository.addContribution(contribution);
  }
}