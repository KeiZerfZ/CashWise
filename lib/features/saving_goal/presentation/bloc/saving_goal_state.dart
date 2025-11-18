import 'package:equatable/equatable.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal_with_details.dart';

abstract class SavingGoalState extends Equatable {
  const SavingGoalState();
  @override
  List<Object> get props => [];
}

class SavingGoalInitial extends SavingGoalState {}

class SavingGoalLoading extends SavingGoalState {}

class SavingGoalError extends SavingGoalState {
  final String message;
  const SavingGoalError({required this.message});
  @override
  List<Object> get props => [message];
}

// State ini akan nampung SEMUA data yang kita butuhin
class SavingGoalLoaded extends SavingGoalState {
  // Untuk halaman "Markas" (List semua celengan)
  final List<SavingGoalWithDetails> goals;
  // Untuk halaman "Detail" (List setoran dari 1 celengan)
  final List<SavingContribution> contributions;

  const SavingGoalLoaded({
    this.goals = const [],
    this.contributions = const [],
  });

  // Bikin copyWith biar gampang update state tanpa ngilangin data lain
  SavingGoalLoaded copyWith({
    List<SavingGoalWithDetails>? goals,
    List<SavingContribution>? contributions,
  }) {
    return SavingGoalLoaded(
      goals: goals ?? this.goals,
      contributions: contributions ?? this.contributions,
    );
  }

  @override
  List<Object> get props => [goals, contributions];
}