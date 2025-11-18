import 'package:drift/drift.dart';
import 'package:cashwise/data/local/app_database.dart'; // Import tabel Drift
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';

// Model ini adalah "penerjemah" antara Entity dan format Database
class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.month,
    required super.year,
  });

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      categoryId: entity.categoryId,
      amount: entity.amount,
      month: entity.month,
      year: entity.year,
    );
  }

  // Mengubah Model menjadi format yang bisa disimpan Drift
  BudgetsCompanion toCompanion() {
    return BudgetsCompanion(
      // =================================================================
      // INI DIA PERBAIKANNYA!
      // =================================================================
      // Kalo id-nya 0 (sinyal "data baru"), kita kirim 'Value.absent()'.
      // Ini bilang ke Drift: "Tolong, biarin database yang urus ID-nya" (pake autoIncrement).
      // Kalo id-nya BUKAN 0 (artinya mode Edit), baru kita kirim ID-nya.
      id: (id == 0) ? const Value.absent() : Value(id),
      
      categoryId: Value(categoryId),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
    );
  }

  // Kita juga butuh 'fromDrift' biar bisa dibaca (walaupun BudgetPage
  // pake 'BudgetWithSpending', tapi ini best practice)
  factory BudgetModel.fromDrift(BudgetData driftData) {
    return BudgetModel(
      id: driftData.id,
      categoryId: driftData.categoryId,
      amount: driftData.amount,
      month: driftData.month,
      year: driftData.year,
    );
  }
}