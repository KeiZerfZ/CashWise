import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashwise/core/usecase/usecase.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/add_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/delete_saving_goal.dart' as del_goal;
import 'package:cashwise/features/saving_goal/domain/usecases/get_all_saving_goals.dart';
import 'package:cashwise/features/saving_goal/domain/usecases/get_goal_details.dart' as get_details;
import 'package:cashwise/features/saving_goal/domain/usecases/save_saving_goal.dart';
import 'saving_goal_event.dart';
import 'saving_goal_state.dart';

class SavingGoalBloc extends Bloc<SavingGoalEvent, SavingGoalState> {
  final GetAllSavingGoals getAllSavingGoals;
  final get_details.GetGoalDetails getGoalDetails;
  final SaveSavingGoal saveSavingGoal;
  final del_goal.DeleteSavingGoal deleteSavingGoal;
  final AddContribution addContribution;

  SavingGoalBloc({
    required this.getAllSavingGoals,
    required this.getGoalDetails,
    required this.saveSavingGoal,
    required this.deleteSavingGoal,
    required this.addContribution,
  }) : super(SavingGoalInitial()) {
    
    on<LoadAllSavingGoals>(_onLoadAllSavingGoals);
    on<LoadGoalDetails>(_onLoadGoalDetails);
    on<SaveSavingGoalEvent>(_onSaveSavingGoal);
    on<DeleteSavingGoalEvent>(_onDeleteSavingGoal);
    on<AddContributionEvent>(_onAddContribution);
  }

  Future<void> _onLoadAllSavingGoals(
    LoadAllSavingGoals event,
    Emitter<SavingGoalState> emit,
  ) async {
    emit(SavingGoalLoading());
    final result = await getAllSavingGoals(NoParams());
    
    // Ambil 'contributions' dari state lama (kalo ada) biar gak ke-reset
    final oldContributions = (state is SavingGoalLoaded) ? (state as SavingGoalLoaded).contributions : <dynamic>[];
    
    result.fold(
      (failure) => emit(SavingGoalError(message: failure.message)),
      // FIX: Kirim 'goals' baru, tapi 'contributions' lama tetep dibawa
      (goals) => emit(SavingGoalLoaded(
        goals: goals,
        contributions: List.from(oldContributions), // <-- DIBAWA TERUS
      )),
    );
  }

  Future<void> _onLoadGoalDetails(
    LoadGoalDetails event,
    Emitter<SavingGoalState> emit,
  ) async {
    // JANGAN emit Loading() di sini biar gak kedip
    final currentState = state;
    
    final result = await getGoalDetails(get_details.Params(goalId: event.goalId));
    
    result.fold(
      (failure) => emit(SavingGoalError(message: failure.message)),
      (contributions) {
        // FIX: Pake 'copyWith' buat "nge-merge" state
        if (currentState is SavingGoalLoaded) {
          emit(currentState.copyWith(contributions: contributions));
        } else {
          // Kalo state-nya masih Initial, baru kita bikin
          emit(SavingGoalLoaded(contributions: contributions));
        }
      },
    );
  }

  Future<void> _onSaveSavingGoal(
    SaveSavingGoalEvent event,
    Emitter<SavingGoalState> emit,
  ) async {
    final result = await saveSavingGoal(event.goal);
    result.fold(
      (failure) => emit(SavingGoalError(message: failure.message)),
      (_) => add(LoadAllSavingGoals()),
    );
  }

  Future<void> _onDeleteSavingGoal(
    DeleteSavingGoalEvent event,
    Emitter<SavingGoalState> emit,
  ) async {
    final result = await deleteSavingGoal(del_goal.Params(goalId: event.goalId));
    result.fold(
      (failure) => emit(SavingGoalError(message: failure.message)),
      (_) => add(LoadAllSavingGoals()),
    );
  }

  Future<void> _onAddContribution(
    AddContributionEvent event,
    Emitter<SavingGoalState> emit,
  ) async {
    final result = await addContribution(event.contribution);
    result.fold(
      (failure) => emit(SavingGoalError(message: failure.message)),
      (_) {
        // Panggil DUA-DUANYA (handlers-nya udah bener, jadi aman)
        add(LoadAllSavingGoals());
        add(LoadGoalDetails(goalId: event.contribution.goalId));
      },
    );
  }
}