import 'package:equatable/equatable.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgetsEvent extends BudgetEvent {
  final int month;
  final int year;

  const LoadBudgetsEvent({required this.month, required this.year});

  @override
  List<Object> get props => [month, year];
}

class SaveBudgetEvent extends BudgetEvent {
  final Budget budget;

  const SaveBudgetEvent({required this.budget});

  @override
  List<Object> get props => [budget];
}

// EVENT BARU: Untuk menghapus budget
class DeleteBudgetEvent extends BudgetEvent {
  final int budgetId;
  final int month; // Diperlukan untuk me-refresh halaman ke bulan yang benar
  final int year;

  const DeleteBudgetEvent({
    required this.budgetId,
    required this.month,
    required this.year,
  });

  @override
  List<Object> get props => [budgetId, month, year];
}