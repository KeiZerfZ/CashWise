import 'package:drift/drift.dart';
import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';

// "Penerjemah" untuk SavingGoal
class SavingGoalModel extends SavingGoal {
  const SavingGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    super.targetDate,
  });

  // Konversi dari Entity (Resep) ke Model
  factory SavingGoalModel.fromEntity(SavingGoal entity) {
    return SavingGoalModel(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      targetDate: entity.targetDate,
    );
  }

  // Konversi dari data Drift (Catatan Database) ke Model
  factory SavingGoalModel.fromDrift(SavingGoalData driftData) {
    return SavingGoalModel(
      id: driftData.id,
      name: driftData.name,
      targetAmount: driftData.targetAmount,
      targetDate: driftData.targetDate,
    );
  }

  // Konversi dari Model ke format Companion (buat nulis ke DB)
  SavingGoalsCompanion toCompanion() {
    return SavingGoalsCompanion(
      // Pake trik "id: 0" kita biar Drift tau ini data baru
      id: (id == 0) ? const Value.absent() : Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      targetDate: Value(targetDate),
    );
  }
}