import 'package:equatable/equatable.dart';
import 'package:cashwise/features/budgeting/domain/entities/budget_with_spending.dart'; // <-- Ganti import

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetWithSpending> budgets; // <-- Gunakan entity baru

  const BudgetLoaded({required this.budgets});

  @override
  List<Object> get props => [budgets];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});

  @override
  List<Object> get props => [message];
}