import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/saving_goal/data/datasources/saving_goal_local_data_source.dart';
import 'package:cashwise/features/saving_goal/data/models/saving_contribution_model.dart';
import 'package:cashwise/features/saving_goal/data/models/saving_goal_model.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal_with_details.dart';
import 'package:cashwise/features/saving_goal/domain/repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  final SavingGoalLocalDataSource localDataSource;
  SavingGoalRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> addContribution(SavingContribution contribution) async {
    try {
      final model = SavingContributionModel.fromEntity(contribution);
      final companion = model.toCompanion();
      await localDataSource.addContribution(companion);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavingGoal(int goalId) async {
    try {
      await localDataSource.deleteSavingGoal(goalId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SavingGoalWithDetails>>> getAllSavingGoals() async {
    try {
      // Ini adalah "Orkestrasi" data
      // 1. Ambil SEMUA celengan
      final goals = await localDataSource.getAllSavingGoals();
      // 2. Ambil SEMUA setoran
      final contributions = await localDataSource.getAllContributions();

      // 3. Gabungkan!
      final List<SavingGoalWithDetails> result = [];
      for (var goal in goals) {
        // 4. Cari setoran yang cocok
        final goalContributions = contributions.where((c) => c.goalId == goal.id);
        // 5. Jumlahkan total setorannya
        final total = goalContributions.fold(0.0, (sum, c) => sum + c.amount);
        
        // 6. Masukin ke paket
        result.add(SavingGoalWithDetails(
          goal: goal, // 'goal' di sini adalah 'SavingGoalModel', tapi itu gak masalah
          totalContribution: total,
        ));
      }
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SavingContribution>>> getGoalContributions(int goalId) async {
    try {
      final result = await localDataSource.getGoalContributions(goalId);
      // 'result' adalah List<SavingContributionModel>, tapi karena dia 'extends',
      // kita bisa langsung kirim sebagai List<SavingContribution>
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveSavingGoal(SavingGoal goal) async {
    try {
      final model = SavingGoalModel.fromEntity(goal);
      final companion = model.toCompanion();
      await localDataSource.saveSavingGoal(companion);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }
}