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
      // Untuk update, kita perlu ID-nya. Untuk insert, tidak.
      // Kita handle ini di RepositoryImpl nanti.
      id: Value(id),
      categoryId: Value(categoryId),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
    );
  }
}
