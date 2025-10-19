import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart';

// Ini adalah KONTRAK KERJA untuk semua yang berhubungan dengan Budget.
// Setiap UseCase Budget akan berbicara melalui kontrak ini.
abstract class BudgetRepository {
  /// Mengambil daftar budget beserta total pengeluaran untuk bulan dan tahun tertentu.
  Future<Either<Failure, List<BudgetWithSpending>>> getBudgetsWithSpending(int month, int year);
  
  /// Menyimpan atau memperbarui sebuah budget.
  Future<Either<Failure, void>> saveBudget(Budget budget);

  /// Menghapus sebuah budget berdasarkan ID-nya.
  /// NOTE: Di sini kita sederhanakan, asumsi datasource hanya butuh budgetId untuk menghapus.
  Future<Either<Failure, void>> deleteBudget(int budgetId);
}

