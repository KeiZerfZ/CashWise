import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/features/budgeting/domain/usecases/delete_budget.dart';
import 'package:cashwise/features/budgeting/domain/usecases/get_budgets_with_spending.dart';
import 'package:cashwise/features/budgeting/domain/usecases/save_budget.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetsWithSpending getBudgetsWithSpending;
  final SaveBudget saveBudget;
  final DeleteBudget deleteBudget;

  BudgetBloc({
    required this.getBudgetsWithSpending,
    required this.saveBudget,
    required this.deleteBudget,
  }) : super(BudgetInitial()) {

    on<LoadBudgetsEvent>((event, emit) async {
      emit(BudgetLoading());
      final result = await getBudgetsWithSpending(GetBudgetsParams(month: event.month, year: event.year));
      result.fold(
        (failure) => emit(BudgetError(message: failure.message)),
        (budgets) => emit(BudgetLoaded(budgets: budgets)),
      );
    });

    on<SaveBudgetEvent>((event, emit) async {
      await saveBudget(SaveBudgetParams(budget: event.budget));
      add(LoadBudgetsEvent(month: event.budget.month, year: event.budget.year));
    });

    on<DeleteBudgetEvent>((event, emit) async {
      await deleteBudget(DeleteBudgetParams(budgetId: event.budgetId, month: event.month, year: event.year));
      add(LoadBudgetsEvent(month: event.month, year: event.year));
    });
  }
}