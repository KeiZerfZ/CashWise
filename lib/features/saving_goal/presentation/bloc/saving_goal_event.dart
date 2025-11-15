import 'package:equatable/equatable.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_contribution.dart';
import 'package:cashwise/features/saving_goal/domain/entities/saving_goal.dart';

abstract class SavingGoalEvent extends Equatable {
  const SavingGoalEvent();
  @override
  List<Object> get props => [];
}

/// Event untuk memuat semua celengan (untuk halaman "Markas")
class LoadAllSavingGoals extends SavingGoalEvent {}

/// Event untuk memuat detail setoran dari 1 celengan (untuk halaman "Detail")
class LoadGoalDetails extends SavingGoalEvent {
  final int goalId;
  const LoadGoalDetails({required this.goalId});
  @override
  List<Object> get props => [goalId];
}

/// Event untuk menyimpan (tambah/edit) celengan
class SaveSavingGoalEvent extends SavingGoalEvent {
  final SavingGoal goal;
  const SaveSavingGoalEvent({required this.goal});
  @override
  List<Object> get props => [goal];
}

/// Event untuk menghapus celengan
class DeleteSavingGoalEvent extends SavingGoalEvent {
  final int goalId;
  const DeleteSavingGoalEvent({required this.goalId});
  @override
  List<Object> get props => [goalId];
}

/// Event untuk menambah setoran ke celengan
class AddContributionEvent extends SavingGoalEvent {
  final SavingContribution contribution;
  const AddContributionEvent({required this.contribution});
  @override
  List<Object> get props => [contribution];
}