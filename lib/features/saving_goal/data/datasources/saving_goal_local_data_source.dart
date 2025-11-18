import 'package:drift/drift.dart';
import 'package:cashwise/core/error/exceptions.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/saving_goal/data/models/saving_contribution_model.dart';
import 'package:cashwise/features/saving_goal/data/models/saving_goal_model.dart';

// --- Kontrak Kerja si "Koki" ---
abstract class SavingGoalLocalDataSource {
  // Ambil SEMUA celengan
  Future<List<SavingGoalModel>> getAllSavingGoals();
  // Ambil SEMUA riwayat setoran (buat ngitung total)
  Future<List<SavingContributionModel>> getAllContributions();
  // Ambil riwayat setoran buat 1 celengan spesifik
  Future<List<SavingContributionModel>> getGoalContributions(int goalId);
  // Simpan/Update 1 celengan
  Future<void> saveSavingGoal(SavingGoalsCompanion goal);
  // Hapus 1 celengan
  Future<void> deleteSavingGoal(int goalId);
  // Tambah 1 setoran
  Future<void> addContribution(SavingContributionsCompanion contribution);
}


// --- Implementasi si "Koki" ---
class SavingGoalLocalDataSourceImpl implements SavingGoalLocalDataSource {
  final AppDatabase database;
  SavingGoalLocalDataSourceImpl({required this.database});

  @override
  Future<void> addContribution(SavingContributionsCompanion contribution) async {
    try {
      await database.into(database.savingContributions).insert(contribution);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteSavingGoal(int goalId) async {
    try {
      await (database.delete(database.savingGoals)..where((tbl) => tbl.id.equals(goalId))).go();
      // Note: Karena 'onDelete: KeyAction.cascade' gak ada di tabel Contributions,
      // kita mungkin perlu hapus setorannya manual, tapi kita coba dulu.
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<SavingContributionModel>> getAllContributions() async {
    try {
      final data = await database.select(database.savingContributions).get();
      return data.map((d) => SavingContributionModel.fromDrift(d)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<SavingGoalModel>> getAllSavingGoals() async {
    try {
      final data = await database.select(database.savingGoals).get();
      return data.map((d) => SavingGoalModel.fromDrift(d)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<SavingContributionModel>> getGoalContributions(int goalId) async {
    try {
      final query = database.select(database.savingContributions)
        ..where((tbl) => tbl.goalId.equals(goalId));
      final data = await query.get();
      return data.map((d) => SavingContributionModel.fromDrift(d)).toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> saveSavingGoal(SavingGoalsCompanion goal) async {
    try {
      // 'insertOnConflictUpdate' adalah "Tamu Baru" / "Update Tamu Lama"
      await database.into(database.savingGoals).insertOnConflictUpdate(goal);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}