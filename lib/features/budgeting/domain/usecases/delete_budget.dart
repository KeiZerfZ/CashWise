import 'package:equatable/equatable.dart';
import 'package:cashwise/core/either.dart';
import 'package:cashwise/core/error/failures.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/budgeting/domain/repositories/budget_repository.dart';

// Implementasi UseCase dengan Type 'void' dan Params 'DeleteBudgetParams'
class DeleteBudget implements UseCase<void, DeleteBudgetParams> {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  // Tipe kembalian di sini sudah sesuai dengan kontrak: Future<Either<Failure, void>>
  @override
  Future<Either<Failure, void>> call(DeleteBudgetParams params) async {
    // FIX: Repository hanya butuh ID untuk menghapus.
    // Kita panggil repository dengan hanya mengirimkan budgetId dari params.
    return await repository.deleteBudget(params.budgetId);
  }
}

// Class untuk membungkus parameter yang dibutuhkan oleh 'call'
class DeleteBudgetParams extends Equatable {
  final int budgetId;
  // Kita tetap simpan month & year di sini, mungkin berguna untuk logic lain nanti,
  // tapi tidak kita kirim ke repository.
  final int month;
  final int year;

  const DeleteBudgetParams({
    required this.budgetId,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [budgetId, month, year];
}

