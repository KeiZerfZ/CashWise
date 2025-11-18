import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal_with_details.dart';

abstract class SavingGoalRepository {
  // 1. Buat "Markas": Muat semua celengan (plus total setorannya)
  Future<Either<Failure, List<SavingGoalWithDetails>>> getAllSavingGoals();

  // 2. Buat "Detail": Muat 1 celengan + SEMUA riwayat setorannya
  Future<Either<Failure, List<SavingContribution>>> getGoalContributions(int goalId);

  // 3. Buat "Formulir": Nambah/Edit celengan
  Future<Either<Failure, void>> saveSavingGoal(SavingGoal goal);

  // 4. Hapus celengan
  Future<Either<Failure, void>> deleteSavingGoal(int goalId);

  // 5. Tambah setoran ke celengan
  Future<Either<Failure, void>> addContribution(SavingContribution contribution);
}