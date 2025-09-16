import 'package:cashwise/data/local/app_database.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:drift/drift.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.month,
    required super.year,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      amount: budget.amount,
      month: budget.month,
      year: budget.year,
    );
  }

  // Menggunakan 'BudgetData' yang di-generate oleh Drift
  factory BudgetModel.fromTable(BudgetData tableData) {
    return BudgetModel(
      id: tableData.id,
      categoryId: tableData.categoryId,
      amount: tableData.amount,
      month: tableData.month,
      year: tableData.year,
    );
  }

  BudgetsCompanion toTableCompanion() {
    return BudgetsCompanion(
      // Jika id bukan 0, kirim nilainya. Jika 0, biarkan Drift auto-increment.
      id: id == 0 ? const Value.absent() : Value(id), 
      categoryId: Value(categoryId),
      amount: Value(amount),
      month: Value(month),
      year: Value(year),
    );
  }
}